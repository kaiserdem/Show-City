//
//  PopVC.swift
//  Show City
//
//  Created by Kaiserdem on 14.02.2019.
//  Copyright © 2019 Kaiserdem. All rights reserved.
//

import UIKit

class PopVC: UIViewController, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var popImageView: UIImageView!
  
  var passedImage: UIImage!
  
  func initData(forImage image: UIImage) {
    self.passedImage = image
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    popImageView.image = passedImage
    addDoubleTap()
  }
  func addDoubleTap() {
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(csreenWasDoubleTapped))
    doubleTap.numberOfTapsRequired = 2
    doubleTap.delegate = self
    view.addGestureRecognizer(doubleTap)
  }
  @objc func csreenWasDoubleTapped() {
    dismiss(animated: true, completion: nil)
  }
}
