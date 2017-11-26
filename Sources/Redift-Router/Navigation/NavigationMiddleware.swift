//
//  NavigationMiddleware.swift
//  Redift
//
//  Created by Justin Guedes on 2017/11/22.
//

import Redift

func navigationMiddleware<T>(_ router: Router<T>) -> Middleware<NavigationState, NavigationAction> {
    return Middleware<NavigationState, NavigationAction> { store, nextDispatch in
        return { action in
            nextDispatch(action)
        }
    }
}
