//
//  ViewController.swift
//  pixel-city
//
//  Created by Patrik Kemeny on 31/3/18.
//  Copyright © 2018 Patrik Kemeny. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation // for location services

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus() // const  info if we are authorized to check location
    let regionRadius: Double = 1000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self //now we can use the mapview here
        locationManager.delegate = self // check out the extentions without the extention it will not work
        configureLocationServices()
        addDoubleTap()
       
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender: )))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }

    @IBAction func centerMapButtonWasPressed(_ sender: Any) {
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            //if we have authorized our location than cenbter the map
            centerMapOnUserLocation()
            
        }
    }
}


extension MapVC: MKMapViewDelegate {
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //customize the pinc with custom color
        if annotation is MKUserLocation {
            return nil
        }
        let pinAnnotation = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DroppablePin")
        pinAnnotation.pinTintColor = #colorLiteral(red: 0.9647058824, green: 0.6509803922, blue: 0.137254902, alpha: 1)
        pinAnnotation.animatesDrop = true
        return pinAnnotation
    }
    
    func centerMapOnUserLocation(){
        guard let coordinates = locationManager.location?.coordinate else {return}
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinates, regionRadius * 2.0, regionRadius * 2.0)//center and how wide we are making a circle
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    @objc func dropPin(sender: UITapGestureRecognizer){ //where i tap will i convert to coordinates on the map
        print("pin was droped")
        removePin()
        //drop pin on the map
        let touchPoint = sender.location(in: mapView)
        print(touchPoint) // screen coordinates
        //convert touhcpoint into coordinates on map
        let touchCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCoordinates, indentifier: "DropablePin")
        mapView.addAnnotation(annotation)
        //center the map to pin
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinates, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func removePin(){
        for annotaion in mapView.annotations {
            mapView.removeAnnotation(annotaion)
        }
    }
}



extension MapVC: CLLocationManagerDelegate{
    func configureLocationServices(){
        //check to see if is our app authorise to check location or not
        //if not request the use location
        if authorizationStatus == .notDetermined { //it the app dont know
            locationManager.requestAlwaysAuthorization()
        } else { // deny or verify
            return 
        }
    }
    //checking the change to get the map in the centre of our location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
       ///anytime the map change authorization
        centerMapOnUserLocation()
    }
}









