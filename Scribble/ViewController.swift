//
//  ViewController.swift
//  Scribble
//
//  Created by Caroline Begbie on 29/11/2015.
//  Copyright © 2015 Caroline Begbie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  @IBOutlet weak var canvasView: CanvasView!

  override func viewDidLoad() {
    super.viewDidLoad()
    canvasView.clearCanvas()
  }
  
  @IBAction func btnClear(sender: AnyObject) {
    canvasView.clearCanvas()
  }

}

