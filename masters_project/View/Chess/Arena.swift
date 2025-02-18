import SwiftUI
import RealityKit
import RealityKitContent

//let tableTransform = Transform(translation: SIMD3<Float>(x: 0, y: -0.62, z: -1))
let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
struct Arena: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    var body: some View {
        RealityView { content, attachments in
            //content.add(anchor)
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                anchor.addChild(immersiveContentEntity)
                content.add(ImmersiveContentEntity)

                //anchor.addChild(immersiveContentEntity)
                immersiveContentEntity.move(to: Transform(scale: SIMD3(x: 0.1, y: 0.1, z: 0.1), translation: SIMD3<Float>(0.5, -1, -1)), relativeTo: anchor)
                //anchor.addChild(immersiveContentEntity)
                //content.add(anchor)
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
