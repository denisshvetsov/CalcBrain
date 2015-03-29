//
//  Stack.swift
//  CalcBrain
//
//  Created by Denis Shvetsov on 29/03/15.
//  Copyright (c) 2015 Denis Shvetsov. All rights reserved.
//

import Foundation

struct Stack<T>: Printable {
    
    private var data = [T]()
    
    mutating func pop() -> T {
        return data.removeLast()
    }
    
    mutating func push(t: T) {
        data.append(t)
    }
    
    var isEmpty: Bool {
        return data.isEmpty
    }
    
    var last: T? {
        return data.last
    }
    
    var size: Int {
        return data.count
    }
    
    var description: String {
        return "\(data)"
    }
}
