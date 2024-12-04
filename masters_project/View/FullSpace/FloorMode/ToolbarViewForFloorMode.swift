import SwiftUI

struct ToolbarViewForFloorMode: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.openWindow) var openWindow
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        if self.model.floorMode {
            HStack {
                Group {
                    Button {
                        self.model.separateFromFloor()
                    } label: {
                        Image(systemName: "arrow.up.to.line")
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
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
                    Button {
                        self.model.rotateBoard()
                    } label: {
                        Image(systemName: "arrow.turn.right.up")
                            .frame(width: Self.circleButtonSize,
                                   height: Self.circleButtonSize)
                    }
                }
                .buttonBorderShape(.circle)
                .disabled(self.model.activityState.chess.log.isEmpty)
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
            .buttonStyle(.plain)
            .disabled(!self.model.movingPieces.isEmpty)
            .fixedSize()
            .padding()
            .padding(.horizontal)
            .glassBackgroundEffect()
            .rotation3DEffect(.degrees(270), axis: .y)
            .offset(z: -Size.Point.board(physicalMetrics) / 2)
            .offset(x: Size.Point.board(physicalMetrics),
                    y: -Size.Point.board(physicalMetrics) / 2)
        }
    }
}

private extension ToolbarViewForFloorMode {
    private static let circleButtonSize = 48.0
}
