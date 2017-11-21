//
//  AnySubscriber.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

class AnySubscriber<State> {
    
    private(set) var isValid: Bool = true
    private let _state: (State) -> Any?
    private var _newState: (Any?, inout Bool) -> Void
    private weak var _reference: AnyObject?
    
    init(_state: @escaping (State) -> Any?, _newState: @escaping (Any?, inout Bool) -> Void, _reference: AnyObject? = .none) {
        self._state = _state
        self._newState = _newState
        self._reference = _reference
    }
    
    func newState(_ state: State) {
        _newState(_state(state), &isValid)
    }
    
    func isEqual(toSubscriber subscriber: AnyObject) -> Bool {
        return _reference === subscriber
    }
    
}

// MARK: - Subscriber
extension AnySubscriber {
    
    convenience init<S: Subscriber>(_ subscriber: S) where S.State == State {
        self.init(_state: { $0 },
                  _newState: AnySubscriber.update(subscriber: subscriber))
    }
    
    convenience init<S: Subscriber>(_ subscriber: S) where S.State == State, S: AnyObject {
        self.init(_state: { $0 },
                  _newState: AnySubscriber.update(subscriber: subscriber),
                  _reference: subscriber)
    }
    
}

// MARK: - SpecificSubscriber
extension AnySubscriber {
    
    convenience init<S: SpecificSubscriber>(specific subscriber: S) where S.ParentState == State {
        self.init(_state: AnySubscriber.getState(fromSubscriber: subscriber),
                  _newState: AnySubscriber.update(subscriber: subscriber))
    }
    
    convenience init<S: SpecificSubscriber>(specific subscriber: S) where S.ParentState == State, S: AnyObject {
        self.init(_state: AnySubscriber.getState(fromSubscriber: subscriber),
                  _newState: AnySubscriber.update(subscriber: subscriber),
                  _reference: subscriber)
    }
    
    private static func getState<S: SpecificSubscriber, State>(fromSubscriber subscriber: S) -> (State) -> Any? where State == S.ParentState {
        return { state in
            subscriber.stateLens.get(state)
        }
    }
    
    private static func getState<S: SpecificSubscriber, State>(fromSubscriber subscriber: S) -> (State) -> Any? where State == S.ParentState, S: AnyObject {
        weak var subscriber = subscriber
        return { state in
            subscriber?.stateLens.get(state)
        }
    }
    
}

fileprivate extension AnySubscriber {
    
    static func update<S: Subscriber, State>(subscriber: S) -> (Any?, inout Bool) -> Void where State == S.State {
        return { state, isValid in
            guard let state = state as? State else {
                isValid = false
                return
            }
            
            subscriber.newState(state)
        }
    }
    
    static func update<S: Subscriber, State>(subscriber: S) -> (Any?, inout Bool) -> Void where State == S.State, S: AnyObject {
        weak var subscriber = subscriber
        return { state, isValid in
            guard let state = state as? State else {
                isValid = false
                return
            }
            
            subscriber?.newState(state)
        }
    }
    
}
