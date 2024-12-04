import SwiftUI
import RealityKit
import GroupActivities
import Combine

@MainActor
class AppModel: ObservableObject {
    @Published private(set) var activityState = ActivityState()
    private(set) var rootEntity = Entity()
    @Published private(set) var movingPieces: [Piece.ID] = []
    @Published var isFullSpaceShown: Bool = false
    
    @Published private(set) var groupSession: GroupSession<AppGroupActivity>?
    private var messenger: GroupSessionMessenger?
    private var subscriptions: Set<AnyCancellable> = []
    private var tasks: Set<Task<Void, Never>> = []
    @Published private(set) var spatialSharePlaying: Bool?
    @Published private(set) var queueToOpenScene: TargetScene?
    
    
    init() {
        self.configureGroupSessions()
        self.setUpEntities()
    }
}

extension AppModel {
    func upScale() {
        self.activityState.viewScale *= self.floorMode ? 1.4 : 1.1
        self.sendMessage()
    }
    func downScale() {
        self.activityState.viewScale *= self.floorMode ? 0.75 : 0.9
        self.sendMessage()
    }
    func raiseBoard() {
        self.activityState.viewHeight += 50
        self.sendMessage()
    }
    func lowerBoard() {
        self.activityState.viewHeight -= 50
        self.sendMessage()
    }
    func lowerToFloor() {
        self.activityState.viewHeight = 0
        self.sendMessage()
    }
    func separateFromFloor() {
        self.activityState.viewHeight = 1000
        self.sendMessage()
    }
    func rotateBoard() {
        self.activityState.boardAngle += 90
        self.sendMessage()
    }
    func expandToolbar(_ position: ToolbarPosition) {
        self.activityState.expandedToolbar.append(position)
        self.sendMessage()
    }
    func closeToolbar(_ position: ToolbarPosition) {
        self.activityState.expandedToolbar.removeAll { $0 == position }
        self.sendMessage()
    }
    func clearQueueToOpenScene() {
        self.queueToOpenScene = nil
    }
    var isSharePlayStateNotSet: Bool {
        self.groupSession?.state == .joined
        &&
        self.activityState.mode == .localOnly
    }
    var floorMode: Bool {
        self.isFullSpaceShown
        &&
        self.activityState.viewHeight == 0
    }
}

private extension AppModel {
    private func setUpEntities() {
        self.activityState.chess.setPreset()
    }
}

//MARK: ==== SharePlay ====
extension AppModel {
    var showProgressView: Bool {
        self.groupSession != nil
        &&
        self.activityState.mode == .localOnly
    }
    private func configureGroupSessions() {
        Task {
            for await groupSession in AppGroupActivity.sessions() {
                self.activityState.clear()
                self.activityState.chess.setPreset()
                
                self.groupSession = groupSession
                let messenger = GroupSessionMessenger(session: groupSession)
                self.messenger = messenger
                
                groupSession.$state
                    .sink {
                        if case .invalidated = $0 {
                            self.messenger = nil
                            self.tasks.forEach { $0.cancel() }
                            self.tasks = []
                            self.subscriptions = []
                            self.groupSession = nil
                            self.spatialSharePlaying = nil
                            self.activityState.chess.clearLog()
                            self.activityState.chess.setPreset()
                            self.activityState.mode = .localOnly
                        }
                    }
                    .store(in: &self.subscriptions)
                
                groupSession.$activeParticipants
                    .sink {
                        if $0.count == 1 { self.activityState.mode = .sharePlay }
                        let newParticipants = $0.subtracting(groupSession.activeParticipants)
                        Task {
                            try? await messenger.send(self.activityState,
                                                      to: .only(newParticipants))
                        }
                    }
                    .store(in: &self.subscriptions)
                
                self.tasks.insert(
                    Task {
                        for await (message, _) in messenger.messages(of: ActivityState.self) {
                            self.receive(message)
                        }
                    }
                )
                
#if os(visionOS)
                self.tasks.insert(
                    Task {
                        if let systemCoordinator = await groupSession.systemCoordinator {
                            for await localParticipantState in systemCoordinator.localParticipantStates {
                                self.spatialSharePlaying = localParticipantState.isSpatial
                            }
                        }
                    }
                )
                
                self.tasks.insert(
                    Task {
                        if let systemCoordinator = await groupSession.systemCoordinator {
                            for await immersionStyle in systemCoordinator.groupImmersionStyle {
                                if immersionStyle != nil {
                                    self.queueToOpenScene = .fullSpace
                                } else {
                                    self.queueToOpenScene = .volume
                                }
                            }
                        }
                    }
                )
                
                self.tasks.insert(
                    Task {
                        if let systemCoordinator = await groupSession.systemCoordinator {
                            var configuration = SystemCoordinator.Configuration()
                            configuration.supportsGroupImmersiveSpace = true
                            systemCoordinator.configuration = configuration
                            groupSession.join()
                        }
                    }
                )
#else
                groupSession.join()
#endif
            }
        }
    }
    private func sendMessage() {
        Task {
            try? await self.messenger?.send(self.activityState)
        }
    }
    private func receive(_ message: ActivityState) {
        guard message.mode == .sharePlay else { return }
        Task { @MainActor in
            self.activityState = message
        }
    }
#if os(iOS)
    func   activateGroupActivity() {
        Task {
            do {
                let result = try await AppGroupActivity().activate()
                switch result {
                    case true: self.activityState.mode = .sharePlay
                    default: break
                }
            } catch {
                print("Failed to activate activity: \(error)")
            }
        }
    }
#endif
}

//Ref: Drawing content in a group session | Apple Developer Documentation
//https://developer.apple.com/documentation/groupactivities/drawing_content_in_a_group_session
//Ref: Design spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10075
//Ref: Build spatial SharePlay experiences - WWDC23 - Videos - Apple Developer
//https://developer.apple.com/videos/play/wwdc2023/10087
