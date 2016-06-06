//
//  Operation.swift
//  Calculator
//
//  Created by Tom Yu on 6/6/16.
//  Copyright © 2016 kangleyu. All rights reserved.
//

import Foundation

// enum is like struct, which was passed by value
enum Operation {
    // single constant value. (Double as an associate value)
    case Constant(Double)
    
    // a unary operation like : √
    case UnaryOperation((Double) -> Double)
    
    // a binaray operation like : + - etc.
    case BinaryOperation((Double, Double) -> Double)
    
    // a special operation =
    case Equals
}