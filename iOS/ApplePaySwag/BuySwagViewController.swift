//
//  DetailViewController.swift
//  ApplePaySwag
//
//  Created by Erik.Kerber on 10/17/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit
import PassKit

class BuySwagViewController: UIViewController {
    
    @IBOutlet weak var swagPriceLabel: UILabel!
    @IBOutlet weak var swagTitleLabel: UILabel!
    @IBOutlet weak var swagImage: UIImageView!
    @IBOutlet weak var applePayButton: UIButton!
    
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    // Where is the appropriate place to store this?
    let ApplePaySwagMerchantID = "merchant.com.livenson.ApplePaySwag"
    
    var swag: Swag! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        
        if (!self.isViewLoaded()) {
            return
        }
        
        self.title = swag.title
        self.swagPriceLabel.text = "$" + swag.priceString
        self.swagImage.image = swag.image
        self.swagTitleLabel.text = swag.description
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
        self.configureView()
    }
    
    @IBAction func purchase(sender: UIButton) {
        // TODO: - Fill in implementation
        // represent a single apple pay payment
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePaySwagMerchantID // used to decrypt cryptogram in backend
        request.supportedNetworks = SupportedPaymentNetworks // which cards show up in apple pay sheet
        request.merchantCapabilities = PKMerchantCapability.Capability3DS // security (3DS is most popular)
        request.countryCode = "US" // currently only one available
        request.currencyCode = "USD"
        setUpShippingFieldsDependingOnType(request)
        
        // The amount
        request.paymentSummaryItems = calculateSummaryItemsFromSwag(swag)
        
        #if DEBUG
            let applePayController = STPTestPaymentAuthorizationViewController(paymentRequest: request)
            applePayController.delegate = self
        #else
            let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
            applePayController.delegate = self
        #endif
        
        self.presentViewController(applePayController, animated: true, completion: nil)
    }
    
    func setUpShippingFieldsDependingOnType(request:PKPaymentRequest) {
        
        // This will create options in the apple pay sheet that will let you choose shipping
        // As well as give the shipping info depending on type
        switch (swag.swagType) {
        case SwagType.Delivered(let type):
            var shippingMethods = [PKShippingMethod]()
            
            for shippingMethod in ShippingMethod.ShippingMethodOptions {
                let method = PKShippingMethod(label: shippingMethod.title, amount: shippingMethod.price)
                method.identifier = shippingMethod.title
                method.detail = shippingMethod.description
                shippingMethods.append(method)
            }
            request.shippingMethods = shippingMethods
            request.requiredShippingAddressFields = PKAddressField.PostalAddress | PKAddressField.Phone
        case SwagType.Electronic:
            request.requiredShippingAddressFields = PKAddressField.Email
        }
    }
    
    func calculateSummaryItemsFromSwag(swag: Swag) -> [PKPaymentSummaryItem]{
        var summaryItems = [PKPaymentSummaryItem]()
        summaryItems.append(PKPaymentSummaryItem(label: swag.title, amount: swag.price))
        
        switch (swag.swagType) {
        case .Delivered(let swagType):
            summaryItems.append(PKPaymentSummaryItem(label: "Shipping", amount: swagType.method.price))
        case .Electronic:
            break
        }
        
        summaryItems.append(PKPaymentSummaryItem(label: "Razeware", amount: swag.total()))
        return summaryItems
    }
}

