//
//  PendingBinaryOperationInfo.swift
//  Calculator
//
//  Created by Tom Yu on 6/6/16.
//  Copyright © 2016 kangleyu. All rights reserved.
//

import Foundation

// struct passed as copy (value type)
struct PendingBinaryOperationInfo {
    // binary function
    var binaryFunction: (Double, Double) -> Double
    
    // first oprand
    var firstOperand: Double
}