//
//  Results.swift
//  PhotoAlbum
//
//  Created by Carlos Guedes on 15/03/2019.
//  Copyright © 2019 Carlos Guedes. All rights reserved.
//

import Foundation
import UIKit

class Results {
    var date: Date
    var result: String
    var latitude: Double
    var longitude: Double
    
    init(date:Date, result:String, latitude: Double, longitude: Double) {
        self.date = date
        self.result = result
        self.latitude = latitude
        self.longitude = longitude
    }
}
