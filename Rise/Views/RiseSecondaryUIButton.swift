//
//  RiseSecondaryUIButton.swift
//  Rise
//
//  Created by Domonique Dixon on 11/5/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import ChameleonFramework

class RiseSecondaryUIButton: UIButton {

    let borderColor = HexColor("99FBDA")!
    
    public override func awakeFromNib() {
        
        let paddingLeftRight: CGFloat = 24.0
        let paddingTopBottom: CGFloat = 16.0
        
        let size = self.titleLabel!.text!.size(
            withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: self.titleLabel!.font.pointSize)]
        )
        
        self.frame.size = CGSize(width: size.width + paddingLeftRight * 2,
                                 height: size.height + paddingTopBottom * 2)
        
        
        self.contentEdgeInsets = UIEdgeInsets(top: paddingTopBottom,
                                              left: paddingLeftRight,
                                              bottom: paddingTopBottom,
                                              right: paddingLeftRight)
        
        self.setTitleColor(UIColor.black, for: .normal)
    }
    
    // MARK: Public interface
    
    //    @IBInspectable public var cornerRadius: CGFloat = 8 {
    //        didSet {
    //            self.setNeedsLayout()
    //        }
    //    }
    //
    //    @IBInspectable public var bgColor: UIColor = UIColor.white {
    //        didSet {
    //            self.setNeedsLayout()
    //        }
    //    }
    //
    //    @IBInspectable var borderColor: UIColor? {
    //        get {
    //            return UIColor(cgColor: self.layer.borderColor!)
    //        }
    //        set {
    //            self.layer.borderColor = newValue?.cgColor
    //        }
    //    }
    
    // MARK: Overrides
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        layoutRoundRectLayer()
    }
    
    override public var isEnabled: Bool {
        didSet {
            layoutSubviews()
        }
    }
    
    // MARK: Private
    
    private var roundRectLayer: CAShapeLayer?
    
    private func layoutRoundRectLayer() {
        if let existingLayer = roundRectLayer {
            existingLayer.removeFromSuperlayer()
        }
        let shapeLayer = CAShapeLayer()
        shapeLayer.lineWidth = 3
        shapeLayer.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 26).cgPath
        shapeLayer.fillColor = UIColor.white.cgColor
        shapeLayer.strokeColor = borderColor.cgColor
        
        self.layer.insertSublayer(shapeLayer, at: 0)
        self.roundRectLayer = shapeLayer
    }

}
