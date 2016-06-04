//
//  ViewController.swift
//  Calculator
//
//  Created by Tom Yu on 6/4/16.
//  Copyright © 2016 kangleyu. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var userIsInTheMiddleOfTyping = false;

    @IBOutlet weak var display: UILabel!;
    
    @IBAction func touchDigit(sender: UIButton) {
        if let digit = sender.currentTitle {
            if (userIsInTheMiddleOfTyping) {
                let textCurrentlyInDisplay = display.text!;
                display.text = textCurrentlyInDisplay + digit;
            } else {
                userIsInTheMiddleOfTyping = true;
                display.text = digit;
            }
            
        }
        
    }
    
    @IBAction func performOperation(sender: UIButton) {
        if let mathmaticalSymbol = sender.currentTitle {
            userIsInTheMiddleOfTyping = false;
            if mathmaticalSymbol == "π" {
                display.text = String(M_PI);
            }
        }
    }
    
}

