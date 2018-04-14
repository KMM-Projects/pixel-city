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
import Alamofire
import AlamofireImage

class MapVC: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var pullUpViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pullUpView: UIView!
    
    
    var locationManager = CLLocationManager()
    let authorizationStatus = CLLocationManager.authorizationStatus() // const  info if we are authorized to check location
    let regionRadius: Double = 1000
    var screenSize =  UIScreen.main.bounds
    var spinner: UIActivityIndicatorView?
    var progressLabel:UILabel? // not i itialized now
    
    //collectionView for the pictures
    var collectionView: UICollectionView? //not yet extantionated
    var flowLayout = UICollectionViewFlowLayout() // if we are creating collectionView programaticly we need this
    
    
    //images
    var ImageUrlArray = [String]()
    var ImageArray = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self //now we can use the mapview here
        locationManager.delegate = self // check out the extentions without the extention it will not work
        configureLocationServices()
        addDoubleTap()
        
       
       //view.bounds = mean big as the view
        //flowlayout never use just nedded for initioalization
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: flowLayout)
        collectionView?.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
        collectionView?.delegate
        collectionView?.dataSource // bc the error we need to extentionate check the bottoom
        collectionView?.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        pullUpView.addSubview(collectionView!) // add the collectionView into pullupView
    }
    
    //func that swipe down the view  with pictures
    func addSwipe(){
        let swipe =  UISwipeGestureRecognizer(target: self, action: #selector(animateViewDown))
        swipe.direction = .down //direction of the swipe
        pullUpView.addGestureRecognizer(swipe)
    }
    
    func animateViewUp(){
        //set up new constraints
        pullUpViewHeightConstraint.constant = 300
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded() //redraw the new constant
            //put inside this closure bc i wana see the 
        }
        
    }
    
    @objc func animateViewDown(){
        cancelAppSessions()
        pullUpViewHeightConstraint.constant = 1
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    func addDoubleTap(){
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(dropPin(sender: )))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.delegate = self
        mapView.addGestureRecognizer(doubleTap)
    }

    func addSpineer(){
        spinner = UIActivityIndicatorView() //extentionated from UIActivity Indicator
        //we need to set couple of things
        spinner?.center = CGPoint(x: (screenSize.width / 2)-((spinner?.frame.width)! / 2), y: 150)   //point on screen
        spinner?.activityIndicatorViewStyle = .whiteLarge
        spinner?.color = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        spinner?.startAnimating()
       // pullUpView.addSubview(spinner!) //force unwrape and send to the midlle of the screen
        //after i added a collection view i wanna have it in front of collectionView
        collectionView?.addSubview(spinner!)
    }
    
    func removeSpinner(){
        if spinner != nil {
            spinner?.removeFromSuperview()
        }
    }
    
    func addProgressLabel(){
        progressLabel = UILabel()
        progressLabel?.frame = CGRect(x: (screenSize.width / 2) - 120, y: 175, width: 200, height: 40) //add a frame to know how big
        //it will be , a75 je 25 under the spinner
        progressLabel?.font = UIFont(name: "Avenir Next", size: 18)
        progressLabel?.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        //progressLabel?.text = "12/40 Photos Loaded"
        progressLabel?.textAlignment = .center
       // pullUpView.addSubview(progressLabel!)
        //after adding the collection view i dont want to have it covered so i put it in fornt of colelctionview
        collectionView?.addSubview(progressLabel!)
        
    }
    
    func removeProgressLabel(){
        if progressLabel != nil {
            progressLabel?.removeFromSuperview()
        }
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
        removeSpinner()
        removeProgressLabel()
        cancelAppSessions()
        
        animateViewUp()
        
        ImageUrlArray = []
        ImageArray = []
        
        collectionView?.reloadData()
       
        addSwipe()
        addSpineer()
        addProgressLabel()
        
        
        let touchPoint = sender.location(in: mapView)
        print(touchPoint) // screen coordinates
        //convert touhcpoint into coordinates on map
        let touchCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        let annotation = DroppablePin(coordinate: touchCoordinates, indentifier: "DroppablePin")
        mapView.addAnnotation(annotation)
        
        print(flickUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40))
        //drop pin on the map
        
        //center the map to pin
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(touchCoordinates, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
        
        retrieveUrls(forAnnotation: annotation) { (finished) in
            print(self.ImageUrlArray)
            //shoul print https://farm1.staticflickr.com/878/27417686408/fd14946aa7_k_d.jpeg
            if finished {
                self.retrieveImages(handler: { (finished) in
                    if finished {
                        //hide the spinner and reload colection view and hide label
                        self.removePin()
                        self.removeProgressLabel()
                        self.collectionView?.reloadData()
                    }
                })
            }
        }
    }
    
    func removePin(){
        for annotaion in mapView.annotations {
            mapView.removeAnnotation(annotaion)
        }
    }
    
    //wee need to have a completion handler to know when we finished puling
    func retrieveUrls(forAnnotation annotation:DroppablePin, handler: @escaping (_ status: Bool) -> ()){
        //completion handler handler: @escaping (_ status: Bool) -> ())
        //name handler .. @escaping is sending us to function wich terieve nothing, the "_" bc we are not allowed to use names
        
        
        Alamofire.request(flickUrl(forApiKey: API_KEY, withAnnotation: annotation, andNumberOfPhotos: 40)).responseJSON { (response) in
            print(response)
            // the response is dictionary inside is an array of dictionaries
            guard let json = response.result.value as? Dictionary<String,AnyObject> else {return}
            let photosDict = json["photos"] as! Dictionary<String,AnyObject> //bring out the photos
            let photosDictArray = photosDict["photo"] as! [Dictionary<String,AnyObject>]
            for photo in photosDictArray {
                let postUrl = "https://farm\(photo["farm"]!).staticflickr.com/\(photo["server"]!)/\(photo["id"]!)/\(photo["secret"]!)_h_d.jpg"
                self.ImageUrlArray.append(postUrl)
            }
            handler(true)
            
            
//SUCCESS: {
//            photos =     {
//                page = 1;
//                pages = 17999;
//                perpage = 40;
//                photo =         (
//                    {
//                        farm = 1;
//                        id = 41305421871;
//                        isfamily = 0;
//                        isfriend = 0;
//                        ispublic = 1;
//                        owner = "64684255@N00";
//                        secret = 9edbdbdf2e;
//                        server = 801;
//                        title = "And yes, Transbay photo means we came up to the city again to work on the condo";
//                },
//                    {
//                        farm = 1;
//                        id = 41262882692;
//                        isfamily = 0;
//                        isfriend = 0;
//                        ispublic = 1;
//                        owner = "64684255@N00";
//                        secret = 8de36d15e4;
//                        server = 881;
//                        title = "Work on the new Transbay Terminal is coming along #sf";
//                },
//
        }
        
        
    }
    func retrieveImages(handler: @escaping (_ status:Bool) -> ()){ // we do not need to return anything we just need to know that we finished with the pictures downloading
       
        for url in ImageUrlArray { //go thrue all of the imageurl and create alamofile request to download the image
            Alamofire.request(url).responseImage(completionHandler: { (response) in //response is type Image
                guard let image = response.result.value else {return}
                self.ImageArray.append(image)//image is type Image and  ImageArray is type UIImage
                self.progressLabel?.text = "\(self.ImageArray.count)/40  Images Downloaded"
                
                //check
                if self.ImageArray.count == self.ImageUrlArray.count {
                    handler(true)
                }
            })
            
        }
        
    }
    func cancelAppSessions(){
        Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (sessionDatatask, UploadData, DownloadData) in
            //cancel all session for Downloaddata ans sessiondatatask
            sessionDatatask.forEach({ $0.cancel() }) //single line forloop
            //for task in sessiondatatask { print.....task.cansel} we replace with $0
            DownloadData.forEach({ $0.cancel() })
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


extension MapVC: UICollectionViewDelegate,UICollectionViewDataSource {
    //here are 3 required functions
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //number of items in array
        return ImageArray.count
        
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as? PhotoCell else {return (UICollectionViewCell())}
        //create imageView and add as Subview
        let imageFromIndex = ImageArray[indexPath.row]
        let imageView = UIImageView(image: imageFromIndex)
        cell.addSubview(imageView) //now the cell have imageview
        return cell // return blank cell
        //need to reload the collectionView so go to droppin
    }
    
}








