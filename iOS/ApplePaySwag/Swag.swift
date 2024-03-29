//
//  Swag.swift
//  ApplePaySwag
//
//  Created by Erik.Kerber on 10/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit

enum SwagType {
    case Delivered(method: ShippingMethod)
    case Electronic
    
}

struct ShippingMethod {
    let price: NSDecimalNumber
    let title: String
    let description: String
    
    init(price: NSDecimalNumber, title: String, description: String) {
        self.price = price
        self.title = title
        self.description = description
    }
    
    static let ShippingMethodOptions = [
        ShippingMethod(price: NSDecimalNumber(string: "5.00"), title: "Carrier Pigeon", description: "You may get it someday"),
        ShippingMethod(price: NSDecimalNumber(string: "100.0"), title: "Racecar", description: "Vrrrom! Get it soon"),
        ShippingMethod(price: NSDecimalNumber(string: "90000.00"), title: "Rocket Ship", description: "Look outside")
    ]
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
    let shippingPrice: NSDecimalNumber = NSDecimalNumber(string: "5.0")
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
    
    func total() -> NSDecimalNumber {
        switch(swagType) {
        case .Delivered(let swagType):
            return price.decimalNumberByAdding(swagType.method.price)
        case .Electronic:
            return price
        }
    }
}
