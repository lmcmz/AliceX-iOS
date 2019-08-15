//
//  Websocket.swift
//  AliceX
//
//  Created by lmcmz on 16/8/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Foundation
import web3swift
import BigInt

class Websocket: Web3SocketDelegate {
    static let shared = Websocket()
    var socketProvider: InfuraWebsocketProvider?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeNetwork), name: .networkChange, object: nil)
        socketProvider = InfuraWebsocketProvider.init(.Mainnet, delegate: self)
        
         try! socketProvider?.subscribeOnNewPendingTransactions()
    }
    
    @objc func changeNetwork() {
        let network = Networks.Custom(networkID: BigUInt(Web3Net.currentNetwork.chainID))
        socketProvider = InfuraWebsocketProvider.init(network, delegate: self)
    }
    
    func received(message: Any) {
        
    }
    
    func gotError(error: Error) {
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
