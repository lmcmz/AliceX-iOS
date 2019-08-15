//
//  OpenSea.swift
//  AliceX
//
//  Created by lmcmz on 15/8/19.
//  Copyright © 2019 lmcmz. All rights reserved.
//

import Foundation
import Moya

enum OpenSea {
    case assets(address: String)
}

extension OpenSea: TargetType {
    var baseURL: URL {
        return URL(string: "https://api.opensea.io/api/v1")!
    }

    var path: String {
        switch self {
        case .assets:
            return "/assets"
        }
    }

    var method: Moya.Method {
        return .get
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case let .assets(address):
            return .requestPlain
        }
    }

    var headers: [String: String]? {
        return ["Content-Type": "application/json"]
    }
}
