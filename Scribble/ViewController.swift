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

class ViewController: UIViewController {

  @IBOutlet weak var canvasView: CanvasView!

  override func viewDidLoad() {
    super.viewDidLoad()
    canvasView.clearCanvas(animated:false)
  }
    
  // Shake to clear screen

    
 override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    canvasView.clearCanvas(animated: true)
  }
  
  @IBAction func btnCoalesced(_ button:UIButton) {
    canvasView.isCoalesced = !canvasView.isCoalesced
    if (canvasView.isCoalesced) {
      button.setTitle("Coalesced ON", for: .normal)
    } else {
      button.setTitle("Coalesced OFF", for: .normal)
    }
  }

  @IBAction func btnPredicted(_ button:UIButton) {
    canvasView.isPredicted = !canvasView.isPredicted
    if (canvasView.isPredicted) {
      button.setTitle("Predicted ON", for: .normal)
    } else {
      button.setTitle("Predicted OFF", for: .normal)
    }
  }
  
  @IBAction func btnShowPredicted(_ button:UIButton) {
    canvasView.isShowPredicted = !canvasView.isShowPredicted
    if (canvasView.isShowPredicted) {
      button.setTitle("Show Predicted ON", for: .normal)
    } else {
      button.setTitle("Show Predicted OFF", for: .normal)
    }
   
  }
  

//   override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
//
//    canvasView.clearCanvas(animated: true)
//    }

}



