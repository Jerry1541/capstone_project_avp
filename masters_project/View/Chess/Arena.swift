import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct Arena: View {
    @EnvironmentObject var model: AppModel
    @Environment(\.physicalMetrics) var physicalMetrics
    /*-----------------------------------------------------------------------------------------*/
    /*Code for collision*/
    @State private var collisionBegan: EventSubscription?
    @State private var collisionEnded: EventSubscription?
    @State private var isCollision = false
    @State private var isPaused = false
    @State private var isReset = false
    @State var isStart = false
    @Environment(\.realityKitScene) var scene
    let rknt = "RealityKit.NotificationTrigger"
    func notify(_ scene: RealityKit.Scene) {
        if(isStart) {
            let notification_start = Notification(name: .init(rknt), userInfo: ["\(rknt).Scene" : scene, "\(rknt).Identifier" : "start"])
            model.sendAnimationControl(isStart)
            NotificationCenter.default.post(notification_start)
        }
        
        if(isPaused) {
            let notification_resume = Notification(name: .init(rknt), userInfo: ["\(rknt).Scene" : scene, "\(rknt).Identifier" : "resume"])
            NotificationCenter.default.post(notification_resume)
        } else {
            let notification_pause = Notification(name: .init(rknt), userInfo: ["\(rknt).Scene" : scene, "\(rknt).Identifier" : "pause"])
            NotificationCenter.default.post(notification_pause)
        }
        
        if(isCollision) {
            let notification_collide = Notification(name: .init(rknt), userInfo: ["\(rknt).Scene" : scene, "\(rknt).Identifier" : "collision"])
            NotificationCenter.default.post(notification_collide)
        }
        
        if(isReset) {
            let notification_reset = Notification(name: .init(rknt), userInfo: ["\(rknt).Scene" : scene, "\(rknt).Identifier" : "reset"])
            NotificationCenter.default.post(notification_reset)
        }
    }
    /*-----------------------------------------------------------------------------------------*/
    
    var body: some View {
        RealityView { content, attachments in
            
            let configuration = SpatialTrackingSession.Configuration(tracking: [.hand])
            let session = SpatialTrackingSession()
            await session.run(configuration)
            
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) { //Immersive
                // Change opacity
//                immersiveContentEntity.components.set(OpacityComponent(opacity: 0.5))
//                model.sendMessage()
                
                let headAnchor = AnchorEntity(.hand(.right, location: .indexFingerTip))
                
                headAnchor.anchoring.physicsSimulation = .none
                headAnchor.components.set(InputTargetComponent())
                headAnchor.components.set(ModelComponent(mesh: .generateSphere(radius: 0.01), materials: [SimpleMaterial()]))
                headAnchor.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.1)], mode: CollisionComponent.Mode.trigger))
                content.add(headAnchor)
                collisionBegan = content.subscribe(to: CollisionEvents.Began.self, on: headAnchor) { collisionEvent in
                    print("Collision began.")
                    isCollision = true
                    isPaused = true
                    if let scene {
                        notify(scene)
                    }
                }
                collisionEnded = content.subscribe(to: CollisionEvents.Ended.self, on: headAnchor) { collisionEvent in
                    print("Collision ended.")
                    isCollision = false
                    isPaused = false
                }
                content.add(immersiveContentEntity)
            }
            
        }
            attachments: {
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
//            .onReceive(NotificationCenter.default.publisher(for: .didReceiveSessionAction)) { notification in
//                if let action = notification.object as? SessionAction {
//                    switch action {
//                    case .start:
//                        statusText = "🚀 Started!"
//                    case .pause:
//                        statusText = "⏸️ Paused."
//                    case .reset:
//                        statusText = "🔄 Reset."
//                    case .resume:
//                        statusText = "▶️ Resumed."
//                    }
//                }
//            }
            if(model.isFullSpaceShown) {
                HStack {
                    Button("Start", systemImage: "play.fill") {
//                        model.sendAction(.start)
                        isPaused = true
                        isStart = true
                        if let scene {
                            notify(scene)
                        }
                        isPaused = false
                        isStart = false
                    }
                    
                    if(isPaused) {
                        Button("Resume", systemImage: "play.circle") {
                            if let scene {
                                notify(scene)
                            }
                            isPaused = false
                        }
                    }
                    else {
                        Button("Pause", systemImage: "pause.circle") {
                            if let scene {
                                notify(scene)
                            }
                            isPaused = true
                        }
                    }
                    
                    Button("Reset", systemImage: "backward.end.circle") {
                        isReset = true
                        isPaused = true
                        if let scene {
                            notify(scene)
                        }
                        isReset = false
                        isPaused = false
                    }
                }
            }
//            if(isCollision) {
//                ZStack {
//                    Color.red
//                    
//                    Text("Warning! Collision has occurred")
//                }
//                .edgesIgnoringSafeArea(.all)
//            }
        }
}

// MARK: - Code for placing anchors

