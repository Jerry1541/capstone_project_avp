import SwiftUI
import RealityKit
import RealityKitContent

let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
struct Arena: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        RealityView { content, attachments in
            content.add(anchor)
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                anchor.addChild(model)
                model.move(to: Transform(scale: SIMD3(x: 1, y: 1, z: 1), translation: SIMD3<Float>(0.01, 0.01, 0.01)), relativeTo: anchor)
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
