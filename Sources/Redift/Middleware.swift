//
//  Middleware.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

import Prelude

public struct Middleware<State, Action> {
    
    let execute: (_ store: SubStore<State, Action>, _ nextDispatch: @escaping (Action) -> Void) -> ((Action) -> Void)
    
    public init(execute: @escaping (_ store: SubStore<State, Action>, _ nextDispatch: @escaping (Action) -> Void) -> ((Action) -> Void)) {
        self.execute = execute
    }
    
}

extension Middleware: Monoid {
    
    public static func <> (lhs: Middleware, rhs: Middleware) -> Middleware {
        return Middleware { store, nextDispatch in
            return { action in
                lhs.execute(store, nextDispatch)(action)
                rhs.execute(store, nextDispatch)(action)
            }
        }
    }
    
    public static var empty: Middleware<State, Action> {
        return Middleware { _, nextDispatch in
            return { action in
                nextDispatch(action)
            }
        }
    }
    
}

public extension Middleware {
    
    func lift<ParentState>(state lens: Lens<ParentState, State>) -> Middleware<ParentState, Action> {
        return Middleware<ParentState, Action> { store, nextDispatch in
            let childStore = SubStore<State, Action>(dispatchFunction: store.dispatch, autoclosureState: lens.get <*> store.state)
            return self.execute(childStore, nextDispatch)
        }
    }
    
    func lift<ParentState>(state keyPath: WritableKeyPath<ParentState, State>) -> Middleware<ParentState, Action> {
        return lift(state: Lens(keyPath))
    }
    
    func lift<ParentAction>(action prism: Prism<ParentAction, Action>) -> Middleware<State, ParentAction> {
        return Middleware<State, ParentAction> { store, nextDispatch in
            let childStore = SubStore<State, Action>(dispatchFunction: store.dispatch <<< prism.createFrom, autoclosureState: store.state)
            let childNextDispatch = nextDispatch <<< prism.createFrom
            
            return { action in
                guard let childAction = prism.tryGetFrom(action) else {
                    nextDispatch(action)
                    return
                }
                
                self.execute(childStore, childNextDispatch)(childAction)
            }
        }
    }
    
    func lift<ParentState, ParentAction>(state keyPath: WritableKeyPath<ParentState, State>, action prism: Prism<ParentAction, Action>) -> Middleware<ParentState, ParentAction> {
        return lift(state: keyPath).lift(action: prism)
    }
    
    func lift<ParentState, ParentAction>(state lens: Lens<ParentState, State>, action prism: Prism<ParentAction, Action>) -> Middleware<ParentState, ParentAction> {
        return lift(state: lens).lift(action: prism)
    }
    
}
