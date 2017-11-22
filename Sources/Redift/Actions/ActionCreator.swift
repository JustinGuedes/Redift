//
//  ActionCreator.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

import Foundation
import Prelude

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

public extension Store {
    
    func dispatchActionCreator(_ actionCreator: ActionCreator<State, Action>) {
        let store = SubStore(dispatchFunction: dispatch, autoclosureState: self.state)
        if let action = actionCreator.execute(store) {
            dispatch(action)
        }
    }
    
}

public extension SpecificStore {
    
    func dispatch(_ actionCreator: ActionCreator<State, Action>) {
        let parentActionCreator = ActionCreator<ParentState, ParentAction> { parentStore in
            let childStore = SubStore(dispatchFunction: parentStore.dispatch <<< self.prism.createFrom, autoclosureState: self.lens.get(parentStore.state))
            guard let childAction = actionCreator.execute(childStore) else {
                return .none
            }
            
            return self.prism.createFrom(childAction)
        }
        
        parentStore.dispatchActionCreator(parentActionCreator)
    }
    
}
