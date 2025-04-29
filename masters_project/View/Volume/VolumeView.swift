import SwiftUI
import RealityKit
import ARKit

struct VolumeView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissWindow) var dismissWindow
    
    var body: some View {
        VStack(spacing: 12) {
            if self.showSharePlayMenu {
                SharePlayMenu()
                    .frame(height: self.boardSize * 0.65)
            }
            Spacer()
//            Arena()
            if(model.groupSession?.localParticipant == model.groupSession?.activeParticipants.first){
                ToolbarsView(targetScene: .volume)
            }
        }
        .frame(width: self.boardSize, height: self.boardSize)
        .frame(depth: self.boardSize)
        .onChange(of: self.model.queueToOpenScene) { _, newValue in
            if newValue == .fullSpace {
                Task {
                    await self.openImmersiveSpace(id: "immersiveSpace")
                    self.dismissWindow(id: "volume")
                    self.model.clearQueueToOpenScene()
                }
            }
        }
        .task {
            print("in volume view register")
            SharePlayProvider.registerGroupActivity()
        }
    }
}

private extension VolumeView {
    private var boardSize: CGFloat {
        Size.Point.board(self.physicalMetrics)
    }
    private var showSharePlayMenu: Bool {
#if targetEnvironment(simulator)
        true
//        false
#else
        self.model.groupSession == nil
#endif
    }
}
