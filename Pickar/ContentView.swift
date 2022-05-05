//
//  ContentView.swift
//  Pickar
//
//  Created by Rivaldo Fernandes on 04/05/22.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    @State private var isPlacementEnabled = false
    
    
    private var models: [String] = {
       //dynamicly get our model filename
        let fileManager = FileManager.default
        
        guard let path = Bundle.main.resourcePath, let files = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        
        var availableModel: [String] = []
        for fileName in files where fileName.hasSuffix("usdz") {
            let modelName = fileName.replacingOccurrences(of: ".usdz", with: "")
            availableModel.append(modelName)
        }
        
        return availableModel
    }()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer()
            
            if(self.isPlacementEnabled){
                PlacementButtonsView()
            }else{
                ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, models: self.models)
            }
            
        }
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    func makeUIView(context: Context) -> ARView {
        
        let arView = ARView(frame: .zero)
        
        return arView
        
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
}

struct PlacementButtonsView: View {
    var body: some View {
        HStack {
            //cancel button
            Button(action: {
                print("DEBUG: model replacement canceled")
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
}


struct ModelPickerView: View {
    @Binding var isPlacementEnabled: Bool
    
    var models: [String]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 30) {
                ForEach(0 ..< self.models.count, id: \.self){ index in
                    Button(action: {
                        print("DEBUG : selected model with name \(models[index])")
                        
                        self.isPlacementEnabled = true
                    }){
                        Image(uiImage: UIImage(named: models[index])!)
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
