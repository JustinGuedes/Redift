//
//  Navigation.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/22.
//

import Prelude

public protocol HasNavigationState {
    
    static var navigationLens: Lens<Self, NavigationState> { get }
    
}

public protocol HasNavigationAction {
    
    static var navigationPrism: Prism<Self, NavigationAction> { get }
    
}

public extension Store where State: HasNavigationState, Action: HasNavigationAction {
    
    convenience init(withNavigation reducer: Reducer<State, Action>, initialState: State, middlewares: [Middleware<State, Action>]) {
        let newReducer = reducer <> navigationReducer.lift(state: State.navigationLens,
                                                           action: Action.navigationPrism)
        let newMiddlewares = middlewares + [navigationMiddleware.lift(state: State.navigationLens,
                                                                      action: Action.navigationPrism)]
        self.init(reducer: newReducer, initialState: initialState, middlewares: newMiddlewares)
    }
    
    func dispatchNavigation(_ action: NavigationAction) {
        dispatch(Action.navigationPrism.createFrom(action))
    }
    
}

public extension SpecificStore where ParentState: HasNavigationState, ParentAction: HasNavigationAction {
    
    func dispatch(_ navigation: NavigationAction) {
        parentStore.dispatchNavigation(navigation)
    }
    
}

public extension SubStore where State: HasNavigationState, Action: HasNavigationAction {
    
    func dispatch(_ navigation: NavigationAction) {
        dispatch(Action.navigationPrism.createFrom(navigation))
    }
    
}
