//
//  Persistable.swift
//  PillBox
//
//  Created by Hannah Hoff on 5/20/19.
//  Copyright © 2019 Hannah Hoff. All rights reserved.
//

import Foundation

protocol Persistable {
    var ud: UserDefaults {get}
    var persistKey: String {get}
    func persist()
    func unpersist()
}
