//
//  SpecificStore.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

import Prelude

public class SpecificStore<ParentState, State, ParentAction, Action> {
    
    private let parentStore: Store<ParentState, ParentAction>
    private let lens: Lens<ParentState, State>
    private let prism: Prism<ParentAction, Action>
    
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
    
    public func dispatch(_ actionCreator: ActionCreator<State, Action>) {
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
