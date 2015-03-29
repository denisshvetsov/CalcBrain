//
//  Result.swift
//  CalcBrain
//
//  Created by Denis Shvetsov on 29/03/15.
//  Copyright (c) 2015 Denis Shvetsov. All rights reserved.
//

import Foundation

/**
* A type representing a computation that has either failed or succeeded. Use 'map' to chain pure
* computations or 'flatMap' to chain failure-prone ones.
*/
enum Result<T>: Printable {
    case Success(Box<T>)
    case Failure(String)
    
    func map<P>(f: T -> P) -> Result<P> {
        switch self {
        case Success(let box):
            return .Success(Box(value: f(box.value)))
        case Failure(let err):
            return .Failure(err)
        }
    }
    
    func flatMap<P>(f: T -> Result<P>) -> Result<P> {
        switch self {
        case .Success(let box):
            return f(box.value)
        case .Failure(let err):
            return .Failure(err)
        }
    }
    
    var description:String {
        switch self {
        case .Success(let box):
            return "\(box.value)"
        case .Failure(let err):
            return "\(err)"
        }
    }
}

/**
* Sad type that needs to exist because we can't have non-fixed layout enums yet
*/
class Box<T> {
    let value: T
    init(value: T) {
        self.value = value
    }
}