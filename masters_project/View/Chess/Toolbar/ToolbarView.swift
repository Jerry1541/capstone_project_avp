import SwiftUI

struct ToolbarView: View {
    var targetScene: TargetScene
    var position: ToolbarPosition
    @EnvironmentObject var model: AppModel
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissWindow) var dismissWindow
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        ZStack(alignment: .top) {
            Button {
                self.model.expandToolbar(self.position)
            } label: {
                Image(systemName: "ellipsis")
                    .padding(24)
            }
            .buttonStyle(.plain)
            .glassBackgroundEffect()
            .opacity(self.isExpanded ? 0 : 1)
            HStack(spacing: 24) {
                Group {
                    Button {
                        self.model.closeToolbar(self.position)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .resizable()
                            .symbolRenderingMode(.multicolor)
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                    }
                    if self.targetScene == .fullSpace {
                        HStack(spacing: 8) {
                            Button {
                                self.model.raiseBoard()
                            } label: {
                                Image(systemName: "chevron.up")
                                    .frame(width: Self.circleButtonSize,
                                           height: Self.circleButtonSize)
                            }
                            Button {
                                self.model.lowerBoard()
                            } label: {
                                Image(systemName: "chevron.down")
                                    .frame(width: Self.circleButtonSize,
                                           height: Self.circleButtonSize)
                            }
                            Button {
                                self.model.lowerToFloor()
                            } label: {
                                Image(systemName: "arrow.down.to.line")
                                    .frame(width: Self.circleButtonSize,
                                           height: Self.circleButtonSize)
                            }
                        }
                        HStack(spacing: 8) {
                            Button {
                                self.model.upScale()
                            } label: {
                                Image(systemName: "plus")
                                    .frame(width: Self.circleButtonSize,
                                           height: Self.circleButtonSize)
                            }
                            Button {
                                self.model.downScale()
                            } label: {
                                Image(systemName: "minus")
                                    .frame(width: Self.circleButtonSize,
                                           height: Self.circleButtonSize)
                            }
                            .disabled(self.model.activityState.viewScale < 0.6)
                        }
                    }
                    Button {
                        self.model.rotateBoard()
                    } label: {
                        Image(systemName: "arrow.turn.right.up")
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                    }
                }
                .buttonBorderShape(.circle)
                switch self.targetScene {
                    case .volume:
                        Button {
                            Task {
                                await self.openImmersiveSpace(id: "immersiveSpace")
                                self.dismissWindow(id: "volume")
                            }
                        } label: {
                            Label("Enter full space",
                                  systemImage: "arrow.up.left.and.arrow.down.right")
                            .padding(8)
                        }
                    case .fullSpace:
                        Button {
                            Task {
                                self.openWindow(id: "volume")
                                await self.dismissImmersiveSpace()
                            }
                        } label: {
                            Label("Exit full space", systemImage: "escape")
                                .padding(8)
                        }
                }
            }
            .buttonStyle(.plain)
            .disabled(!self.model.movingPieces.isEmpty)
            .font(.subheadline)
            .padding(12)
            .padding(.horizontal, 16)
            .glassBackgroundEffect()
            .opacity(self.isExpanded ? 1 : 0)
        }
        .animation(.default, value: self.isExpanded)
        //.rotation3DEffect(.degrees(20), axis: .x) <- temp
        .rotation3DEffect(.degrees(self.position.rotationDegrees), axis: .y)
    }
}

private extension ToolbarView {
    private var isExpanded: Bool {
        self.model.activityState.expandedToolbar.contains(self.position)
    }
    private static let circleButtonSize = 40.0
}

/*Preview on simulator*/
//Requires Editor > Canvas
//#Preview {
//    ToolbarView(targetScene: TargetScene.volume, position: ToolbarPosition.foreground, model: arg, openImmersiveSpace: arg, dismissImmersiveSpace: <#T##arg#>, openWindow: <#T##arg#>, dismissWindow: <#T##arg#>, physicalMetrics: arg)
//}
