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
    var currentLocation = CLLocation?()
    var url = NSURL()
    var divvyBikesDic = NSDictionary()
    let bikesAnnotaion = MKPointAnnotation()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "SF Bikes"

        requestLocation()
        bikeTableView.separatorStyle = .None
        if let curLoc = currentLocation {

            centerMapOnLocation(curLoc)
            addBikeStationsToMap()
            loadBikes()
        }
    }

    override func viewDidAppear(animated: Bool) {

        bikeTableView.reloadData()
    }

    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {

        locationManager.startUpdatingLocation()
        addBikeStationsToMap()
        loadBikes()
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)

        bikeMapView.setRegion(coordinateRegion, animated: true)
    }

    func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {

        if let loc = userLocation.location {

            centerMapOnLocation(loc)
        }
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let currentLoc = locations.first {

            currentLocation = currentLoc
            if currentLoc.verticalAccuracy < 1000 && currentLoc.horizontalAccuracy < 1000 {

                locationManager.stopUpdatingLocation()
            }

            else {

                print("No bikes found")
            }
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

                    if let currLoc = self.currentLocation {

                           let bike = Bike(bikeDictionary: divvyBike, userLocation: currLoc)
                        self.bikes.append(bike)
                    }
                }

                self.bikes.sortInPlace({ $0.distance < $1.distance})

                dispatch_async(dispatch_get_main_queue(), { () -> Void in
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
        cell.cellBikesAvailable.text = "Available Bikes: \(bike.bikes)"

        if let currLoc = self.currentLocation {

            let distance = bike.coordinate.distanceFromLocation(currLoc)
            let miles = distance * 0.000621371
            let bikeMiles = Double(round(10 * miles)/10)

            cell.cellDistanceLabel.text = "\(bikeMiles) mi"
        }
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

            if let currLoc = self.currentLocation {

                detailView.currentLocation = currLoc
            }
        }
        
        if segue.identifier == "bikeCellSegue" {
            
            let detailView = segue.destinationViewController as! DetailViewController
            let bike = bikes[(bikeTableView.indexPathForSelectedRow?.row)!]
            detailView.selectedBikeStation = bike

            if let currLoc = self.currentLocation {

                detailView.currentLocation = currLoc
            }
        }
    }
}

func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    
    print(error)
}

class BikePointAnnotation : MKPointAnnotation {
    
    var bikeStation : Bike!
}
