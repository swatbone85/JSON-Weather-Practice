//
//  JSON Model Objects.swift
//  JSON Weather Practice
//
//  Created by Thomas Swatland on 03/10/2017.
//  Copyright © 2017 Thomas Swatland. All rights reserved.
//

import Foundation

struct Forecast: Decodable {
    let latitude: Double
    let longitude: Double
    let currently: CurrentWeather
}

struct CurrentWeather: Decodable {
    let summary: String
    let icon: String
    let temperature: Double
    let humidity: Double
    let windSpeed: Double
}
