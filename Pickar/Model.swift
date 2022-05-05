//
//  Model.swift
//  Pickar
//
//  Created by Rivaldo Fernandes on 06/05/22.
//

import UIKit
import RealityKit
import Combine

class Model {
    var modelName: String
    var image: UIImage
    var modelEntity: ModelEntity?
    
    private var cancellable: AnyCancellable? = nil
    
    init(modelName: String){
        self.modelName = modelName
        
        self.image = UIImage(named: modelName)!
        
        let fileName = modelName + ".usdz"
        self.cancellable = ModelEntity.loadModelAsync(named: fileName)
            .sink(receiveCompletion: { loadCompletion in
                //handle out error
                print("DEBUG: unable to load model entity for modelname: \(self.modelName)")
            }, receiveValue: { modelEntity in
                //get model entity
                self.modelEntity = modelEntity
                print("DEBUG: Successfully loaded modelEntity for modelname: \(self.modelName)")
            })
    }
    
}
