//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Tom Yu on 6/6/16.
//  Copyright © 2016 kangleyu. All rights reserved.
//

import Foundation

internal class CalculatorBrain { // internal means available in same module
    
    private var accumulator = 0.0;
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "√" : Operation.UnaryOperation(sqrt),
        "∛" : Operation.UnaryOperation(cbrt),
        "x2" : Operation.UnaryOperation({ $0 * $0 }),
        "x3" : Operation.UnaryOperation({ $0 * $0 * $0 }),
        "cos" : Operation.UnaryOperation(cos),
        "sin" : Operation.UnaryOperation(sin),
        "tan" : Operation.UnaryOperation(tan),
        "±" : Operation.UnaryOperation({ -$0 }), // closure inferred as single parameter
        "×" : Operation.BinaryOperation({ $0 * $1 }), // closure is used here
        "÷" : Operation.BinaryOperation({ $0 / $1 }),
        "+" : Operation.BinaryOperation({ $0 + $1 }),
        "−" : Operation.BinaryOperation({ $0 - $1 }),
        "=" : Operation.Equals
    ];
    private var pending: PendingBinaryOperationInfo?
    
    private var includeAccumulator: Bool = true;
    private var useConstant: Bool = false;
    private var lastConstant: String = "";
    internal var description = "";
    
    var isPartialResult: Bool {
        get {
            return pending != nil;
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = pending!.binaryFunction(pending!.firstOperand, accumulator);
            pending = nil;
        }
    }
    
    private func updateDescription(symbol: String, operation: Operation) {
        let displayOperand = useConstant ? lastConstant : String(accumulator);
        
        switch operation {
        case .Constant:
            lastConstant = symbol;
            useConstant = true;
            return;
        case .UnaryOperation:
            if (!isPartialResult) {
                description = "\(symbol)(\(description))";
            } else {
                description = description + "\(symbol)(\(displayOperand))";
                useConstant = false;
                includeAccumulator = false;
            }
        case .BinaryOperation:
            if (!isPartialResult && includeAccumulator) {
                description = description + "\(displayOperand)\(symbol)";
                useConstant = false;
            } else {
                if (includeAccumulator) {
                    description = description + "\(displayOperand)\(symbol)";
                    useConstant = false;
                } else {
                    description = description + "\(symbol)";
                    includeAccumulator = true;
                }
            }
        case .Equals:
            if (includeAccumulator) {
                description = description + "\(displayOperand)";
                useConstant = false;
                includeAccumulator = false;
            }
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = operand;
        if (!isPartialResult && !includeAccumulator)  {
            description = "";
            includeAccumulator = true;
        }
    }
    
    func performOperation(symbol: String) {
        if let operation = operations[symbol] {
            updateDescription(symbol, operation: operation);
            switch operation {
            case .Constant(let value):
                accumulator = value;
            case .UnaryOperation(let function):
                accumulator = function(accumulator);
            case.BinaryOperation(let function):
                executePendingBinaryOperation();
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: accumulator);
            case.Equals:
                executePendingBinaryOperation();
            }
            
        }
    }
    
    func clear() {
        accumulator = 0.0;
        pending = nil;
        description = "";
        includeAccumulator = true;
        lastConstant = "";
        useConstant = false;
    }
    
    var result: Double {
        get {
            return accumulator;
        }
    }
}
