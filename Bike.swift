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

    // properties
    var name           = ""
    var bikes          = 0
    var lat            = 0.0
    var lon            = 0.0
    var status         = ""
    var city           = ""
    var location       = ""
    var distance       = 0.0
    var coordinate     = CLLocation()
    var coordinate2D     = CLLocationCoordinate2D()
    var renting        = Bool()

    // init
    init(bikeDictionary: NSDictionary, userLocation: CLLocation) {

        self.name      = bikeDictionary["stAddress1"] as! String
        self.bikes     = bikeDictionary["availableBikes"] as! Int
        self.lat       = bikeDictionary["latitude"] as! Double
        self.lon       = bikeDictionary["longitude"] as! Double
        self.status    = bikeDictionary["statusValue"] as! String
        self.city      = bikeDictionary["city"] as! String
        self.location  = bikeDictionary["location"] as! String
        self.distance  = userLocation.distanceFromLocation(CLLocation(latitude: lat, longitude: lon))
        self.renting   = bikeDictionary["renting"] as! Bool

        self.coordinate = CLLocation(latitude: lat, longitude: lon)
        self.coordinate2D   = CLLocationCoordinate2DMake(lat, lon)
    }
}



