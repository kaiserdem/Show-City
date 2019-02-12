//
//  MapVC.swift
//  Show City
//
//  Created by Kaiserdem on 12.02.2019.
//  Copyright © 2019 Kaiserdem. All rights reserved.
//

import UIKit
import MapKit

class MapVC: UIViewController {
  
  @IBOutlet weak var mapView: MKMapView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.delegate = self
    
  }
  
  @IBAction func centerMapBtnWasPressed(_ sender: Any) {
  }
  
}
extension MapVC: MKMapViewDelegate {
  
}
