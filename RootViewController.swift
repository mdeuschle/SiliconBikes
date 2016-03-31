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

    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let bikesAnnotaion = MKPointAnnotation()

    var timer = NSTimer()

    var locationFound = false

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Silicon Bikes"
        bikeTableView.separatorStyle = .None

        requestLocation()
        print(bikes)

        if locationFound {

            downloadBikeStations()
        } else {

            timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: #selector(RootViewController.downloadBikeStations), userInfo: nil, repeats: false)
        }
    }

    override func viewDidAppear(animated: Bool) {

        bikeTableView.reloadData()
    }

    func requestLocation() {

        locationManager.requestWhenInUseAuthorization()
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }

    func downloadBikeStations() {

        let url = NSURL(string: "http://www.bayareabikeshare.com/stations/json")!
        let session = NSURLSession.sharedSession()

        session.dataTaskWithURL(url) { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            do {
                if let bikeStationData = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as? [String:AnyObject] {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.configureData(bikeStationData)
                    })
                }
            } catch {}
            }.resume()
    }

    func configureData(data: [String:AnyObject]) {

        let results = data["stationBeanList"] as! [[String:AnyObject]]

        for bikestation in results {
            let newBikeStation = Bike()
            newBikeStation.initWithData(bikestation, currentLocation: self.currentLocation)
            bikes.append(newBikeStation)
            bikeTableView.reloadData()
        }
        bikes.sortInPlace({ $0.0.distance < $0.1.distance })
        dropPins()
    }

    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, 1000, 1000)

        bikeMapView.setRegion(coordinateRegion, animated: true)
    }


    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        if let currentLoc = locations.first {

            currentLocation = currentLoc
            locationFound = true
            bikeTableView.reloadData()

            if currentLoc.verticalAccuracy < 1000 && currentLoc.horizontalAccuracy < 1000 {

                locationManager.stopUpdatingLocation()
                centerMapOnLocation(currentLocation)
            }
        }
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

    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {

        if annotation.isEqual(mapView.userLocation) {
            return nil }

        let mapPin = MKAnnotationView()
        mapPin.canShowCallout = true
        mapPin.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        mapPin.image = UIImage(named: "bikePin")
        return mapPin
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return bikes.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! TableViewCell

        let bike: Bike!

        bike = bikes[indexPath.row]

        cell.cellAddressLabel.text = bike.name
        cell.cellBikesAvailable.text = "Available Bikes: \(bike.bikes)"

        let distance = self.currentLocation.distanceFromLocation(CLLocation(latitude: bike.lat, longitude: bike.lon))

        let miles = distance * 0.000621371
        let bikeMiles = Double(round(10 * miles)/10)

        cell.cellDistanceLabel.text = "\(bikeMiles) mi"

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        bikeTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "bikeDetailSegue" {

            let detailView = segue.destinationViewController as! DetailViewController
            let selectedPoint = bikeMapView.selectedAnnotations.first as! BikePointAnnotation
            detailView.selectedBikeStation = selectedPoint.bikeStation
            detailView.currentLocation = self.currentLocation
        }

        if segue.identifier == "bikeCellSegue" {

            let detailView = segue.destinationViewController as! DetailViewController
            let bike = bikes[(bikeTableView.indexPathForSelectedRow?.row)!]
            detailView.selectedBikeStation = bike
            detailView.currentLocation = self.currentLocation
        }
    }
}

func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
    
    print(error.localizedDescription)
}

class BikePointAnnotation : MKPointAnnotation {
    
    var bikeStation : Bike!
}
