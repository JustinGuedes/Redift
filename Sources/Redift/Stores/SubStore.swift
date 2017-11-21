//
//  SubStore.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

public struct SubStore<State, Action> {
    
    private let dispatchFunction: (Action) -> Void
    private let stateFunction: () -> State
    
    init(dispatchFunction: @escaping (Action) -> Void, stateFunction: @escaping () -> State) {
        self.dispatchFunction = dispatchFunction
        self.stateFunction = stateFunction
    }
    
    init(dispatchFunction: @escaping (Action) -> Void, autoclosureState: @autoclosure @escaping () -> State) {
        self.dispatchFunction = dispatchFunction
        self.stateFunction = autoclosureState
    }
    
}

public extension SubStore {
    
    var state: State {
        return stateFunction()
    }
    
    func dispatch(_ action: Action) {
        dispatchFunction(action)
    }
    
}
