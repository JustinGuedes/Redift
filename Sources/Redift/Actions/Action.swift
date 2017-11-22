//
//  Action.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/22.
//

import Prelude

public protocol Action {}

public extension Prism where Whole == Action, Part: Action {
    
    static var identity: Prism {
        return Prism(tryGetFrom: { $0 as? Part }, createFrom: { $0 })
    }
    
}
