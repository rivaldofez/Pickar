//
//  ContentView.swift
//  Pickar
//
//  Created by Rivaldo Fernandes on 04/05/22.
//

import SwiftUI
import RealityKit

struct ContentView : View {
    var models: [String] = ["fender_stratocaster", "flower_tulip", "lemon_meringue_pie", "toy_biplane", "wateringcan"]
    
    var body: some View {
        ZStack(alignment: .bottom) {
            ARViewContainer()
            
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 30) {
                    ForEach(0 ..< self.models.count){ index in
                        Button(action: {
                            print("DEBUG : selected model with name \(models[index])")
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

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
