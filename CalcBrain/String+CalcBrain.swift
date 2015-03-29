//
//  String+CalcBrain.swift
//  CalcBrain
//
//  Created by Denis Shvetsov on 29/03/15.
//  Copyright (c) 2015 Denis Shvetsov. All rights reserved.
//

import Foundation

extension String {
    
    func stringFromIndex(index: Int) -> String? {
        if 0..<countElements(self) ~= index {
            return String(self[indexFromInt(index)])
        }
        return nil
    }
    
    func indexFromInt(int: Int) -> String.Index {
        return advance(self.startIndex, int)
    }
    
    var isSeparator: Bool {
        if countElements(self) == 1 && " ()+-*/".rangeOfString(self) != nil {
            return true
        }
        return false
    }
    
    var doubleValue: Double? { // don't handle "," as decimal point
        let formatter = NSNumberFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_US")
        if let number = formatter.numberFromString(self) {
            return number.doubleValue
        }
        return nil
    }
    
}