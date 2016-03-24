//
//  TableViewCell.swift
//  BikeFindr
//
//  Created by Matt Deuschle on 3/18/16.
//  Copyright © 2016 Matt Deuschle. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var cellAddressLabel: UILabel!
    @IBOutlet var cellBikesAvailable: UILabel!
    @IBOutlet var cellDistanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
