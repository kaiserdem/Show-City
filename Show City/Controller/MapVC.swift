//
//  MapVC.swift
//  Show City
//
//  Created by Kaiserdem on 12.02.2019.
//  Copyright © 2019 Kaiserdem. All rights reserved.
// An app that downloads photos from the internet and displays for a location

import UIKit
import MapKit
import CoreLocation

class MapVC: UIViewController, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var pullUpView: UIView!
  @IBOutlet weak var pullUpViewHightConstraints: NSLayoutConstraint!
  
  var locationManager = CLLocationManager()
  let authorizationStatus = CLLocationManager.authorizationStatus()
  let regionRadius: Double = 1000
  
  var spinner: UIActivityIndicatorView?
  var progressLbl: UILabel?
  var collecrionView: UICollectionView?
  var flowLayauot = UICollectionViewFlowLayout()
  var screenSize = UIScreen.main.bounds
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    mapView.delegate = self
    locationManager.delegate = self
    configureLocationServices()
    addDoubleTap()
    
    collecrionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayauot)
    collecrionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "photoCell")
    collecrionView?.delegate = self
    collecrionView?.dataSource = self
    collecrionView?.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
    
    pullUpView.addSubview(collecrionView!)
  }
  
  func addDoubleTap() {
    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender:)))
    doubleTap.numberOfTapsRequired = 2
    doubleTap.delegate = self
    mapView.addGestureRecognizer(doubleTap)
  }
  
  func addSwipe() { // вю скрываеться
    let swipe = UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
    swipe.direction = .down
    pullUpView.addGestureRecognizer(swipe)
  }
  func animateViewUp() { // появляеться вю
    pullUpViewHightConstraints.constant = 300
    UIView.animate(withDuration: 0.3) {
      self.view.layoutIfNeeded()
    }
  }
  
  @objc func animateViewDown() {
    pullUpViewHightConstraints.constant = 0
    UIView.animate(withDuration: 0.3) {
      self.loadViewIfNeeded()
    }
  }
  
  func addSpinner() {
    spinner = UIActivityIndicatorView()
    spinner?.center = CGPoint(x: (screenSize.width / 2) - ((spinner?.frame.width)! / 2), y: 150)
    spinner?.style = .whiteLarge
    spinner?.color = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    spinner?.startAnimating()
    collecrionView?.addSubview(spinner!)
  }
  
  func  removeSpinner() {
    if spinner != nil {
      spinner?.removeFromSuperview()
    }
  }
  func addProgressLbl() {
    progressLbl = UILabel()
    progressLbl?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 240, height: 40)
    progressLbl?.font = UIFont(name: "Avenir Next", size: 18)
    progressLbl?.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    progressLbl?.textAlignment = .center

    collecrionView?.addSubview(progressLbl!)
  }
  func removeProgressLbl() {
    if progressLbl != nil {
      progressLbl?.removeFromSuperview()
    }
  }
  
  @IBAction func centerMapBtnWasPressed(_ sender: Any) {
    if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
      centerMapOnUserLocation()
    }

  }
  
}
extension MapVC: MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    if annotation is MKUserLocation {
      return nil
    }
    
    var pinAnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
    pinAnotation.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
    pinAnotation.animatesDrop = true
    return pinAnotation
  }
  
  func centerMapOnUserLocation() {
    guard let coordinate = locationManager.location?.coordinate else { return }
    
    let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
    
    mapView.setRegion(coordinateRegion, animated: true)
  }
             // поставить метку
  @objc func dropPin(sender: UITapGestureRecognizer) {
    
    removePin()
    removeSpinner()
    removeProgressLbl()
    
    animateViewUp()
    addSwipe()
    addSpinner()
    addProgressLbl()
    
       // координаты места на карте
    let touchPoint = sender.location(in: mapView)
    let touchCoordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
    
    let annotation = DroppablePin(coordinate: touchCoordinate, identifier: "droppablePin")
    mapView.addAnnotation(annotation)
    
    print(flickerUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40))
    
    let coordinateRegion = MKCoordinateRegion(center: touchCoordinate, latitudinalMeters: regionRadius * 2.0, longitudinalMeters: regionRadius * 2.0)
    mapView.setRegion(coordinateRegion, animated: true)
  }
  
  func removePin() {
    for annotation in mapView.annotations {
      mapView.removeAnnotation(annotation)
    }
  }
}

extension MapVC: CLLocationManagerDelegate {
  
  func configureLocationServices() {
    if authorizationStatus == .notDetermined {
      
      locationManager.requestAlwaysAuthorization()
    } else {
      return
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    centerMapOnUserLocation()
  }
}

extension MapVC: UICollectionViewDelegate, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return 4
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collecrionView?.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath)
    
    return cell!
  }
  
  
  
}




