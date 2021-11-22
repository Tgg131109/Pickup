//
//  MKPlacemark_Extension.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/6/21.
//

import MapKit
import Contacts

extension MKPlacemark {
    var formattedAddress: String? {
        guard let postalAddress = postalAddress else { return nil }
        return CNPostalAddressFormatter.string(from: postalAddress, style: .mailingAddress).replacingOccurrences(of: "\n", with: " ")
    }
}