/*
Variables needed for anchoring
@State var previewSphere: Entity?
@State private var worldTracking = WorldTrackingProvider()
@State private var arSession = ARKitSession()
let contentRoot = Entity()
/// A dictionary that contains `WorldAnchor` structures.
@State var worldAnchors = [UUID: WorldAnchor]()
/// A dictionary that contains `ModelEntity` structures for spheres.
@State var sphereEntities = [UUID: ModelEntity]()
 
/// Removing anchors and children from parent
contentRoot.children.removeAll()
sphereEntities.removeAll()
worldAnchors.removeAll()
arSession.stop()
print(arSession.description)

Placed inside Reality View
/**Place 3 anchors for triangulation***/
await content.add(setupContentEntity())
do {
    try await arSession.run([worldTracking])
} catch let error {
    print("Error = \(error.localizedDescription)")
}
// print("WorldTracking state = \(worldTracking.state)")
// Creates a preview sphere that's attached to the head.
let sphere = createPreviewSphere()
// Places the preview one meter in front of the head.
sphere.position = [0, 0, -1]
previewSphere = sphere
// Creates a head anchor and attaches the preview sphere.
let headAnchor2 = AnchorEntity(.head)
content.add(headAnchor2)
headAnchor2.addChild(sphere)

Placed as closures on RealityView
.task{
 await processWorldTrackingUpdates()
}
.gesture(
 SpatialTapGesture()
     .targetedToAnyEntity()
     .onEnded { event in
         if event.entity == previewSphere {
             Task {
                 // To place a sphere you need to:
                 // 1. Create a world anchor with the translation of that offset transform and add the anchor to the world tracking provider.
                 // 2. Create the sphere's geometry in `processWorldTrackingUpdates()` after you have successfully added the world anchor.
                 if(worldAnchors.count == 3){
                     previewSphere?.isEnabled = false
                     print("3 anchors already exist")
                 }
                 await addWorldAnchor(at: event.entity.transformMatrix(relativeTo: nil))
             }
         }
})
 
Functions for placing spheres and anchors
 func setupContentEntity() async -> Entity {
     return contentRoot
 }
 
 func createPreviewSphere() -> ModelEntity {
     let sphereMesh = MeshResource.generateSphere(radius: 0.1)
     let sphereMaterial = SimpleMaterial(color: .gray.withAlphaComponent(0.5), roughness: 0.2, isMetallic: false)
     let sphere = ModelEntity(mesh: sphereMesh, materials: [sphereMaterial])
     
     // Enables gestures on the preview sphere.
     // Looking at the preview and using a pinch gesture causes a world anchored sphere to appear.
     sphere.generateCollisionShapes(recursive: false, static: true)
     // Ensures the preview only accepts indirect input (for tap gestures).
     sphere.components.set(InputTargetComponent(allowedInputTypes: [.indirect]))
     
     return sphere
 }
 
 func processWorldTrackingUpdates() async {
     for await update in worldTracking.anchorUpdates {
         let worldAnchor = update.anchor
         let sphereMesh = MeshResource.generateSphere(radius: 0.1)
         let material = SimpleMaterial(color: .green, roughness: 0.2, isMetallic: true)
         let sphereEntity = ModelEntity(mesh: sphereMesh, materials: [material])
         sphereEntity.transform = Transform(matrix: worldAnchor.originFromAnchorTransform)
         
         if(worldAnchors.count < 3){
             worldAnchors[worldAnchor.id] = worldAnchor
             sphereEntities[worldAnchor.id] = sphereEntity
             contentRoot.addChild(sphereEntity)
         }
         else{
             print("More than 3 anchors")
         }
     }
 }
 
 func addWorldAnchor(at transform: simd_float4x4) async {
     print(worldTracking.description)
     
     while worldTracking.state != .running {
         print("⏳ Waiting for tracking to become active...")
         do {
             try await Task.sleep(nanoseconds: 500_000_000)
         } catch {
            
         }
     }
     
     let worldAnchor = WorldAnchor(originFromAnchorTransform: transform)
     do {
         try await worldTracking.addAnchor(worldAnchor)
     } catch let error {
         print("The app has encountered an unexpected error: \(error.localizedDescription)")
     }
 }
*/

// MARK: - Code for image anchoring

/*
 
 let arSession = ARKitSession()
 let imageInfo = ImageTrackingProvider(referenceImages: ReferenceImage.loadReferenceImages(inGroupNamed: "CardDeck20"))
 var entity = Entity()
 var rootEntity = Entity()
 let simpleMaterial = SimpleMaterial(
     color: .red, isMetallic: true
 )
 let anchoring = AnchoringComponent(.image(group: "CardDeck20", name: "IMG_4108"))
 
 
 let _ = await arSession.requestAuthorization(for: [.worldSensing, .handTracking, .cameraAccess])

//Img tracking/detection
var imgDetected = await implementImgAnchor(content: content)
 let imgAncEnt = AnchorEntity(components: self.anchoring)
 
immersiveContentEntity.setPosition(SIMD3<Float>(x: 0, y: 0, z: 0), relativeTo: imgAncEnt)


func implementImgAnchor(content: RealityViewContent) async -> Bool  {
    
    var entityMap : [UUID: ModelEntity] = [:]
    var toPrint: Bool = true
    var isDetected: Bool = false
    
    if true {
        do {
            try await arSession.run([imageInfo])
        } catch {
            print("error in img tracking provider")
        }
        
        for await update in imageInfo.anchorUpdates {
//                let _ = print(update.anchor.description)
            let entity = ModelEntity(mesh: .generateSphere(radius: 0.25), materials: [simpleMaterial])
            entityMap[update.anchor.id] = entity
            rootEntity.addChild(entity)
            entityMap[update.anchor.id]?.transform = Transform(matrix: update.anchor.originFromAnchorTransform)
            content.add(entity)
            if (toPrint){
//                    print("Image anchor detected!");
//                    toPrint = false;
                isDetected = true
                return isDetected
            }
            
        }
    }
    return isDetected
}*/
