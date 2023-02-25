//
//  MySlider.swift
//  Stay
//
//  Created by Jin on 2023/2/19.
//

import UIKit

class MySlider: UIControl {
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    var minimumValue: CGFloat = 0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var maximumValue: CGFloat = 1 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var value: CGFloat = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var trackTintColor = UIColor(white: 0.0, alpha: 0.1) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var trackHighlightTintColor = UIColor(white: 1.0, alpha: 1) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var thumbImage = UIImage(systemName: "circle.fill", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 10)))!.withTintColor(.white).withRenderingMode(.alwaysOriginal) {
        didSet {
            thumbImageView.image = thumbImage
            updateLayerFrames()
        }
    }
    
    private let trackLayer = SliderTrackLayer()
    private let thumbImageView = UIImageView()
    private var previousLocation = CGPoint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.mySlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        thumbImageView.image = thumbImage
        addSubview(thumbImageView)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateLayerFrames()
    }
    
    // 1
    private func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3)
        trackLayer.setNeedsDisplay()
        thumbImageView.frame = CGRect(origin: thumbOriginForValue(value),
                                      size: thumbImage.size)
        CATransaction.commit()
    }
    // 2
    func positionForValue(_ value: CGFloat) -> CGFloat {
        return value.isNaN ? 0 : bounds.width * value
    }
    // 3
    private func thumbOriginForValue(_ value: CGFloat) -> CGPoint {
        let x = positionForValue(value) - thumbImage.size.width / 2.0
        return CGPoint(x: x, y: (bounds.height - thumbImage.size.height) / 2.0)
    }
}

extension MySlider {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.self) {
            return false
        }
        
        return true
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        // 1
        previousLocation = touch.location(in: self)
        
        // 2
        if thumbImageView.frame.contains(previousLocation) {
            thumbImageView.isHighlighted = true
            sendEvent(event: event)
        }
        
        // 3
        return thumbImageView.isHighlighted
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // 1
        let deltaLocation = location.x - previousLocation.x
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / bounds.width
        
        previousLocation = location
        
        // 2
        if thumbImageView.isHighlighted {
            value += deltaValue
            value = boundValue(value, toLowerValue: minimumValue,
                               upperValue: maximumValue)
        }
        
        sendEvent(event: event)
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        thumbImageView.isHighlighted = false
        
        sendEvent(event: event)
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        
        thumbImageView.isHighlighted = false
        
        sendEvent(event: event)
    }
    
    private func sendEvent(event: UIEvent?) {
        for target in allTargets {
            if let actions = actions(forTarget: target, forControlEvent: .valueChanged) {
                for action in actions {
                    sendAction(Selector(action), to: target, for: event)
                }
            }
        }
    }
    
    // 4
    private func boundValue(_ value: CGFloat, toLowerValue lowerValue: CGFloat, upperValue: CGFloat) -> CGFloat {
        return min(max(value, lowerValue), upperValue)
    }
}

class SliderTrackLayer: CALayer {
    weak var mySlider: MySlider?
    
    override func draw(in ctx: CGContext) {
        guard let slider = mySlider else {
            return
        }
        
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2)
        ctx.addPath(path.cgPath)
        ctx.setFillColor(slider.trackTintColor.cgColor)
        ctx.fillPath()
        
        let curValuePosition = slider.positionForValue(slider.value)
        let rect = CGRect(x: 0, y: 0,
                          width: curValuePosition,
                          height: bounds.height)
        let hlPath = UIBezierPath(roundedRect: rect, cornerRadius: bounds.height / 2)
        ctx.beginPath()
        ctx.addPath(hlPath.cgPath)
        ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
        ctx.fillPath()
    }
}
