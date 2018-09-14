//
//  ViewController.swift
//  Paytm Demo
//
//  Created by NITV on 7/4/18.
//  Copyright © 2018 NITV. All rights reserved.
//

import UIKit
import JGProgressHUD


class ViewController: UIViewController {
    private let CheckSumVerifyURL = BASE_URL + "test/verifychecksum"
    private var hud: JGProgressHUD!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func startPayment(_ sender: Any) {
        let paytmInstance = PaytmManager.sharedInstance
        paytmInstance.createOrderWith(sender: self, amount: "100", customerID: "123456")
    }
    func showAlertView(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            //ref.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    func verifyChecksum(orderID: String){
        
        self.hud = ProgressHud.showNormalHud(view:self.view, message: "Payment verification")
        
        var orderDict = [String : Any]()
        orderDict["ORDERID"] = orderID;
        print(orderDict)
        
        postRequest(CheckSumVerifyURL, params: orderDict as [String : AnyObject]?,oauth: true, result: {
            (response: JSON?, error: NSError?, statuscode: Int) in
            self.hud.dismiss()
            guard error == nil else {
                print(error?.localizedDescription as Any)
                return
            }
            if response!["status"].stringValue == "fail" {
                printLog(log: response!["reason"].stringValue)
            } else {
                printLog(log: response!)
                if statuscode == 200
                {
                    
                    //self.showTransectionController(orderID: response!["ORDER_ID"].stringValue, checksumhash: response!["CHECKSUMHASH"].stringValue)
                    self.showAlertView(title: "SUCCESS", message: "Paytm payment sucess.")
                }
                else{
                   self.showAlertView(title: "Error", message: "Error on verifying payment")
                }
            }
        })
        
    }

}

extension ViewController: PaytmManagerDelegate {
    func didFailedTransaction(error: Error!) {
        print(error.localizedDescription)
    }
    
    func didFinishedResponse(data: JSON) {
        guard data != JSON.null else {
            showAlertView(title: "Error", message: "Transection failed due to some error if your amount will deducted, we will refund you in 7 working days")
            return
        }
        if data["STATUS"].stringValue == "TXN_SUCCESS" {
            print("Success: \n\(String(describing: data))")
            self.verifyChecksum(orderID: data["ORDERID"].stringValue)
            //showAlertView(title: "SUCCESS", message: data["TXNID"].stringValue)
            
        } else {
            showAlertView(title: "Error", message: "Transection Fail")
        }
    }
    
    func didCancelTrasaction() {
        showAlertView(title: "Error", message: "Transection cancel by user")
    }
    
    func errorMisssingParameter(error: Error!) {
        showAlertView(title: "Error", message: error.localizedDescription)
    }
}


