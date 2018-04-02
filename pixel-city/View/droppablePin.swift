//
//  droppablePin.swift
//  pixel-city
//
//  Created by Patrik Kemeny on 2/4/18.
//  Copyright © 2018 Patrik Kemeny. All rights reserved.
//

import UIKit
import MapKit


class DroppablePin: NSObject, MKAnnotation{
    
    dynamic  var coordinate: CLLocationCoordinate2D //need to be dynamic
    var indentifier: String
    
    init(coordinate: CLLocationCoordinate2D, indentifier: String){
        self.coordinate = coordinate
        self.indentifier = indentifier
        super.init()
    }
    
    
}

