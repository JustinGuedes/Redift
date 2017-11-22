//
//  NavigationMiddleware.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/22.
//

let navigationMiddleware = Middleware<NavigationState, NavigationAction> { store, nextDispatch in
    return { action in
        nextDispatch(action)
    }
}
