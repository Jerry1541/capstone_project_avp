import SwiftUI

struct FullSpaceView: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        
        VStack(spacing: 12) {
            Arena()
            if(model.groupSession?.localParticipant == model.groupSession?.activeParticipants.first){
                ToolbarsView(targetScene: .fullSpace)
            }
            // if !self.model.floorMode { ToolbarsView(targetScene: .fullSpace) }
        }
        .overlay {
            if(model.groupSession?.localParticipant == model.groupSession?.activeParticipants.first){
                ToolbarViewForFloorMode()
            }
            // ToolbarViewForFloorMode()
        }
        .scaleEffect(self.model.activityState.viewScale, anchor: .bottom)
        .offset(z: self.model.spatialSharePlaying == true ? 0 : -1200)
        .offset(y: -self.model.activityState.viewHeight)
        .animation(.default, value: self.model.activityState.viewScale)
        .animation(.default, value: self.model.activityState.viewHeight)
        .onChange(of: self.model.queueToOpenScene) { _, newValue in
            if newValue == .volume {
                Task {
                    self.openWindow(id: "volume")
                    await self.dismissImmersiveSpace()
                    self.model.clearQueueToOpenScene()
                }
            }
        }
        .onAppear { self.model.isFullSpaceShown = true }
        .onDisappear { self.model.isFullSpaceShown = false }
    }
}
