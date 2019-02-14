//
//  Constants.swift
//  Show City
//
//  Created by Kaiserdem on 14.02.2019.
//  Copyright © 2019 Kaiserdem. All rights reserved.
// 59ca8f94a069d822b5ad88a84fb51ac6


import Foundation

let apiKey = "6541ef03c19a5c531e367fa2deb9d774"

func flickerUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
  
  return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(number)&format=json&nojsoncallback=1"
  
}
