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
    var available = ""
    var bikeStationLat = ""
    var bikeStationLon = ""

    @IBOutlet var detailMapView: MKMapView!
    @IBOutlet var detailTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = selectedBikeStation.name
        requestLocation()
        setUpMapViewStart()
        dropPins()
        addBikeStationsToMap()
    }

    func setUpMapViewStart() {

        let sanFranCord = CLLocationCoordinate2D(latitude: selectedBikeStation.lat, longitude: selectedBikeStation.lon)
        detailMapView.setRegion(MKCoordinateRegionMake(sanFranCord, MKCoordinateSpanMake(0.035, 0.035)), animated: true)
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

    func dropPins() {

        let newPin = BikePointAnnotation()
        newPin.coordinate = selectedBikeStation.coordinate2D
        newPin.title = selectedBikeStation.name
        newPin.subtitle = "Bikes Available: \(selectedBikeStation.bikes)"
        newPin.bikeStation = selectedBikeStation
        detailMapView.addAnnotation(newPin)
    }

    func requestLocation() {

        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }

    func addBikeStationsToMap() {

        detailMapView.showsUserLocation = true

        let annotation = MKPointAnnotation()
        annotation.coordinate = selectedBikeStation.coordinate2D
        self.detailMapView.addAnnotation(annotation)
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

    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView,
        calloutAccessoryControlTapped control: UIControl) {

            let selectedLoc = view.annotation
            let currentLocMapItem = MKMapItem.mapItemForCurrentLocation()
            let selectedPlacemark = MKPlacemark(coordinate: selectedLoc!.coordinate, addressDictionary: nil)
            let selectedMapItem = MKMapItem(placemark: selectedPlacemark)
            let mapItems = [selectedMapItem, currentLocMapItem]
            let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

            MKMapItem.openMapsWithItems(mapItems, launchOptions:launchOptions)
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("CellID") as! DetailTableViewCell

        cell.addressLabel.text = selectedBikeStation.name
        cell.bikesAvailableLabel.text = "Available Bikes: \(selectedBikeStation.bikes)"

        if selectedBikeStation.renting == true {

            available = "In Service?: Yes"
        }

        else {

            available = "In Service?: No"
        }

        cell.inServiceLabel.text = available

        let distance = selectedBikeStation.coordinate.distanceFromLocation(self.currentLocation)

        print(self.currentLocation)

        let miles = distance * 0.000621371
        let bikeMiles = Double(round(10 * miles)/10)

        cell.milesLabel.text = "\(bikeMiles) mi"

        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 1
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        bikeStationLat = String(selectedBikeStation.lat)
        bikeStationLon = String(selectedBikeStation.lon)
        UIApplication.sharedApplication().openURL(NSURL(string: "http://maps.apple.com/maps?daddr=\(bikeStationLat),\(bikeStationLon)")!)

        detailTableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

class DetailPointAnnotation : MKPointAnnotation {
    var bikeStation : Bike!
}

