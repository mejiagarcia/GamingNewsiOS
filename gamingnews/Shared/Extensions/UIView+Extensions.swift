//
//  UIView+Extensions.swift
//  gamingnews
//
//  Created by Carlos Mejia on 3/14/19.
//  Copyright © 2019 Carlos Mejia. All rights reserved.
//

import UIKit

extension UIView {
    func fadeTransition(_ duration: CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
    func addShadow(cornerRadius: CGFloat = 12,
                   shadowColor: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5),
                   shadowOffset: CGSize = CGSize(width: 0.1, height: 0.1),
                   shadowOpacity: Float = 0.5,
                   shadowRadius: CGFloat = 2) {
        
        layer.cornerRadius = cornerRadius
        layer.shadowColor = shadowColor.cgColor
        
        layer.masksToBounds = false
        clipsToBounds = false
        
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.shadowRadius = shadowRadius
    }
}
