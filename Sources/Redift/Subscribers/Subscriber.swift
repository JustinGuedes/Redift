//
//  Subscriber.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/21.
//

public protocol Subscriber {
    
    associatedtype State
    
    func newState(_ state: State)
    
}
