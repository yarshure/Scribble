//
//  CanvasView.swift
//  Scribble
//
//  Created by Caroline Begbie on 29/11/2015.
//  Copyright © 2015 Caroline Begbie. All rights reserved.
//

import UIKit

let π = CGFloat(M_PI)

@IBDesignable
class CanvasView: UIImageView {
  
  var drawingImage: UIImage?
  
  @IBInspectable var drawColor: UIColor = UIColor.redColor()
  @IBInspectable var lineWidth: CGFloat = 6
  
  let ForceSensitivity:CGFloat = 4.0

  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    self.layer.borderColor = UIColor.blueColor().CGColor
    self.layer.borderWidth = 1
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    
    // Draw previous image into context
    self.image?.drawInRect(bounds)
    
    var touches = [UITouch]()

    // Coalesce Touches
    if let coalescedTouches = event?.coalescedTouchesForTouch(touch) {
      touches = coalescedTouches
    } else {
      touches.append(touch)
    }

    for touch in touches {
      drawStroke(context, touch: touch)
    }
    
    // Update image
    self.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
  }
  
  func drawStroke(context: CGContext?, touch: UITouch) {
    let previousLocation = touch.previousLocationInView(self)
    let location = touch.locationInView(self)
    
    // Set up the default stroke
    CGContextSetLineCap(context, .Round)
    CGContextSetLineWidth(context, lineWidth)
    
    // calculate force
    // if finger, force is 0
    
    let force = touch.force == 0 ? 1 : touch.force
    if touch.type == .Stylus {
      // draw line with pencil
      CGContextSetLineWidth(context, force * ForceSensitivity)
    }
    
    drawColor.setStroke()
    
    // Set up the points
    CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
    CGContextAddLineToPoint(context, location.x, location.y)
    
    // Draw the stroke
    CGContextStrokePath(context)

  }
}
