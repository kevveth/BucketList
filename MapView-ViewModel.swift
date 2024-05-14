//
//  MapView-ViewModel.swift
//  BucketList
//
//  Created by Kenneth Oliver Rathbun on 5/11/24.
//

import Foundation
import LocalAuthentication
import SwiftUI
import MapKit

extension MapView {
    @Observable
    class ViewModel {
        var startPosition = MapCameraPosition.region(
            MKCoordinateRegion(
                // San Diego
                center: CLLocationCoordinate2D(latitude: 32.7157, longitude: -117.1611),
                span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
            )
        )
        
//        let locations = [
//            // 32.734716598885875, -117.14454537432057
//            Location(name: "Balboa Park", coordinates: CLLocationCoordinate2D(latitude: 32.7347, longitude: -117.1445)),
//            // 32.857783225798926, -117.2577201526877
//            Location(name: "La Jolla Shores", coordinates: CLLocationCoordinate2D(latitude: 32.8578, longitude: -117.2577))
//        ]
        
        private(set) var locations: [Location]
        var selectedPlace: Location?
        
        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")
        
        var isUnlocked = true
        var isStandardMap = true
        var mapMode: MapStyle {
            isStandardMap ? .standard : .hybrid
        }
        
        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }
        
        func addLocation(at point: CLLocationCoordinate2D) {
            let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: point.latitude, longitude: point.longitude)
            locations.append(newLocation)
            save()
        }
        
        func authenticate() {
            let context = LAContext()
            var error: NSError?
            
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, autheticationError in
                    if success {
                        self.isUnlocked = true
                    } else {
                        // error
                    }
                }
                
            } else {
                // no biometrics
            }
        }
        
        func update(location: Location) {
            guard let selectedPlace else { return }
            
            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
            }
            save()
        }
        
        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }
    }
}
