//
//  TouchBarView.swift
//  TouchBreakout
//
//  Created by 宋 奎熹 on 2017/11/16.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

import Cocoa

protocol TouchBarViewDelegate: class {
    
    func didMoveTo(_ locationX: Double)
    
}

class TouchBarView: NSView {

    private let kPaddleWidth    = 100.0
    private let kPaddleHeight   = 30.0

    var trackingTouchIdentity: AnyObject?
    
    override var acceptsFirstResponder: Bool { return true }
    
    var touchBarPaddle: NSView?
    
    weak var delegate: TouchBarViewDelegate? = nil
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        touchBarPaddle = NSView(frame: NSRect(x: Double(frame.width / 2) - kPaddleWidth / 2,
                                              y: 0,
                                              width: kPaddleWidth,
                                              height: kPaddleHeight))
        touchBarPaddle?.wantsLayer = true   // Necessary
        touchBarPaddle?.layer?.cornerRadius = 15.0
        touchBarPaddle?.layer?.masksToBounds = true
        touchBarPaddle?.layer?.backgroundColor = NSColor.paddle.cgColor
        
        addSubview(touchBarPaddle!)
    }
    
    override func touchesBegan(with event: NSEvent) {
        // trackingTouchIdentity != nil:
        // We are already tracking a touch, so ignore this new touch.
        if trackingTouchIdentity == nil {
            if let touch = event.touches(matching: .began, in: self).first, touch.type == .direct {
                trackingTouchIdentity = touch.identity
//                let location = touch.location(in: self)
//                if (touchBarPaddle?.frame.contains(location))! {
//                    print("In Paddle")
//                }
            }
        }
        super.touchesBegan(with: event)
    }
    
    override func touchesMoved(with event: NSEvent) {
        if let trackingTouchIdentity = trackingTouchIdentity {
            let relevantTouches = event.touches(matching: .moved, in: self)
            let actualTouches = relevantTouches.filter({ $0.type == .direct && $0.identity.isEqual(trackingTouchIdentity) })
            if let trackingTouch = actualTouches.first {
                let location = trackingTouch.location(in: self)
                let locationX = Double(location.x) - kPaddleWidth / 2
                
                var finalLocationX = 0.0
                if locationX < 0.0 {
                    finalLocationX = 0.0
                } else if locationX + kPaddleWidth > Double(frame.width) {
                    finalLocationX = Double(frame.width) - kPaddleWidth
                } else {
                    finalLocationX = locationX
                }
                touchBarPaddle?.frame = NSRect(x: finalLocationX,
                                               y: 0,
                                               width: kPaddleWidth,
                                               height: kPaddleHeight)
                self.delegate?.didMoveTo(finalLocationX)
            }
        }
        super.touchesMoved(with: event)
    }
    
    override func touchesEnded(with event: NSEvent) {
        if let trackingTouchIdentity = trackingTouchIdentity {
            let relevantTouches = event.touches(matching: .ended, in: self)
            let actualTouches = relevantTouches.filter({ $0.type == .direct && $0.identity.isEqual(trackingTouchIdentity) })
            if let _ = actualTouches.first {
                self.trackingTouchIdentity = nil
            }
        }
        super.touchesEnded(with: event)
    }
    
    override func touchesCancelled(with event: NSEvent) {
        if let trackingTouchIdentity = trackingTouchIdentity {
            let relevantTouches = event.touches(matching: .cancelled, in: self)
            let actualTouches = relevantTouches.filter({ $0.type == .direct && $0.identity.isEqual(trackingTouchIdentity) })
            if let _ = actualTouches.first {
                self.trackingTouchIdentity = nil
            }
        }
        super.touchesCancelled(with: event)
    }
}
