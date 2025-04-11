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
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func startAnimation() {
        super.startAnimation()
        setupText()
    }

    override func stopAnimation() {
        super.stopAnimation()
    }

    override func draw(_ rect: NSRect) {
        NSColor.black.setFill()
        rect.fill()
    }

    private func setupText() {
        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor.black.cgColor

        let fontSize: CGFloat = bounds.height * 0.1
        let defaultFontSpec: NSFont = NSFont.systemFont(ofSize: fontSize, weight: .bold)
        let fontSpec = NSFont(name: "Michroma", size: fontSize)
        let atributes: [NSAttributedString.Key: Any] = [.font: fontSpec ?? defaultFontSpec]

        let startX = bounds.width
        let startY = bounds.midY - fontSize / 2
        let textWidth: CGFloat = CGFloat( text.size(withAttributes: atributes).width )

        var charPosition = startX
        for (_, char) in text.enumerated() {
            let charLayer = CATextLayer()
            charLayer.string = String(char)
            charLayer.font = fontSpec
            charLayer.fontSize = fontSize
            charLayer.foregroundColor = NSColor.white.cgColor
            charLayer.alignmentMode = .center
            charLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0

            let charSpace: CGSize = String(char).size(withAttributes: atributes)
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

    private func animateExit(centerX: CGFloat, textWidth: CGFloat) {
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
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration / 7) {
            self.animateIn(textWidth: textWidth)
        }
    }

    private func configSpringAnimation(layer: CASpringAnimation, index: Int) {
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
