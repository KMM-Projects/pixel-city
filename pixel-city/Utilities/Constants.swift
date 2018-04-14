//
//  Constants.swift
//  pixel-city
//
//  Created by Patrik Kemeny on 8/4/18.
//  Copyright © 2018 Patrik Kemeny. All rights reserved.
//

import Foundation


let API_KEY = "114d3fe7c0c8dffd069190257e6bb3fa" //API key form flickt webside

func flickUrl(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String{
    
    let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
    print(url)
    return url
}


