import SwiftUI
import RealityKit
import RealityKitContent
import ARKit

struct Arena: View {
    @EnvironmentObject var model: AppModel
    //    @Environment(CommonSpaceViewModel.self) var commonModel
    @Environment(\.physicalMetrics) var physicalMetrics
    //    var commonModel = CommonSpaceViewModel()
    //    var roadModel = RoadViewModel()
    //    var arkitViewModel = ARKitViewModel()
    
    /*-----------------------------------------------------------------------------------------*/
    /*Jeff Code for collision*/
    @State private var collisionBegan: EventSubscription?
    @State private var collisionEnded: EventSubscription?
    @Environment(\.realityKitScene) var scene
    let rknt = "RealityKit.NotificationTrigger"
    fileprivate func notify(_ scene: RealityKit.Scene) {
        let notification = Notification(name: .init(rknt), userInfo: ["\(rknt).Scene" : scene, "\(rknt).Identifier" : "notifier"])
        NotificationCenter.default.post(notification)
    }
    /*-----------------------------------------------------------------------------------------*/
    
    /*-----------------------------------------------------------------------------------------*/
    /*Code for image tracking*/
    let arSession = ARKitSession()
    let imageInfo = ImageTrackingProvider(referenceImages: ReferenceImage.loadReferenceImages(inGroupNamed: "CardDeck20"))
    var entity = Entity()
//    var entityMap : [UUID: ModelEntity] = [:]
    var rootEntity = Entity()
    let simpleMaterial = SimpleMaterial(
        color: .red, isMetallic: false
    )
    let anchoring = AnchoringComponent(.image(group: "CardDeck20", name: "IMG_4108"))
    /*-----------------------------------------------------------------------------------------*/
    
    var body: some View {
        RealityView { content, attachments in
            
            //Jeff Code
            let configuration = SpatialTrackingSession.Configuration(tracking: [.hand])
            let session = SpatialTrackingSession()
            await session.run(configuration)
            
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(immersiveContentEntity)
                let headAnchor = AnchorEntity(.hand(.right, location: .indexFingerTip))
                
                headAnchor.anchoring.physicsSimulation = .none
                headAnchor.components.set(InputTargetComponent())
                headAnchor.components.set(ModelComponent(mesh: .generateSphere(radius: 0.01), materials: [SimpleMaterial()]))
                headAnchor.components.set(CollisionComponent(shapes: [.generateSphere(radius: 0.1)], mode: CollisionComponent.Mode.trigger))
                content.add(headAnchor)
                collisionBegan = content.subscribe(to: CollisionEvents.Began.self, on: headAnchor) { collisionEvent in
                    print("Collision began.")
                    if let scene {
                        notify(scene)
                    }
                }
                collisionEnded = content.subscribe(to: CollisionEvents.Ended.self, on: headAnchor) { collisionEvent in
                    print("Collision ended.")
                }
                
            }
            
            let _ = await arSession.requestAuthorization(for: [.worldSensing, .handTracking, .cameraAccess])
            
            /*if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                print(immersiveContentEntity)
                content.add(immersiveContentEntity)
                
                immersiveContentEntity.findEntity(named: "Transform")?.anchor?.anchoring = anchoring
//                immersiveContentEntity.findEntity(named: "Transform")?.transform.scale /= 2
                immersiveContentEntity.findEntity(named: "Transform")?.transform.translation.z = 0.25
                
//                immersiveContentEntity.transform.translation = immersiveContentEntity.findEntity(named: "Transform")?.transform.translation ?? SIMD3()
            }*/
            
            //Img tracking/detection
//            await implementImgAnchor(content: content)
            
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
        .gesture(
            SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded {
                $0.entity.applyTapForBehaviors()
            }
        )
    }
        
    
    func implementImgAnchor(content: RealityViewContent) async {
        
        var entityMap : [UUID: ModelEntity] = [:]
        var toPrint: Bool = true
        
        if true {
            do {
                try await arSession.run([imageInfo])
            } catch {
                print("error in img tracking provider")
            }
            
            for await update in imageInfo.anchorUpdates {
//                let _ = print(update.anchor.description)
                let entity = ModelEntity(mesh: .generateSphere(radius: 2), materials: [simpleMaterial])
                entityMap[update.anchor.id] = entity
                rootEntity.addChild(entity)
                entityMap[update.anchor.id]?.transform = Transform(matrix: update.anchor.originFromAnchorTransform)
                content.add(entity)
                if (toPrint){ print("Image anchor detected!"); toPrint = false }
                
            }
        }
    }
                        
    
    //    var worldAnchor: Entity = AnchorEntity(.image(group: "CardDeck20", name: "IMG_4108"), trackingMode: .once)
    
    //    var body: some View {
    //        RealityView { content in
    //            content.add(commonModel.setupContentEntity())
    
    //            roadModel.root = commonModel.homeEntity
    //            content.add(roadModel.myRoad)
    //            commonModel.homeEntity.addChild(roadModel.yourRoad)
    
    
    //            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
    //                content.add(immersiveContentEntity)
    //            }
    
    //            await arkitViewModel.runSession()
    
    //            try? await arkitViewModel.runSession()
    
    
    //            roadModel.root = worldAnchor
    //            worldAnchor.addChild(roadModel.myRoad)
    //            worldAnchor.addChild(roadModel.yourRoad)
    //        }
    //        .task {
    //            do {
    //                if commonModel.dataProvidersAreSupported && commonModel.isReadyToRun {
    //                    try await commonModel.runSession()
    //                } else {
    //                    print("providers not supported or model not ready to run!!")
    //                }
    //            } catch {
    //                print("Failed to start session!")
    //            }
    //        }
    //        .task {
    //            await commonModel.processUpdates()
    //        }
    //        .task(priority: .low) {
    //            await commonModel.processLowUpdates()
    //        }
    //    }
}
