//
//  CustomSliderCell.swift
//  Newcast
//
//  Created by Nikhil Bolar on 8/8/19.
//  Copyright © 2019 Nikhil Bolar. All rights reserved.
//

import Cocoa

class CustomSliderCell: NSSliderCell {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func drawBar(inside aRect: NSRect, flipped: Bool) {
        var rect = aRect
        rect.size.height = CGFloat(6)
        let barRadius = CGFloat(2.5)
        let value = CGFloat((self.doubleValue - self.minValue) / (self.maxValue - self.minValue))
        let finalWidth = CGFloat(value * (self.controlView!.frame.size.width - 8))
        var leftRect = rect
        leftRect.size.width = finalWidth
        let bg = NSBezierPath(roundedRect: rect, xRadius: barRadius, yRadius: barRadius)
        NSColor.white.setFill()
        bg.fill()
        let active = NSBezierPath(roundedRect: leftRect, xRadius: barRadius, yRadius: barRadius)
//        CGColor.init(red: 0.39, green: 0.72, blue: 1.0, alpha: 0.9)
        NSColor.init(red: 0.39, green: 0.62, blue: 1.0, alpha: 0.9).setFill()
        active.fill()
    }

    
//    override func drawKnob(_ rect: NSRect) {
//        let drawImage: NSImage? = .init(imageLiteralResourceName: "pause")
//
//        var drawRect = rect
//        drawRect = knobRect(flipped: controlView?.isFlipped ?? false)
//
//        let fraction: CGFloat = 1.0
//
//        drawImage?.draw(in: drawRect, from: NSRect.zero, operation: .sourceOver, fraction: fraction, respectFlipped: true, hints: nil)
//    }
    
//    override func knobRect(flipped: Bool) -> NSRect {
//        let drawImage: NSImage? = .init(imageLiteralResourceName: "pause")
//
//        var drawRect: NSRect = super.knobRect(flipped: flipped)
//
//        drawRect.size = drawImage?.size ?? CGSize.zero
////
////        var bounds: NSRect? = controlView?.bounds
////        bounds = bounds?.insetBy(dx: 0, dy: 0)
////        var val = CGFloat(min(maxValue, max(minValue, doubleValue)))
////        val = (val - CGFloat(minValue)) / CGFloat((maxValue - minValue))
////        let x: CGFloat = val * bounds!.width + bounds!.minX
//
//        drawRect = NSOffsetRect(drawRect, -4, -2.5)
//        return drawRect
//    }
}
