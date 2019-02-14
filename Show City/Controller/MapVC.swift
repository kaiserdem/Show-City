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
import Alamofire
import AlamofireImage

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
  
  var imageUrlArray = [String]()
  var imageArray = [UIImage]()
  
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
    cancelAllSession()
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
    progressLbl?.font = UIFont(name: "Avenir Next", size: 14)
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
    cancelAllSession()
    
    imageUrlArray = []
    imageArray = []
    
    collecrionView?.reloadData()
    
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
    
    retrieveUrls(forAnnotation: annotation) { (finished) in
      if finished {
        self.retriveImages(handler: { (finished) in
          if finished {
            self.removeSpinner()
            self.removeProgressLbl()
            self.collecrionView?.reloadData()
          }
        })
      }
    }
  }
  
  func removePin() {
    for annotation in mapView.annotations {
      mapView.removeAnnotation(annotation)
    }
  }
        // разобрать полученую сслку
  func retrieveUrls(forAnnotation annotation: DroppablePin, handler: @escaping(_ status: Bool) -> ()) {
    Alamofire.request(flickerUrl(forApiKey: apiKey, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
      guard let jason = response.result.value as? Dictionary<String, AnyObject> else { return }
      let photosDict = jason["photos"] as! Dictionary<String, AnyObject>
      let photosDictArray = photosDict["photo"] as! [Dictionary<String, AnyObject>]
      for photo in photosDictArray {
        let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)_\(photo["secret"]!)_h_d.jpg"
        self.imageUrlArray.append(postUrl)
      }
      handler(true)
    }
  }
  // извлеч фото
  func retriveImages(handler: @escaping(_ status: Bool) -> ()) {
    for url in imageUrlArray {
      Alamofire.request(url).responseImage { (response) in
        guard let image = response.result.value else { return }
        self.imageArray.append(image)
        self.progressLbl?.text = "\(self.imageArray.count)/40 IMAGE DOWNLOADED"
        
        if self.imageArray.count == self.imageUrlArray.count {
          handler(true)
        }
      }
    }
  }
  func cancelAllSession() { // завершить
    Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
      sessionDataTask.forEach({ $0.cancel() })
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
    return imageArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    guard let cell = collecrionView?.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else { return UICollectionViewCell () }
    let imageFromIndex = imageArray[indexPath.row]
    let imageView = UIImageView(image: imageFromIndex)
    cell.addSubview(imageView)
    return cell
  }
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard let popVC = storyboard?.instantiateViewController(withIdentifier: "PopVC") as? PopVC else { return }
    popVC.initData(forImage: imageArray[indexPath.row])
    present(popVC, animated: true, completion: nil)
    }
  
  
}




