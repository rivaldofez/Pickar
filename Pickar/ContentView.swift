//
//  ContentView.swift
//  Pickar
//
//  Created by Rivaldo Fernandes on 04/05/22.
//

import SwiftUI
import RealityKit
import ARKit
import FocusEntity

struct ContentView : View {
    @State private var isPlacementEnabled = false
    @State private var selectedModel: Model?
    @State private var modelConfirmedForPlacement: Model?
    
    
    
    private var models: [Model] = {
       //dynamicly get our model filename
        let fileManager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableModel: [Model] = []
        for fileName in files where fileName.hasSuffix("usdz") {
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            let model = Model(modelName: modelName)
            
            availableModel.append(model)
            
            
        }
        
        return availableModel
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer(modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            
            if(self.isPlacementEnabled){
                PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
            }else{
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
            }
            
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var modelConfirmedForPlacement: Model?
    
    func makeUIView(context: Context) -> ARView {
        
//        let arView = ARView(frame: .zero)
        let arView = FocusARView(frame: .zero)
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let model = self.modelConfirmedForPlacement {
            if let modelEntity = model.modelEntity {
                print("DEBUG: adding model to scene = \(model.modelName)")
                
                let anchorEntity = AnchorEntity(plane: .any)
                anchorEntity.addChild(modelEntity.clone(recursive: true))
                
                uiView.scene.addAnchor(anchorEntity)
            } else {
                print("DEBUG: unable to load model to model entity for modelname = \(model.modelName)")
            }
            
           
            DispatchQueue.main.async {
                self.modelConfirmedForPlacement = nil
            }
        }
    }
    
}

import RealityKit
import FocusEntity
import Combine
import ARKit

class FocusARView: ARView {
  enum FocusStyleChoices {
    case classic
    case material
    case color
  }

  /// Style to be displayed in the example
  let focusStyle: FocusStyleChoices = .color
  var focusEntity: FocusEntity?
    
    
  required init(frame frameRect: CGRect) {
    super.init(frame: frameRect)
    self.setupConfig()

    switch self.focusStyle {
    case .color:
      self.focusEntity = FocusEntity(on: self, focus: .plane)
    case .material:
      do {
        let onColor: MaterialColorParameter = try .texture(.load(named: "Add"))
        let offColor: MaterialColorParameter = try .texture(.load(named: "Open"))
        self.focusEntity = FocusEntity(
          on: self,
          style: .colored(
            onColor: onColor, offColor: offColor,
            nonTrackingColor: offColor
          )
        )
      } catch {
        self.focusEntity = FocusEntity(on: self, focus: .classic)
        print("Unable to load plane textures")
        print(error.localizedDescription)
      }
    default:
      self.focusEntity = FocusEntity(on: self, focus: .classic)
    }
  }

  func setupConfig() {
      let config = ARWorldTrackingConfiguration()
      config.planeDetection = [.horizontal, .vertical]
      config.environmentTexturing = .automatic
      
      if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh){
          config.sceneReconstruction = .mesh
      }
      
      self.session.run(config)
  }

  @objc required dynamic init?(coder decoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}

extension FocusARView: FocusEntityDelegate {
  func toTrackingState() {
    print("tracking")
  }
  func toInitializingState() {
    print("initializing")
  }
}


struct PlacementButtonsView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    @Binding var modelConfirmedForPlacement: Model?
    
    var body: some View {
        HStack {
            //cancel button
            Button(action: {
                print("DEBUG: model replacement canceled")
                self.resetPlacementParameters()
                
            }){
                Image(systemName: "xmark")
                    .frame(width:60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
            
            //confirm button
            Button(action: {
                print("DEBUG: model replacement confirmed")
                self.modelConfirmedForPlacement = self.selectedModel
                self.resetPlacementParameters()
            }){
                Image(systemName: "checkmark")
                    .frame(width:60, height: 60)
                    .font(.title)
                    .background(Color.white.opacity(0.75))
                    .cornerRadius(30)
                    .padding(20)
            }
        }
    }
    
    func resetPlacementParameters(){
        self.isPlacementEnabled = false
        self.selectedModel = nil
    }
}


struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    @Binding var selectedModel: Model?
    
    var models: [Model]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count, id: \.self){ index in
                    Button(action: {
                        print("DEBUG : selected model with name \(models[index])")
                        
                        self.selectedModel = self.models[index]
                        self.isPlacementEnabled = true
                    }){
                        Image(uiImage: self.models[index].image)
                            .resizable()
                            .frame(height: 80)
                            .aspectRatio(1/1, contentMode: .fit)
                            .background(Color.white)
                            .cornerRadius(12)
                    }.buttonStyle(PlainButtonStyle())
                }
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.5))
    }
}


#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
