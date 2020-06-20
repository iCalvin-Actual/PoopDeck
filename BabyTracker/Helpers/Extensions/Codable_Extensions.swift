//
//  Codable_Extensions.swift
//  BabyTracker
//
//  Created by Calvin Chestnut on 6/20/20.
//  Copyright © 2020 Calvin Chestnut. All rights reserved.
//

import Foundation

/// Static instances to reduce memory usage
extension JSONDecoder {
    static var safe: JSONDecoder = {
        var decoder = JSONDecoder()
        return decoder
    }()
}
extension JSONEncoder {
    static var safe: JSONEncoder = {
        var encoder = JSONEncoder()
        return encoder
    }()
}
