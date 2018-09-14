//
//  ProgressHud.swift
//  WTV_GO
//
//  Created by NITV Developer on 3/10/17.
//  Copyright © 2017 nitv. All rights reserved.
//

import Foundation
import JGProgressHUD
import UIKit


class ProgressHud {
    
    
    class func showNormalHud(view:UIView,message:String) -> JGProgressHUD {
        
        let hud = JGProgressHUD(style: JGProgressHUDStyle.dark)
        
        hud.textLabel.text=message
        hud.show(in: view)
        
        
        return hud
        
    }
    class func showNormalHudWithStyleLight(view:UIView) -> JGProgressHUD {
        
        let hud = JGProgressHUD(style: JGProgressHUDStyle.light)
        hud.show(in: view)
        
        return hud
        
    }
    
    
    
    class func showSuccessHud(view:UIView,message:String) -> JGProgressHUD {
        
        let hud = JGProgressHUD(style: JGProgressHUDStyle.dark)
        
        hud.textLabel.text=message
        
        hud.indicatorView = JGProgressHUDSuccessIndicatorView()
        hud.square = true
        hud.show(in: view)
        
        
        
        return hud
        
    }
    
    
    
    class func showErrorHud(view:UIView,message:String) -> JGProgressHUD {
        
        let hud = JGProgressHUD(style: JGProgressHUDStyle.dark)
        
        hud.textLabel.text=message
        
        hud.indicatorView = JGProgressHUDErrorIndicatorView()
        hud.square = true
        hud.show(in: view)
        
        hud.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
        UIView.animate(withDuration: 1.0, animations: {
            
            hud.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            
        }, completion: { (true) in
            
            hud.dismiss(afterDelay: 1.0)
            
            
            
            
        })
        
        
        
        return hud
        
    }
    
}
