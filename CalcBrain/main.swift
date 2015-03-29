//
//  main.swift
//  CalcBrain
//
//  Created by Denis Shvetsov on 29/03/15.
//  Copyright (c) 2015 Denis Shvetsov. All rights reserved.
//

import Foundation

let calc = CalcBrain()

// example
let expression = "11 + (exp(2.010635 + sin(PI/2) * 3) + 50) / 2"
println("\(expression) = " + calc.calculate(expression))

