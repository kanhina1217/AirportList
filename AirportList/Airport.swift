//
//  Airport.swift
//  AirportList
//
//  Created by Kyoko Hobo on 2025/07/31.
//

import Foundation

struct Airport: Identifiable, Decodable, Equatable {
    let id: UUID = UUID()
    let name: String
    let city: String
    let country: String
    let iata: String
    let icao: String
    let latitude: Double
    let longitude: Double
    
    private enum CodingKeys: String, CodingKey {
        case name, city, country, iata, icao, latitude, longitude
    }
}
