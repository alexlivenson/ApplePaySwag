//
//  BuySwagVC+PKPaymentAuthorizationVCDelegate.swift
//  ApplePaySwag
//
//  Created by alex livenson on 12/28/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//
import PassKit

extension BuySwagViewController: PKPaymentAuthorizationViewControllerDelegate {
    // Handles user authorization to complete the purchase
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {
        PKPaymentAuthorizationStatus.Success
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
    
}
