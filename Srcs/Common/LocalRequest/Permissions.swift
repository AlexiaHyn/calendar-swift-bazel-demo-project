//
//  File.swift
//  CalendarProject
//
//  Created by Alexia Huang on 2024/11/18.
//

import Foundation
import CoreLocation

public class Permissions {
    public static let shared = Permissions()
    
    private var locManager = CLLocationManager()
    
    private init() {
        self.locManager.requestWhenInUseAuthorization()
    }
    
    public func getLocation() -> CLLocation? {
        var currentLocation: CLLocation?
        if (locManager.authorizationStatus == CLAuthorizationStatus.authorizedAlways ||
            locManager.authorizationStatus == CLAuthorizationStatus.authorizedWhenInUse) {
            currentLocation = locManager.location
        }
        return currentLocation
    }
}
