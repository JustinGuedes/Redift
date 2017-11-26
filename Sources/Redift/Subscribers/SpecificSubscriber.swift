//
//  SpecificSubscriber.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

import Prelude

public protocol SpecificSubscriber: Subscriber {
    
    associatedtype ParentState
    associatedtype ParentAction
    associatedtype Action
    
    var stateType: Lens<ParentState, State> { get }
    var actionType: Prism<ParentAction, Action> { get }
    
}

public extension SpecificSubscriber where ParentState == State {

    var stateType: Lens<ParentState, State> {
        return Lens.identity
    }

}

public extension SpecificSubscriber where ParentAction == Action {

    var actionType: Prism<ParentAction, Action> {
        return Prism.identity
    }

}

public extension SpecificSubscriber where ParentAction == Redift.Action, Action: Redift.Action {

    var actionType: Prism<ParentAction, Action> {
        return Prism.identity
    }

}

