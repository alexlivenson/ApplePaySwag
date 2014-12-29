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
    
}
