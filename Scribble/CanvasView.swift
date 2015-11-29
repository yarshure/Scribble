/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit

let π = CGFloat(M_PI)

class CanvasView: UIImageView {
  
  var drawingImage: UIImage?
  
  private var drawColor: UIColor = UIColor.redColor()
  private var eraserColor: UIColor {
    if let backgroundColor = self.backgroundColor {
      return backgroundColor
    }
    return UIColor.whiteColor()
  }
  
  private var lineWidth: CGFloat = 6
  private var pencilTexture: UIColor = UIColor(patternImage: UIImage(named: "PencilTexture")!)
  
  // Threshold Parameters
  private let ForceSensitivity:CGFloat = 4.0
  private let TiltThreshold = π / 6
  private let MinLineWidth:CGFloat = 5
  
  
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
  
  private func drawStroke(context: CGContext?, touch: UITouch) {
    let previousLocation = touch.previousLocationInView(self)
    let location = touch.locationInView(self)
    
    if touch.type == .Stylus {
      // Check if shading
      if touch.altitudeAngle < TiltThreshold {
        lineWidth = lineWidthForShading(context, touch: touch)
      } else {
        lineWidth = lineWidthForDrawing(context, touch: touch)
      }
      
      pencilTexture.setStroke()
      
    } else {
      // erase with finger
      CGContextSetLineCap(context, .Round)
      
      lineWidth = touch.majorRadius / 2
      
      eraserColor.setStroke()
    }
    CGContextSetLineWidth(context, lineWidth)
    
    // Set up the points
    CGContextMoveToPoint(context, previousLocation.x, previousLocation.y)
    CGContextAddLineToPoint(context, location.x, location.y)
    // Draw the stroke
    CGContextStrokePath(context)
    
  }
  
  private func lineWidthForDrawing(context: CGContext?, touch: UITouch) -> CGFloat {
    
    // Set up line for Drawing
    CGContextSetLineCap(context, .Round)
    var lineWidth = self.lineWidth
    
    if touch.force > 0 {  // If finger, touch.force = 0
      lineWidth = touch.force * ForceSensitivity
    }
    return lineWidth
  }
  
  private func lineWidthForShading(context: CGContext?, touch: UITouch) -> CGFloat {
    
    // Set up line for Shading
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
    // 0.25 radians means widest stroke and TiltThreshold is where shading narrows to line.
    
    let minAltitudeAngle:CGFloat = 0.25
    let maxAltitudeAngle:CGFloat = TiltThreshold
    
    let altitudeAngle = touch.altitudeAngle < minAltitudeAngle ? minAltitudeAngle : touch.altitudeAngle
    
    // normalize between 0 and 1
    let normalizedAltitude = 1 - ((altitudeAngle - minAltitudeAngle) / (maxAltitudeAngle - minAltitudeAngle))
    
    lineWidth = lineWidth * normalizedAltitude + MinLineWidth
    
    
    // set alpha of shading using force
    let minForce:CGFloat = 0.0
    let maxForce:CGFloat = 5
    
    // normalize between 0 and 1
    let normalizedAlpha = (touch.force - minForce) / (maxForce - minForce)
    
    CGContextSetAlpha(context, normalizedAlpha)
    
    return lineWidth
  }
  
  override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
    // save last predicted touch
    drawingImage = self.image
  }
  
  func clearCanvas() {
    image = UIImage(named: "Background")
    drawingImage = image
  }
}
