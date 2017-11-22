//
//  SpecificStore.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

import Prelude

public class SpecificStore<ParentState, State, ParentAction, Action> {
    
    let parentStore: Store<ParentState, ParentAction>
    let lens: Lens<ParentState, State>
    let prism: Prism<ParentAction, Action>
    
    init(lens: Lens<ParentState, State>, prism: Prism<ParentAction, Action>, parentStore: Store<ParentState, ParentAction>) {
        self.lens = lens
        self.prism = prism
        self.parentStore = parentStore
    }
    
    public func subscribe<S: SpecificSubscriber>(_ subscriber: S) where ParentState == S.ParentState, State == S.State {
        parentStore.subscribe(subscriber)
    }
    
    public func subscribe<S: SpecificSubscriber>(_ subscriber: S) where ParentState == S.ParentState, State == S.State, S: AnyObject {
        parentStore.subscribe(subscriber)
    }
    
    public func unsubscribe<S: SpecificSubscriber>(_ subscriber: S) where ParentState == S.ParentState, State == S.State, S: AnyObject {
        parentStore.unsubscribe(subscriber)
    }
    
    public func dispatch(_ action: Action) {
        parentStore.dispatch(prism.createFrom(action))
    }
    
}
