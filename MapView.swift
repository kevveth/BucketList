//
//  MapView.swift
//  BucketList
//
//  Created by Kenneth Oliver Rathbun on 5/10/24.
//

import Foundation
import SwiftUI
import MapKit

struct MapView: View {
    @State private var startPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            // San Diego
            center: CLLocationCoordinate2D(latitude: 32.7157, longitude: -117.1611),
            span: MKCoordinateSpan(latitudeDelta: 10, longitudeDelta: 10)
        )
    )
    
    //    let locations = [
    //        // 32.734716598885875, -117.14454537432057
    //        Location(name: "Balboa Park", coordinates: CLLocationCoordinate2D(latitude: 32.7347, longitude: -117.1445)),
    //        // 32.857783225798926, -117.2577201526877
    //        Location(name: "La Jolla Shores", coordinates: CLLocationCoordinate2D(latitude: 32.8578, longitude: -117.2577))
    //    ]
    
    @State private var locations = [Location]()
    @State private var selectedPlace: Location?
    
    var body: some View {
        VStack {
            MapReader { proxy in
                Map(initialPosition: startPosition) {
                    ForEach(locations) { location in
                        Annotation(location.name, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                            Image(systemName: "star.circle")
                                .resizable()
                                .foregroundStyle(.red)
                                .frame(width: 44, height: 44)
                                .background(.white)
                                .clipShape(.circle)
                                .onLongPressGesture {
                                    selectedPlace = location
                                }
                        }
                    }
                }
                .onTapGesture { position in
                    if let coordinate = proxy.convert(position, from: .local) {
                        let newLocation = Location(id: UUID(), name: "New Location", description: "", latitude: coordinate.latitude, longitude: coordinate.longitude)
                        locations.append(newLocation)
                    }
                }
                .sheet(item: $selectedPlace) { place in
                    EditView(location: place) { newLocation in
                        if let index = locations.firstIndex(of: place) {
                            locations[index] = newLocation
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    MapView()
}
