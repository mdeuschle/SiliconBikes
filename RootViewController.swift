//
//  RootViewController.swift
//  BikeFindr
//
//  Created by Matt Deuschle on 3/18/16.
//  Copyright © 2016 Matt Deuschle. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class RootViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet var bikeMapView: MKMapView!
    @IBOutlet var bikeTableView: UITableView!

    var bikes = [Bike]()
    var bikesDic = [NSDictionary]()

    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    var url = NSURL()
    var divvyBikesDic = NSDictionary()
    let bikesAnnotaion = MKPointAnnotation()

    override func viewDidLoad() {
        super.viewDidLoad()

        requestLocation()
        loadBikes()
        addBikeStationsToMap()
        setUpMapViewStart()

        self.title = "SF Bikes"
    }

//    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
//        
//        setUpMapViewStart()
//
//    }

    func setUpMapViewStart() {
        
        let sanFranCord = CLLocationCoordinate2D(latitude: 37.7848382, longitude: -122.4048587)
        bikeMapView.setRegion(MKCoordinateRegionMake(sanFranCord, MKCoordinateSpanMake(0.035, 0.035)), animated: true)

//        bikeMapView.setCenterCoordinate((bikeMapView.userLocation.location?.coordinate)!, animated: true)
//
//
//        bikeMapView.region = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, 3000, 3000)
//        bikeMapView.setRegion(bikeMapView.region, animated: true)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let currentLoc = locations.first {

            currentLocation = currentLoc
        }

        if currentLocation.verticalAccuracy < 1000 && currentLocation.horizontalAccuracy < 1000 {

            locationManager.stopUpdatingLocation()
            print("Current location is: \(currentLocation)")
        }

        else {

            print("No bikes found")
        }
    }

    func loadBikes() {

        if let bikeURL = NSURL(string: "http://www.bayareabikeshare.com/stations/json") {

            url = bikeURL
        }

        else {

            print("Broken API")
        }

        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(url) { (data, response, error) -> Void in
            do {

                if let divvyBikes = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? NSDictionary {

                    self.divvyBikesDic = divvyBikes
                }
                else {

                    print("No API Available")
                }

                self.bikesDic = self.divvyBikesDic.objectForKey("stationBeanList") as! [NSDictionary]

                for divvyBike in self.bikesDic {

                    let bike = Bike(bikeDictionary: divvyBike, userLocation: self.currentLocation)

                    self.bikes.append(bike)
                }

                self.bikes.sortInPlace({ $0.distance < $1.distance})

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.bikeTableView.reloadData()
                    self.dropPins()
                })
            }

            catch let error as NSError{
                print("jsonError: \(error.localizedDescription)")
            }

            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.bikeTableView.reloadData()}
        }

        task.resume()
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! TableViewCell

        let bike = bikes[indexPath.row]

        cell.cellAddressLabel.text = bike.name
        cell.cellAddressLabelTwo.text = bike.location
        cell.cellBikesAvailable.text = "Available Bikes: \(bike.bikes)"

        let distance = bike.coordinate.distanceFromLocation(self.currentLocation)

        print(self.currentLocation)

        let miles = distance * 0.000621371
        let bikeMiles = Double(round(10 * miles)/10)

        cell.cellDistanceLabel.text = "\(bikeMiles) mi"

        return cell
    }

    func dropPins() {

        for bike in bikes {
            let newPin = BikePointAnnotation()
            newPin.coordinate = bike.coordinate2D
            newPin.title = bike.name
            newPin.subtitle = "Bikes Available: \(bike.bikes)"
            newPin.bikeStation = bike
            bikeMapView.addAnnotation(newPin)
        }
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {

        performSegueWithIdentifier("bikeDetailSegue", sender: nil)
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.bikes.count
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        bikeTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func requestLocation() {

        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }

    func addBikeStationsToMap() {

        bikeMapView.showsUserLocation = true

        for bikeStation in self.bikes {

            let annotation = MKPointAnnotation()
            annotation.coordinate = bikeStation.coordinate2D
            self.bikeMapView.addAnnotation(annotation)
        }
    }

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation.isEqual(mapView.userLocation) {
            return nil }

        let mapPin = MKAnnotationView()
        mapPin.canShowCallout = true
        mapPin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        mapPin.image = UIImage(named: "bikePin")
        return mapPin
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "bikeDetailSegue" {

            let detailView = segue.destinationViewController as! DetailViewController
            let selectedPoint = bikeMapView.selectedAnnotations.first as! BikePointAnnotation
            detailView.selectedBikeStation = selectedPoint.bikeStation

        }

        if segue.identifier == "bikeCellSegue" {

            let detailView = segue.destinationViewController as! DetailViewController
            let bike = bikes[(bikeTableView.indexPathForSelectedRow?.row)!]
            detailView.selectedBikeStation = bike
        }
    }
}

func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    
    print(error)
}

class BikePointAnnotation : MKPointAnnotation {
    
    var bikeStation : Bike!
}
