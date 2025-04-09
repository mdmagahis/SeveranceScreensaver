//
//  SeveranceScreensaver.swift
//  SeveranceScreensaver
//
//  Created by Mark Magahis on 2025.02.28.
//

import Foundation
import ScreenSaver

class SeveranceScreensaverView: ScreenSaverView {
    var characterLayers: [CATextLayer] = []
    let text = "Hello Ms. Cobel"

    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        setupText()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupText()
    }

    private func setupText() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.black.cgColor
        
        let fontSize: CGFloat = bounds.height * 0.1
        let fontSpec: NSFont = NSFont.systemFont(ofSize: fontSize, weight: .bold)
        let startX = bounds.width
        let startY = bounds.midY - fontSize / 2
        let textWidth: CGFloat = CGFloat( text.size(withAttributes: [.font: fontSpec]).width )

        var charPosition = startX
        for (_, char) in text.enumerated() {
            let charLayer = CATextLayer()
            charLayer.string = String(char)
            charLayer.font = fontSpec
            charLayer.fontSize = fontSize
            charLayer.foregroundColor = NSColor.white.cgColor
            charLayer.alignmentMode = .center
            charLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
            
            let charSpace: CGSize = String(char).size(withAttributes: [.font: fontSpec])
            print("char:", char, "| width:", charSpace.width, "| pos:", charPosition)
            let xPosition = charPosition
            charLayer.frame = CGRect(x: xPosition, y: startY, width: CGFloat(charSpace.width), height: CGFloat(charSpace.height))
            
            self.layer?.addSublayer(charLayer)
            characterLayers.append(charLayer)
            charPosition += CGFloat(charSpace.width)
        }

        animateIn(textWidth: textWidth)
    }

    private func animateIn(textWidth: CGFloat) {

        let centerX = bounds.midX
        var totalDuration: CFTimeInterval = 0

        for ( index, charLayer ) in characterLayers.enumerated() {
            let moveToCenter = CASpringAnimation(keyPath: "position.x")
            configSpringAnimation(layer: moveToCenter, index: index)
            moveToCenter.fromValue = charLayer.position.x
            moveToCenter.toValue = centerX - (textWidth / 2) + charLayer.position.x - bounds.width
            
            charLayer.add(moveToCenter, forKey: "moveToCenter")
            totalDuration += moveToCenter.settlingDuration
        }
        
        let moveOutDelay = totalDuration / 5 // Time before moving out
        DispatchQueue.main.asyncAfter(deadline: .now() + moveOutDelay) {
            self.animateExit(centerX: centerX, textWidth: textWidth)
        }
    }
    func animateExit(centerX: CGFloat, textWidth: CGFloat) {
        var totalDuration: CFTimeInterval = 0

        // Animate moving out to the left
        for ( index, charLayer ) in characterLayers.enumerated() {
            
            
            let moveOut = CASpringAnimation(keyPath: "position.x")
            configSpringAnimation(layer: moveOut, index: index)
            moveOut.fromValue = centerX - (textWidth / 2) + charLayer.position.x - bounds.width
            moveOut.toValue = -(charLayer.position.x)
            
            charLayer.add(moveOut, forKey: "moveOut")
            totalDuration += moveOut.settlingDuration
        }
        
        // Restart animation after exit
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration / 5) {
            self.animateIn(textWidth: textWidth)
        }
    }
    
    func configSpringAnimation(layer: CASpringAnimation, index: Int) {
        let delay = Double(index) * 0.2 // Stagger animation for each character
        layer.damping = 1500
        layer.stiffness = 100
        layer.mass = 10
        layer.initialVelocity = 0.5
        layer.duration = layer.settlingDuration * 10 // Adjust this to change speed of animation
        layer.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.fillMode = .forwards
        layer.beginTime = CACurrentMediaTime() + delay
    }

}
