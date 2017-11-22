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
    
    var stateLens: Lens<ParentState, State> { get }
    var actionPrism: Prism<ParentAction, Action> { get }
    
}

public extension SpecificSubscriber where ParentState == State {
    
    var stateLens: Lens<ParentState, State> {
        return Lens.identity
    }
    
}

public extension SpecificSubscriber where ParentAction == Action {
    
    var actionPrism: Prism<ParentAction, Action> {
        return Prism.identity
    }
    
}

public extension SpecificSubscriber where Action: Redift.Action {

    typealias ParentAction = Redift.Action

}

public extension SpecificSubscriber where ParentAction == Redift.Action, Action: Redift.Action {
    
    var actionType: Prism<ParentAction, Action> {
        return Prism.identity
    }
    
}
