//
//  Swag.swift
//  ApplePaySwag
//
//  Created by Erik.Kerber on 10/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

enum SwagType {
    case Delivered
    case Electronic
    
}

func ==(lhs: SwagType, rhs: SwagType) -> Bool {
    switch(lhs, rhs) {
    case (.Delivered(let lhsVal), .Delivered(let rhsVal)):
        return true
    case (.Electronic, .Electronic):
        return true
    default: return false
    }
}

struct Swag {
    let image: UIImage?
    let title: String
    let price: NSDecimalNumber
    let description: String
    var swagType: SwagType
    
    init(image: UIImage?, title: String, price: NSDecimalNumber, type: SwagType, description: String) {
        self.image = image
        self.title = title
        self.price = price
        self.swagType = type
        self.description = description
    }
    
    var priceString: NSString {
        let dollarFormatter: NSNumberFormatter = NSNumberFormatter()
        dollarFormatter.minimumFractionDigits = 2;
        dollarFormatter.maximumFractionDigits = 2;
        return dollarFormatter.stringFromNumber(price)!
    }
}
