import SwiftUI
import RealityKit
import RealityKitContent

struct Arena: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        RealityView { content, attachments in
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
            }
        } attachments: {
            Attachment(id: "board") {
            }
        }
        .rotation3DEffect(.degrees(self.model.activityState.boardAngle), axis: .y)
        .animation(.default, value: self.model.activityState.boardAngle)
        .frame(width: Size.Point.board(self.physicalMetrics), height: 0)
        .frame(depth: Size.Point.board(self.physicalMetrics))
        .overlay {
            if self.model.showProgressView {
                ProgressView()
                    .offset(y: -200)
                    .scaleEffect(3)
            }
        }
    }
}
