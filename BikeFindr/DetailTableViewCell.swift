//
//  DetailTableViewCell.swift
//  BikeFindr
//
//  Created by Matt Deuschle on 3/21/16.
//  Copyright © 2016 Matt Deuschle. All rights reserved.
//

import UIKit

class DetailTableViewCell: UITableViewCell {

    @IBOutlet var directionsLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var milesLabel: UILabel!
    @IBOutlet var inServiceLabel: UILabel!
    @IBOutlet var bikesAvailableLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
