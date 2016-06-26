//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Tom Yu on 6/6/16.
//  Copyright © 2016 kangleyu. All rights reserved.
//

import Foundation

internal enum Accumulator {
    case Number(Double)
    
    case Variable(String)
    
    var displayValue: String {
        switch self {
        case .Number(let number):
            return String(number);
        case .Variable(let variableName):
            return variableName;
        }
    }
}

internal class CalculatorBrain { // internal means available in same module
    typealias PropertyList = Any;
    
    private var internalProgram = [Any]();
    //private var accumulator = 0.0;
    private var accumulator = Accumulator.Number(0.0);
    
    private var operations: Dictionary<String, Operation> = [
        "π" : Operation.Constant(M_PI),
        "e" : Operation.Constant(M_E),
        "Rand": Operation.Random({ Double(arc4random()) / Double(UINT32_MAX) }),
        "√" : Operation.UnaryOperation(sqrt),
        "∛" : Operation.UnaryOperation(cbrt),
        "x\u{00B2}" : Operation.UnaryOperation({ $0 * $0 }),
        "x\u{00B3}" : Operation.UnaryOperation({ $0 * $0 * $0 }),
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
    private var variableValues: Dictionary<String, Double> = [:];
    
    private var pending: PendingBinaryOperationInfo?
    
    private var includeAccumulator: Bool = true;
    private var useConstant: Bool = false;
    private var lastConstant: String = "";
    internal var description = " ";
    
    var isPartialResult: Bool {
        get {
            return pending != nil;
        }
    }
    
    private func executePendingBinaryOperation() {
        if pending != nil {
            accumulator = .Number(pending!.binaryFunction(pending!.firstOperand, extractValue(accumulator)));
            pending = nil;
        }
    }
    
    private func updateDescription(symbol: String, operation: Operation) {
        let displayOperand = useConstant ? lastConstant : accumulator.displayValue;
        
        switch operation {
        case .Constant:
            lastConstant = symbol;
            useConstant = true;
            return;
        case .UnaryOperation:
            if (!isPartialResult && !includeAccumulator) {
                if (symbol == "x\u{00B2}" || symbol == "x\u{00B3}") {
                    description = "(\(description))\(symbol.substringFromIndex(symbol.startIndex.advancedBy(1)))";
                } else {
                    description = "\(symbol)(\(description))";
                }
            } else {
                if (symbol == "x\u{00B2}" || symbol == "x\u{00B3}") {
                    description = description + "(\(displayOperand))\(symbol.substringFromIndex(symbol.startIndex.advancedBy(1)))";
                } else {
                    description = description + "\(symbol)(\(displayOperand))";
                }
                
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
        case .Random:
            break;
        }
    }
    
    func setOperand(operand: Double) {
        accumulator = .Number(operand);
        internalProgram.append(Accumulator.Number(operand));
        if (!isPartialResult && !includeAccumulator)  {
            description = " ";
            includeAccumulator = true;
        }
    }
    
    // allow to set variable name for the calculation
    func setOperand(variableName: String) {
        accumulator = .Variable(variableName);
        internalProgram.append(Accumulator.Variable(variableName));
        variableValues[variableName] = 0.0;
    }
    
    func setVariableValue(variableName: String, value: Double) {
        variableValues[variableName] = value;
        //includeAccumulator = false;
    }
    
    func performOperation(symbol: String) {
        internalProgram.append(symbol);
        if let operation = operations[symbol] {
            updateDescription(symbol, operation: operation);
            switch operation {
            case .Constant(let value):
                accumulator = .Number(value);
            case .UnaryOperation(let function):
                accumulator = .Number(function(extractValue(accumulator)));
            case.BinaryOperation(let function):
                executePendingBinaryOperation();
                pending = PendingBinaryOperationInfo(binaryFunction: function, firstOperand: extractValue(accumulator));
            case.Equals:
                executePendingBinaryOperation();
            case .Random(let getRandom):
                accumulator = .Number(getRandom());
            }
            
        }
    }
    
    private func extractValue(accumulator: Accumulator) -> Double {
        switch accumulator {
        case .Number(let value):
            return value;
        case .Variable(let variableName):
            return variableValues[variableName] ?? 0.0;
        }
    }
    
    var program: PropertyList {
        get {
            return internalProgram;
        }
        set {
            clear();
            if let arrayOfOps = newValue as? [Any] {
                for op in arrayOfOps {
                    if let operand = op as? Accumulator {
                        setOperand(extractValue(operand));
                    }
                    else if let operation = op as? String {
                        performOperation(operation);
                    }
                }
            }
        }
    }
    
    func clear() {
        accumulator = .Number(0.0);
        pending = nil;
        description = " ";
        includeAccumulator = true;
        lastConstant = "";
        useConstant = false;
        internalProgram.removeAll();
    }
    
    var result: Double {
        get {
            return extractValue(accumulator);
        }
    }
}
