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
    private var displayValue: Double? {
        get {
            if let value = Double(display.text!) {
                return Double(value)
            } else {
                return nil;
            }
        }
        set {
            display.text = String(newValue!);
        }
    }
    
    private func updateDetails() {
        let displayDetails = brain.description.isEmpty ?
            "" :
            (brain.isPartialResult ?
                brain.description + "..." :
                brain.description + "=");
        details.text = displayDetails;
    }
    
    // Outlets
    @IBOutlet private weak var display: UILabel!;
    
    @IBOutlet weak var details: UILabel!
    
    @IBOutlet weak var tripleOp: UIButton!
    
    @IBOutlet weak var squareOp: UIButton!
    
    // Actions
    @IBAction private func touchDigit(sender: UIButton) {
        if let digit = sender.currentTitle {
            if (userIsInTheMiddleOfTyping) {
                let textCurrentlyInDisplay = display.text!;
                // handle for the valid floating point
                if (digit == "." && textCurrentlyInDisplay.rangeOfString(".") != nil) {
                    return;
                }
                if (textCurrentlyInDisplay == "0") {
                    display.text = digit;
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
            if let operand = displayValue {
                brain.setOperand(operand);
            }
            userIsInTheMiddleOfTyping = false;
        }
        if let mathmaticalSymbol = sender.currentTitle {
            brain.performOperation(mathmaticalSymbol);
        }
        displayValue = brain.result;
        updateDetails();
    }
    
    @IBAction func backspace() {
        if (userIsInTheMiddleOfTyping) {
            let textCurrentlyInDisplay = display.text!;
            if (textCurrentlyInDisplay.characters.count == 1) {
                display.text = "0";
            } else if (textCurrentlyInDisplay.characters.count > 1) {
                let toIndex = textCurrentlyInDisplay.endIndex.advancedBy(-1);
                display.text = textCurrentlyInDisplay.substringToIndex(toIndex);
            }
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.clear();
        display.text = String("0");
        details.text = " ";
        userIsInTheMiddleOfTyping = false;
    }
    
    private var savedProgram: CalculatorBrain.PropertyList?;
    
    @IBAction func save() {
        savedProgram = brain.program;
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!;
            displayValue = brain.result;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad();
        squareOp.setTitle("x\u{00B2}", forState: UIControlState.Normal);
        tripleOp.setTitle("x\u{00B3}", forState: UIControlState.Normal);
    }
}

