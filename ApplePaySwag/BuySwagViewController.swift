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
        request.paymentSummaryItems = [
            PKPaymentSummaryItem(label: swag.title, amount: swag.price),
            PKPaymentSummaryItem(label: "Razeware", amount: swag.price)
        ]
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController.delegate = self
        self.presentViewController(applePayController, animated: true, completion: nil)
    }
    
    private func setUpShippingFieldsDependingOnType(request:PKPaymentRequest) {
//        request.requiredShippingAddressFields = PKAddressField.All
        switch (swag.swagType) {
        case SwagType.Delivered:
            request.requiredShippingAddressFields = PKAddressField.PostalAddress | PKAddressField.Phone
        case SwagType.Electronic:
            request.requiredShippingAddressFields = PKAddressField.Email
        }
    }
    
    
    
}

