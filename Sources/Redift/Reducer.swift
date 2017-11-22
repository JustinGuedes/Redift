//
//  Reducer.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

import Prelude

public struct Reducer<State, Action> {
    
    let reduce: (inout State, Action) -> Void
    
    public init(reduce: @escaping (inout State, Action) -> Void) {
        self.reduce = reduce
    }
    
}

extension Reducer: Monoid {
    
    public static func <> (lhs: Reducer, rhs: Reducer) -> Reducer {
        return Reducer { state, action in
            lhs.reduce(&state, action)
            rhs.reduce(&state, action)
        }
    }
    
    public static var empty: Reducer<State, Action> {
        return Reducer { _, _ in }
    }
    
}

public extension Reducer {
    
    func lift<ParentState>(state lens: Lens<ParentState, State>) -> Reducer<ParentState, Action> {
        return Reducer<ParentState, Action> { parentState, action in
            var childState = lens.get(parentState)
            self.reduce(&childState, action)
            lens.mutatingSet(&parentState, childState)
        }
    }
    
    func lift<ParentState>(state keyPath: WritableKeyPath<ParentState, State>) -> Reducer<ParentState, Action> {
        return lift(state: Lens(keyPath))
    }
    
    func lift<ParentAction>(action prism: Prism<ParentAction, Action>) -> Reducer<State, ParentAction> {
        return Reducer<State, ParentAction> { state, parentAction in
            guard let childAction = prism.tryGetFrom(parentAction) else { return }
            self.reduce(&state, childAction)
        }
    }
    
    func lift<ParentState, ParentAction>(state keyPath: WritableKeyPath<ParentState, State>, action prism: Prism<ParentAction, Action>) -> Reducer<ParentState, ParentAction> {
        return lift(state: keyPath).lift(action: prism)
    }
    
    func lift<ParentState, ParentAction>(state lens: Lens<ParentState, State>, action prism: Prism<ParentAction, Action>) -> Reducer<ParentState, ParentAction> {
        return lift(state: lens).lift(action: prism)
    }
    
}
