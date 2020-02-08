//
//  MulticastDelegate.swift
//  Violations
//
//  Created by Artyom Zagoskin on 08.02.2020.
//  Copyright © 2020 Tyoma Zagoskin. All rights reserved.
//

import Foundation


// MARK: - Property Wrapper

@propertyWrapper
struct Multicast<T> {
    
    private var _wrappedValue: MulticastDelegate<T> = .init()
    var projectedValue: MulticastDelegate<T> { _wrappedValue }

    var wrappedValue: T {
        get { fatalError("Should not be accessed directly") }
        set { _wrappedValue.add(newValue) }
    }
    
}


// MARK: - Base

final class MulticastDelegate<T> {
    
    private let delegates: NSHashTable<AnyObject> = NSHashTable.weakObjects()
    
}


// MARK: - Public API

extension MulticastDelegate {
    
    func add(_ delegate: T) {
        delegates.add(delegate as AnyObject)
    }
    
    func remove(_ delegateToRemove: T) {
        for delegate in delegates.allObjects.reversed() {
            if delegate === delegateToRemove as AnyObject {
                delegates.remove(delegate)
            }
        }
    }
    
    func invoke(_ invocation: Handler<T>) {
        for delegate in delegates.allObjects.reversed() {
            invocation(delegate as! T)
        }
    }

}

