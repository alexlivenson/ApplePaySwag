//
//  BuySwagVC+PKPaymentAuthorizationVCDelegate.swift
//  ApplePaySwag
//
//  Created by alex livenson on 12/28/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//
import PassKit

let applicationJson = "application/json"

extension BuySwagViewController: PKPaymentAuthorizationViewControllerDelegate {
    
    // Handles user authorization to complete the purchase
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
        // 1
        let shippingAddress = self.createShippingAddressFromRef(payment.shippingMethod)
        // 2 - this key can be public -> Stripe has the secret key
        Stripe.setDefaultPublishableKey("<your-public-key>")
        
        // 3
        Stripe.createTokenWithPayment(payment, completion: {
            (token, error) -> Void in
            
            if error != nil {
                println(error)
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            
            // 4
            let shippingAddress = self.createShippingAddressFromRef(payment.shippingAddress)
            
            // 5
            let url = NSURL(string: "http://<your-ip-address>/pay")
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.setValue(applicationJson, forHTTPHeaderField: "Content-Ty[e")
            request.setValue(applicationJson, forHTTPHeaderField: "Accept")
            
            let body = ["stripeToken": token.tokenId,
                "amount": self.swag!.total().decimalNumberByMultiplyingBy(NSDecimalNumber(string: "100")),
                "description": self.swag!.title,
                "shipping": [
                    "city" : shippingAddress.City!,
                    "state": shippingAddress.State!,
                    "zip": shippingAddress.Zip!,
                    "firstName": shippingAddress.FirstName!,
                    "lastName": shippingAddress.LastName!]
            ]
            
            var error: NSError?
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(), error: &error)
            
            // 7
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                (response, data, error) -> Void in
                if error != nil {
                    completion(PKPaymentAuthorizationStatus.Failure)
                } else {
                    completion(PKPaymentAuthorizationStatus.Success)
                }
            })
        })
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // lets long running tasks comlpete due to address or shipping changes made on the apple pay sheet (i.e calcuate sales tax)
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didSelectShippingAddress address: ABRecord!, completion: ((status:PKPaymentAuthorizationStatus, shippindMethods:[AnyObject]!, summaryItems:[AnyObject]!) -> Void)!) {
        let shippingAddress = createShippingAddressFromRef(address)
        
        switch(shippingAddress.State, shippingAddress.City, shippingAddress.Zip) {
        case(.Some(let state), .Some(let city), .Some(let zip)):
            completion(status: PKPaymentAuthorizationStatus.Success, shippindMethods: nil, summaryItems: nil)
        default:
            completion(status: PKPaymentAuthorizationStatus.InvalidShippingPostalAddress, shippindMethods: nil, summaryItems: nil)
        }
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didSelectShippingMethod shippingMethod: PKShippingMethod!, completion: ((PKPaymentAuthorizationStatus, [AnyObject]!) -> Void)!) {
        // This works due to the method setUpShippingFieldsDependingOnType which maps values from PKShippingMethod to ShippingMethod
        let swagShippingMethod = ShippingMethod.ShippingMethodOptions.filter { (method) in
            method.title == shippingMethod.identifier
            }.first!
        
        swag.swagType = SwagType.Delivered(method: swagShippingMethod)
        completion(PKPaymentAuthorizationStatus.Success, calculateSummaryItemsFromSwag(swag))
    }
    
    // TODO: Investigate AddressBook
    // Lots of intricit detials in this method with ABRecord
    // NOTE: Method is public so to be accessible to extensions
    func createShippingAddressFromRef(address: ABRecord!) -> Address {
        var shippingAddress: Address = Address()
        shippingAddress.FirstName = ABRecordCopyValue(address, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
        shippingAddress.LastName = ABRecordCopyValue(address, kABPersonLastNameProperty)?.takeRetainedValue() as? String
        
        let addressProperty: ABMultiValueRef = ABRecordCopyValue(address, kABPersonAddressProperty).takeUnretainedValue() as ABMultiValueRef
        
        if let dict:NSDictionary = ABMultiValueCopyValueAtIndex(addressProperty, 0).takeUnretainedValue() as? NSDictionary {
            shippingAddress.Street = dict[String(kABPersonAddressStreetKey)] as? String
            shippingAddress.City = dict[String(kABPersonAddressCityKey)] as? String
            shippingAddress.State = dict[String(kABPersonAddressStateKey)] as? String
            shippingAddress.Zip = dict[String(kABPersonAddressZIPKey)] as? String
        }
        
        return shippingAddress
    }
}
