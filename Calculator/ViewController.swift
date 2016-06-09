//
//  ViewController.swift
//  Calculator
//
//  Created by Tom Yu on 6/4/16.
//  Copyright © 2016 kangleyu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Stored Property
    private var userIsInTheMiddleOfTyping = false;
    private var brain = CalculatorBrain();
    
    // Computed Property
    private var displayValue: Double {
        get {
            if let value = Double(display.text!) {
                return Double(value)
            } else {
                return 0.0;
            }
        }
        set {
            display.text = String(newValue);
        }
    }
    
    // Outlets
    @IBOutlet private weak var display: UILabel!;
    
    
    // Actions
    @IBAction private func touchDigit(sender: UIButton) {
        if let digit = sender.currentTitle {
            if (userIsInTheMiddleOfTyping) {
                let textCurrentlyInDisplay = display.text!;
                // handle for the valid floating point
                if (digit == "." && textCurrentlyInDisplay.rangeOfString(".") != nil) {
                    return;
                }
                display.text = textCurrentlyInDisplay + digit;
            } else {
                userIsInTheMiddleOfTyping = true;
                display.text = digit;
            }
        }
    }
    
    @IBAction private func performOperation(sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(displayValue);
            userIsInTheMiddleOfTyping = false;
        }
        if let mathmaticalSymbol = sender.currentTitle {
            brain.performOperation(mathmaticalSymbol);
        }
        displayValue = brain.result;
    }
    
}

