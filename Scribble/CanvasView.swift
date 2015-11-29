//
//  CanvasView.swift
//  Scribble
//
//  Created by Caroline Begbie on 29/11/2015.
//  Copyright © 2015 Caroline Begbie. All rights reserved.
//

import UIKit

let π = CGFloat(M_PI)

class CanvasView: UIImageView {
  
  var drawingImage: UIImage?
  
  var drawColor: UIColor = UIColor.redColor()
  var eraserColor: UIColor {
    if let backgroundColor = self.backgroundColor {
      return backgroundColor
    }
    return UIColor.whiteColor()
  }
  
  var lineWidth: CGFloat = 6
  
  var pencilTexture: UIColor = UIColor(patternImage: UIImage(named: "PencilTexture")!)
  
  // Threshold Parameters
  let ForceSensitivity:CGFloat = 4.0
  let TiltThreshold = π / 6
  let MinLineWidth:CGFloat = 5
  
  // For averaging line sizes
  let MaxLineWidthGrowth:CGFloat = 5  // Max amount line width can increase for a stroke
  let LineSizeTolerance:Int = 115 // Number of lines to hold in array
  var previousLineSizes = [CGFloat]()
  
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    previousLineSizes = [CGFloat]()
  }
  
  override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
    guard let touch = touches.first else { return }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
    let context = UIGraphicsGetCurrentContext()
    
    // Draw previous image into context
    //    self.image?.drawInRect(bounds)
    drawingImage?.drawInRect(bounds)
    
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
    
    drawingImage = UIGraphicsGetImageFromCurrentImageContext()
    
    // Draw Predicted Touches, but they must be
    // removed from the canvas for the next draw
    // For visualizing predicted touches,
    // remove comments
    
    if let predictedTouches = event?.predictedTouchesForTouch(touch) {
      touches = predictedTouches
      //      let holdPencilTexture = pencilTexture
      //      pencilTexture = UIColor.blueColor()
      for touch in touches {
        drawStroke(context, touch: touch)
      }
      //      pencilTexture = holdPencilTexture
    }
    
    // Update image
    self.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
  }
  
  
  func drawStroke(context: CGContext?, touch: UITouch) {
    let previousLocation = touch.previousLocationInView(self)
    let location = touch.locationInView(self)
    
    if touch.type == .Stylus {
      // Check if shading
      if touch.altitudeAngle < TiltThreshold {
        lineWidth = lineWidthForShading(context, touch: touch)
      } else {
        lineWidth = lineWidthForDrawing(context, touch: touch)
      }
      
      // Set up the default stroke
      pencilTexture.setStroke()
    } else {
      // erase with finger
      CGContextSetLineCap(context, .Round)
      
      lineWidth = touch.majorRadius / 2
      
      eraserColor.setStroke()
    }
    lineWidth = max(lineWidth, MinLineWidth)
    
    
    CGContextSetLineWidth(context, lineWidth)
    
    let isSimple = true
    
    if isSimple {
      // Set up the points
      CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
      CGContextAddLineToPoint(context, location.x, location.y)
    } else {
      
      func distanceBetweenTwoPoints(from from:CGPoint, to:CGPoint) -> CGFloat {
        let squared = (from.x-to.x)*(from.x-to.x) + (from.y-to.y)*(from.y-to.y)
        return sqrt(squared)
      }
      
      let distance = distanceBetweenTwoPoints(from: previousLocation, to: location)
      
      CGContextBeginPath(context)
      CGContextSetStrokeColorWithColor(context, UIColor.redColor().CGColor)
      pencilTexture.setStroke()
      
      
      CGContextSetLineWidth(context, distance);
      CGContextMoveToPoint(context, location.x, location.y)
      
      var targetPoint = CGPoint(x:0.5 + lineWidth * cos(touch.altitudeAngle), y:0.0)
      targetPoint = CGPointApplyAffineTransform(targetPoint, CGAffineTransformMakeRotation(touch.azimuthAngleInView(self)))
      targetPoint.x += location.x
      targetPoint.y += location.y
      CGContextAddLineToPoint(context, targetPoint.x, targetPoint.y)
      
      
    }
    
    // Draw the stroke
    CGContextStrokePath(context)
    
  }
  
  func lineWidthForDrawing(context: CGContext?, touch: UITouch) -> CGFloat {
    
    CGContextSetLineCap(context, .Round)
    var lineWidth = self.lineWidth
    
    if touch.force > 0 {  // If finger, touch.force = 0
      lineWidth =  touch.force * ForceSensitivity
    }
    
    return lineWidth
  }
  
  func lineWidthForShading(context: CGContext?, touch: UITouch) -> CGFloat {
    
    CGContextSetLineCap(context, .Round)
    
    let previousLocation = touch.previousLocationInView(self)
    let location = touch.locationInView(self)
    
    // vector1 is the pencil direction
    let vector1 = touch.azimuthUnitVectorInView(nil)
    
    // vector2 is the stroke direction
    let vector2 = CGPoint(x: location.x - previousLocation.x, y: location.y - previousLocation.y)
    
    // Angle between two vectors
    var angle = abs(atan2(vector2.y, vector2.x) - atan2(vector1.dy, vector1.dx))
    
    // reduce the angle to be between 0 and 90 degrees
    // remember π is 180º and π/2 is 90º
    // if the angle between the pencil direction and the stroke direction is
    // 90º then the stroke is at the widest
    
    // Note I'm sure this can be done in one step maybe with a modulo
    // but for the moment I can't work it out!
    
    if angle > π {
      angle = 2 * π - angle
    }
    if angle > π / 2 {
      angle = π - angle
    }
    
    let maxLineWidth:CGFloat = 60
    
    let minAngle:CGFloat = 0
    let maxAngle:CGFloat = π / 2
    let normalizedAngle = (angle - minAngle) / (maxAngle - minAngle)
    lineWidth = maxLineWidth * normalizedAngle
    
    // modify lineWidth by altitude (tilt of the pencil)
    // 0.25 radians means widest stroke and TiltThreshold is where shading changes to line.
    
    let minAltitudeAngle:CGFloat = 0.25
    let maxAltitudeAngle:CGFloat = TiltThreshold
    
    let altitudeAngle = touch.altitudeAngle < minAltitudeAngle ? minAltitudeAngle : touch.altitudeAngle
    let normalizedAltitude = 1 - ((altitudeAngle - minAltitudeAngle) / (maxAltitudeAngle - minAltitudeAngle))
    
    lineWidth = lineWidth * normalizedAltitude + MinLineWidth
    
    
    // set alpha of shading using force
    let minForce:CGFloat = 0.0
    let maxForce:CGFloat = 5
    
    // normalize
    let normalizedAlpha = (touch.force - minForce) / (maxForce - minForce)
    
    CGContextSetAlpha(context, normalizedAlpha)
    
    return lineWidth
  }
  
  
  
  
  func clearCanvas() {
    image = UIImage(named: "Background")
    drawingImage = image
  }
}
