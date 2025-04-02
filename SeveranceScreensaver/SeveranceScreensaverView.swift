//
//  SeveranceScreensaver.swift
//  SeveranceScreensaver
//
//  Created by Mark Magahis on 2025.02.28.
//

import Foundation
import ScreenSaver

class SeveranceScreensaverView: ScreenSaverView {
    var label: NSTextField!

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
        
        // Create the text label
        label = NSTextField(labelWithString: "Hello, Ms. Cobel.")
        label.font = NSFont.systemFont(ofSize: 48, weight: .bold)
        label.textColor = NSColor.white
        label.alignment = .center
        label.backgroundColor = .clear
        label.frame = CGRect(x: bounds.width, y: bounds.midY - 24, width: 400, height: 50)
        addSubview(label)
        
        // Start animation loop
        animateText()
    }

    private func animateText() {
        let screenWidth = NSScreen.main?.frame.width ?? 800
        let textWidth = label.frame.width
        let centerX = screenWidth / 2 - (textWidth / 2)
//        let textWidth = self.intrinsicContentSize.width
        let offScreenRight = screenWidth + textWidth
        let offScreenLeft = -textWidth
        
        // Set init position (off-screen right)
        label.frame.origin.x = offScreenRight
        
        // Animate moving to center
        let moveToCenter = CASpringAnimation(keyPath: "position.x")
        moveToCenter.fromValue = offScreenRight
        moveToCenter.toValue = centerX
        moveToCenter.damping = 90
        moveToCenter.stiffness = 100
        moveToCenter.mass = 10
        moveToCenter.initialVelocity = 0.00005
        moveToCenter.isRemovedOnCompletion = false
        moveToCenter.duration = moveToCenter.settlingDuration
        moveToCenter.timingFunction = CAMediaTimingFunction(name: .easeIn)

        // Animate moving out to the left
        let moveOut = CASpringAnimation(keyPath: "position.x")
        moveOut.fromValue = centerX
        moveOut.toValue = offScreenLeft
        moveOut.beginTime = moveToCenter.beginTime + moveToCenter.settlingDuration
        moveOut.damping = 90
        moveOut.stiffness = 100
        moveOut.mass = 10
        moveOut.initialVelocity = 0.00005
        moveOut.duration = moveOut.settlingDuration
        moveOut.timingFunction = CAMediaTimingFunction(name: .easeIn)

        // Group both animations
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [moveToCenter, moveOut]
        animationGroup.duration = moveToCenter.settlingDuration + moveOut.settlingDuration + 1
        animationGroup.fillMode = .forwards
        animationGroup.isRemovedOnCompletion = false
        
        label.layer?.add(animationGroup, forKey: "textMoveAnimation")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + animationGroup.duration) {
            self.animateText()
        }
    }
    
    override func draw(_ rect: NSRect) {
        NSColor.black.setFill()
        rect.fill()
    }
}
