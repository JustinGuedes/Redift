//
//  Store.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

public class Store<State, Action> {
    
    let reducer: Reducer<State, Action>
    var subscribers: [AnySubscriber<State>]
    var state: State {
        didSet {
            subscribers.forEach {
                $0.newState(self.state)
            }
        }
    }
    
    private var dispatchFunction: ((Action) -> Void)!
    
    public init(reducer: Reducer<State, Action>, initialState: State) {
        self.reducer = reducer
        self.subscribers = []
        self.state = initialState
        self.dispatchFunction = self._dispatch
    }
    
    public init(reducer: Reducer<State, Action>, initialState: State, middlewares: [Middleware<State, Action>]) {
        self.reducer = reducer
        self.subscribers = []
        self.state = initialState
        self.dispatchFunction = middlewares.reversed().reduce(self._dispatch) { dispatch, middleware in
            let middlewareStore = SubStore(dispatchFunction: self.dispatch, autoclosureState: self.state)
            return middleware.execute(middlewareStore, dispatch)
        }
    }
    
    public func subscribe<S: SpecificSubscriber, SubState>(_ subscriber: S) where State == S.ParentState, SubState == S.State {
        cleanSubscribers()
        let anySubscriber = AnySubscriber(specific: subscriber)
        subscribers.append(anySubscriber)
        anySubscriber.newState(state)
    }
    
    public func subscribe<S: SpecificSubscriber, SubState>(_ subscriber: S) where State == S.ParentState, SubState == S.State, S: AnyObject {
        cleanSubscribers()
        if let _ = subscribers.first(where: { $0.isEqual(toSubscriber: subscriber) }) {
            return
        }
        
        let anySubscriber = AnySubscriber(specific: subscriber)
        subscribers.append(anySubscriber)
        anySubscriber.newState(state)
    }
    
    public func unsubscribe<S: SpecificSubscriber, SubState>(_ subscriber: S) where State == S.ParentState, SubState == S.State, S: AnyObject {
        guard let index = subscribers.index(where: { $0.isEqual(toSubscriber: subscriber) }) else { return }
        subscribers.remove(at: index)
    }
    
    public func dispatch(_ action: Action) {
        dispatchFunction(action)
    }
    
}

fileprivate extension Store {
    
    func _dispatch(_ action: Action) {
        reducer.reduce(&state, action)
    }
    
    func cleanSubscribers() {
        subscribers = subscribers.filter { $0.isValid }
    }
    
}
