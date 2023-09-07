//
//  BackgroundCurveView.swift
//  MoneyBox
//
//  Created by David Gray on 01/09/2023.
//

import UIKit

class BackgroundCurveView: UIView {

    // MARK: - Properties
    var path: UIBezierPath!
    weak var shapeLayer: CAShapeLayer?
    var shouldAnimate: Bool = false
    
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        self.backgroundColor = UIColor.clear
    }
     
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    // MARK: - View Logic
    override func draw(_ rect: CGRect) {
        self.createCurve()
        UIColor(named: "dark_teal")!.setFill()
        path.fill()
    }
    
    func createCurve() {
        // Initialize the path.
        path = UIBezierPath()
        path.move(to: CGPoint(x: -20, y: self.frame.size.height * 0.5))
        path.addCurve(
            to: CGPoint(x: self.frame.size.width + 60, y: self.frame.size.height * 0.18),
            controlPoint1: CGPoint(x: self.frame.size.width * 0.5, y: (self.frame.size.height * 0.5) + 50),
            controlPoint2: CGPoint(x: self.frame.size.width * 0.5, y: (self.frame.size.height * 0.3) - 30)
        )
        path.addLine(to: CGPoint(x: self.frame.size.width + 40, y: self.frame.size.height + 40))
        path.addLine(to: CGPoint(x: -40, y: self.frame.size.height + 40))
        path.close()
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.darkTeal.cgColor
        shapeLayer.strokeColor = UIColor.lightTeal.cgColor
        shapeLayer.lineWidth = 10
        shapeLayer.path = path.cgPath
        
        
        // Configure aniamtion
        layer.addSublayer(shapeLayer)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = shouldAnimate ? 4.5 : 0.00
        shapeLayer.add(animation, forKey: "Curve Animation")
        layer.addSublayer(shapeLayer)
        
    }

}
