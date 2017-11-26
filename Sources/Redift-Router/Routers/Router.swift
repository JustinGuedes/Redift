//
//  Router.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/23.
//

import Foundation

public struct Router<T: Constructable & View> {
    
    let views: [String:T.Type]
    
    let push: (View) -> Void
    let pop: (T) -> Void
    let reset: ([T]) -> Void
    
//    public init(views: [T.Type]) {
//        self.views = views.reduce([String:T.Type]()) { result, view in
//            var result = result
//            result[view.identifier] = view
//            return result
//        }
//    }
    
}

//protocol RouterP {
//    
//    associatedtype V
//    
//    func push(_ view: V)
//    
//}
//
//extension Router where T: UIViewController {
//    
//}

