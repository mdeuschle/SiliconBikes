//
//  DetailViewController.swift
//  BikeFindr
//
//  Created by Matt Deuschle on 3/20/16.
//  Copyright © 2016 Matt Deuschle. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, MKMapViewDelegate {

    var selectedBikeStation: Bike!

    let locationManager = CLLocationManager()
    var currentLocation = CLLocation()
    let bikesAnnotaion = MKPointAnnotation()

    @IBOutlet var detailMapView: MKMapView!
    @IBOutlet var detailTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = selectedBikeStation.name
    }

    override func viewDidAppear(animated: Bool) {

        setUpMapViewStart()
        dropPins()
    }

    func setUpMapViewStart() {

        let sanFranCord = CLLocationCoordinate2D(latitude: selectedBikeStation.lat, longitude: selectedBikeStation.lon)
        detailMapView.setRegion(MKCoordinateRegionMake(sanFranCord, MKCoordinateSpanMake(0.015, 0.015)), animated: true)
    }

    func dropPins() {

        let newPin = BikePointAnnotation()
        newPin.coordinate = selectedBikeStation.coordinate2D
        newPin.title = selectedBikeStation.name
        newPin.subtitle = "Bikes Available: \(selectedBikeStation.bikes)"
        newPin.bikeStation = selectedBikeStation

        detailMapView.addAnnotation(newPin)
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

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {

        print(error)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("CellID") as! DetailTableViewCell

        cell.addressLabel.text = selectedBikeStation.name
        cell.bikesAvailableLabel.text = "Available Bikes: \(selectedBikeStation.bikes)"

        var available = ""

        if selectedBikeStation.renting == true {

            available = "In Service?: Yes"
        }

        else {

            available = "In Service?: No"
        }

        cell.inServiceLabel.text = available

        let distance = self.currentLocation.distanceFromLocation(CLLocation(latitude: selectedBikeStation.lat, longitude: selectedBikeStation.lon))

        let miles = distance * 0.000621371
        let bikeMiles = Double(round(10 * miles)/10)

        cell.milesLabel.text = "\(bikeMiles) mi"

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
                 calloutAccessoryControlTapped control: UIControl) {

        bikeStationDirections(selectedBikeStation.lat, lon: selectedBikeStation.lon)

    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        bikeStationDirections(selectedBikeStation.lat, lon: selectedBikeStation.lon)

    }

    func bikeStationDirections(lat: Double, lon: Double) {

          UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/maps?daddr=\(String(lat)),\(String(lon))")!)
    }
}

class DetailPointAnnotation : MKPointAnnotation {
    
    var bikeStation : Bike!
}

