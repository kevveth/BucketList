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
    @State private var viewModel = ViewModel()
    
    var body: some View {
        if viewModel.isUnlocked {
            VStack {
                MapReader { proxy in
                    Map(initialPosition: viewModel.startPosition) {
                        ForEach(viewModel.locations) { location in
                            Annotation(location.name, coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)) {
                                Image(systemName: "star.circle")
                                    .resizable()
                                    .foregroundStyle(.red)
                                    .frame(width: 44, height: 44)
                                    .background(.white)
                                    .clipShape(.circle)
                                    .onLongPressGesture {
                                        viewModel.selectedPlace = location
                                    }
                            }
                        }
                    }
                    .mapStyle(viewModel.mapMode)
                    .navigationTitle("BucketList")
                    .navigationBarTitleDisplayMode(.inline)
                    .onTapGesture { position in
                        if let coordinate = proxy.convert(position, from: .local) {
                            viewModel.addLocation(at: coordinate)
                        }
                    }
                    .sheet(item: $viewModel.selectedPlace) { place in
                        EditView(location: place) {
                            viewModel.update(location: $0)
                        }
                    }
                    .toolbar {
                        ToolbarItem {
                            Button("Toggle Map Mode", systemImage: "arrow.up.arrow.down") {
                                viewModel.isStandardMap.toggle()
                            }
                        }
                    }
                }
            }
        } else {
            // button here
            Button("Unlock Places", action: viewModel.authenticate)
                .padding()
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.capsule)
        }
    }
}

#Preview {
    MapView()
}
