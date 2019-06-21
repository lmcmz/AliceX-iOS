//
//  Moya+HandyJSON.swift
//  AliceX
//
//  Created by lmcmz on 19/6/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Moya
import HandyJSON

extension Response {
    func mapObject<T: HandyJSON>(_ type: T.Type) -> T? {
        
        guard let dataString = String.init(data: self.data, encoding: .utf8),
            let object = JSONDeserializer<T>.deserializeFrom(json: dataString)
            else {
                return nil
        }
        
        return object
    }
    
    func mapObject<T: HandyJSON>(_ type: T.Type, designatedPath: String) -> T? {
        
        guard let dataString = String(data: self.data, encoding: .utf8),
            let object = JSONDeserializer<T>.deserializeFrom(json: dataString, designatedPath: designatedPath)
            else {
                return nil
        }
        
        return object
    }
    
    func mapArray<T: HandyJSON>(_ type: T.Type) -> [T?]? {
        
        guard let dataString = String(data: self.data, encoding: .utf8),
            let object = JSONDeserializer<T>.deserializeModelArrayFrom(json: dataString)
            else {
                return nil
        }
        return object
    }
    
    func mapArray<T: HandyJSON>(_ type: T.Type, designatedPath: String ) -> [T?]? {
        guard let dataString = String(data: self.data, encoding: .utf8),
            let object = JSONDeserializer<T>.deserializeModelArrayFrom(
                json: dataString, designatedPath: designatedPath)
            else {
                return nil
        }
        return object
    }
}
