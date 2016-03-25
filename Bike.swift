//
//  Bike.swift
//  BikeFindr
//
//  Created by Matt Deuschle on 3/18/16.
//  Copyright © 2016 Matt Deuschle. All rights reserved.
//

import Foundation
import CoreLocation

class Bike {

    var name            = ""
    var bikes           = 0
    var lat             = 0.0
    var lon             = 0.0
    var status          = ""
    var city            = ""
    var location        = ""
    var distance        = 0.0
    var coordinate2D    = CLLocationCoordinate2D()
    var renting         = Bool()

    func initWithData(data: [String:AnyObject], currentLocation: CLLocation) {

        name            = data["stAddress1"] as! String
        bikes           = Int(data["availableBikes"] as! Int)
        lat             = Double(data["latitude"] as! Double)
        lon             = Double(data["longitude"] as! Double)
        status          = data["statusValue"] as! String
        city            = data["city"] as! String
        location        = data["location"] as! String
        distance        = currentLocation.distanceFromLocation(CLLocation(latitude: lat, longitude: lon))
        coordinate2D    = CLLocationCoordinate2DMake(lat, lon)
        renting         = Bool(data["renting"] as! Bool)
    }
}





