//
//  PaytmHelper.swift
//  Paytm Demo
//
//  Created by NITV on 7/4/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import Foundation
import UIKit
import JGProgressHUD
import Alamofire

protocol PaytmManagerDelegate {
    func didFinishedResponse(data: JSON)
    func didCancelTrasaction()
    func didFailedTransaction(error: Error!)
    func errorMisssingParameter(error: Error!)
    
}

public let BASE_URL = "http://wtvgo.nitvsoftware.com/api/"
class PaytmManager: NSObject{
    
    var delegate : PaytmManagerDelegate?
    static var sharedInstance  = PaytmManager()
    private let CheckSumGenerationURL = BASE_URL + "test/paytmchecksum"
    private let CheckSumVerifyURL = BASE_URL + "test/verifychecksum"
    var controller : UIViewController!
    var merchant:PGMerchantConfiguration!
    var CHECKSUMHASH = ""
    var amount  = "0"
    var randomOrderID = ""
    var hud : JGProgressHUD!
    private let MID = "your MID"

    override init() {
        super.init()
    }

    func randomString(length: Int) -> String {
        
        let letters : NSString = MID as NSString
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    func createOrderWith(sender: UIViewController, amount: String , customerID : String){
        self.randomOrderID = self.randomString(length : 20)
        self.controller = sender
        delegate  = sender as? PaytmManagerDelegate
        self.generateChecksum()
        //self.verifyChecksum(orderID:  "123456789")
    }
    
    private func generateChecksum(){
        
        self.hud = ProgressHud.showNormalHud(view:controller.view, message: "Paytm initializing")
        var orderDict = [String : Any]()
        orderDict["MID"] = MID;//paste here your merchant id   //mandatory
        orderDict["CHANNEL_ID"] = "WEB"; // paste here channel id                       // mandatory
        orderDict["INDUSTRY_TYPE_ID"] = "Retail";//paste industry type              //mandatory
        orderDict["WEBSITE"] = "APPSTAGING";// paste website                            //mandatory
        //Order configuration in the order object
        orderDict["TXN_AMOUNT"] = "100"; // amount to charge                      // mandatory
        orderDict["ORDER_ID"] = randomOrderID;//change order id every time on new transaction
        orderDict["REQUEST_TYPE"] = "DEFAULT";// remain same
        orderDict["CUST_ID"] = "123456"; // change acc. to your database user/customers
        // orderDict["MOBILE_NO"] = "8050501556";// optional
        //orderDict["EMAIL"] = "iosapptestnepal@gmail.com"; //optional
        orderDict["CALLBACK_URL"] =  "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=\(randomOrderID)" //(staging)
        
            print(orderDict)
            postRequest(CheckSumGenerationURL, params: orderDict as [String : AnyObject]?,oauth: true, result: {
                (response: JSON?, error: NSError?, statuscode: Int) in
                self.hud.dismiss()
                guard error == nil else {
                    print(error?.localizedDescription ?? "error")
                    return
                }
                if response!["status"].stringValue == "fail" {
                    printLog(log: response!["reason"].stringValue)
                } else {
                    printLog(log: response!)
                    if statuscode == 200
                    {
                        self.showTransectionController(checksumhash: response!["CHECKSUMHASH"].stringValue, orderID: response!["ORDER_ID"].stringValue)
                    }
                }
            })
            
        }
        

    
    private func showTransectionController(checksumhash: String, orderID: String){
        
        var paramDict = [AnyHashable:Any]()
        paramDict["MID"] = MID
        paramDict["CHANNEL_ID"] = "WEB"
        paramDict["INDUSTRY_TYPE_ID"] = "Retail"
        paramDict["WEBSITE"] = "APPSTAGING"
        paramDict["CALLBACK_URL"] = "https://securegw-stage.paytm.in/theia/paytmCallback?ORDER_ID=\(orderID)"
        paramDict["TXN_AMOUNT"] = "100"
        paramDict["ORDER_ID"] = orderID
        //paramDict["MOBILE_NO"] = mobile_no
        //paramDict["EMAIL"] = email
        paramDict["CHECKSUMHASH"] = checksumhash
        paramDict["CUST_ID"] = "123456"
        
        let order = PGOrder(params: paramDict )
        
        let txnController = PGTransactionViewController(transactionFor: order)
        txnController?.serverType = eServerTypeStaging
        txnController?.merchant = PGMerchantConfiguration.default()
        txnController?.delegate = self
        controller.show(txnController!, sender: nil)
    }

}

extension PaytmManager : PGTransactionDelegate{
    func didFinishedResponse(_ controller: PGTransactionViewController!, response responseString: String!) {
        let data = responseString.data(using: .utf8)!
        let obj = JSON(data: data)
        if obj["STATUS"].stringValue != "TXN_SUCCESS" {
            controller.navigationController?.popViewController(animated: true)
        }
        else if obj["STATUS"].stringValue == "TXN_SUCCESS" {
            controller.navigationController?.popViewController(animated: true)
        }
        delegate?.didFinishedResponse(data: obj)
    }
    
    func didCancelTrasaction(_ controller: PGTransactionViewController!) {
        controller.navigationController?.popViewController(animated: true)
        delegate?.didCancelTrasaction()
    }
    
    func errorMisssingParameter(_ controller: PGTransactionViewController!, error: Error!) {
        print(error.localizedDescription)
        controller.navigationController?.popViewController(animated: true)
        delegate?.errorMisssingParameter(error: error)
    }
    
}

