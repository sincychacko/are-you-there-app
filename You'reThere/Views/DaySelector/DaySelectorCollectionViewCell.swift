//
//  DaySelectorCollectionViewCell.swift
//  You'reThere
//
//  Created by SINCY on 02/01/20.
//  Copyright © 2020 SINCY. All rights reserved.
//

import UIKit

class DaySelectorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var title: UILabel!
        
//    @IBInspectable var bgColor: UIColor = Constants.appColor {
//        didSet {
//            bgView.backgroundColor = bgColor
//        }
//    }
    
    var isDaySelected = true {
        didSet {
            if isDaySelected {
                bgView.backgroundColor = UIColor.red
            } else {
                bgView.backgroundColor = UIColor.clear
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        setUpView()
    }
    
    private func setUpView() {
        bgView.layer.cornerRadius = 18
        bgView.layer.borderWidth = 2
        if #available(iOS 11.0, *) {
            bgView.layer.borderColor = UIColor(named: "AppRed")?.cgColor ?? UIColor.red.cgColor
        } else {
            bgView.layer.borderColor = UIColor(red: 239, green: 70, blue: 34, alpha: 1).cgColor
        }

        /*guard let context = UIGraphicsGetCurrentContext() else {
            return
        }

        context.setLineWidth(2.0);

        UIColor.red.set()

        let center = CGPoint(x: 18, y: 18)
        let radius: CGFloat = 10
        context.addArc(center: center, radius: radius, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)

        context.strokePath()*/
    }

}
