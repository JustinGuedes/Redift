//
//  ActionCreator.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

import Foundation

public struct ActionCreator<State, Action> {
    
    let execute: (_ store: SubStore<State, Action>) -> Action?
    
    public init(execute: @escaping (_ store: SubStore<State, Action>) -> Action?) {
        self.execute = execute
    }
    
}

public extension ActionCreator {
    
    static func async(_ action: Action? = .none, _ execute: @escaping (SubStore<State, Action>) -> Void) -> ActionCreator {
        return ActionCreator { store in
            DispatchQueue.global().async {
                let mainThreadStore = SubStore(dispatchFunction: { action in
                    DispatchQueue.main.sync {
                        store.dispatch(action)
                    }
                }, autoclosureState: store.state)
                
                execute(mainThreadStore)
            }
            
            return action
        }
    }
    
}
