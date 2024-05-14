//
//  EditView-ViewModel.swift
//  BucketList
//
//  Created by Kenneth Oliver Rathbun on 5/13/24.
//

import Foundation
import SwiftUI

extension EditView {
    @Observable
    class ViewModel {
        var location: Location
        
        var name: String
        var description: String
        
        var loadingState: LoadingState = .loading
        var pages: [Page] = []
        
        init(location: Location) {
            self.location = location
            self.name = location.name
            self.description = location.description
        }
        
        func addNewLocation(onSave: (Location) -> Void) {
            var newLocation = location
            newLocation.id = UUID()
            newLocation.name = name
            newLocation.description = description
            
            onSave(newLocation)
        }
        
        func fetchNearbyPlaces() async {
            var components = URLComponents()
            components.scheme = "https"
            components.host = "en.wikipedia.org"
            components.path = "/w/api.php"
            components.queryItems = [
                URLQueryItem(name: "ggscoord", value: "\(location.latitude)|\(location.longitude)"),
                URLQueryItem(name: "action", value: "query"),
                URLQueryItem(name: "prop", value: "coordinates|pageimages|pageterms"),
                URLQueryItem(name: "colimit", value: "50"),
                URLQueryItem(name: "piprop", value: "thumbnail"),
                URLQueryItem(name: "pithumbsize", value: "500"),
                URLQueryItem(name: "pilimit", value: "50"),
                URLQueryItem(name: "wbptterms", value: "description"),
                URLQueryItem(name: "generator", value: "geosearch"),
                URLQueryItem(name: "ggsradius", value: "10000"),
                URLQueryItem(name: "ggslimit", value: "50"),
                URLQueryItem(name: "format", value: "json")
            ]
            
            guard let url = components.url else {
                print("Bad URL: \(components.description)")
                return
            }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Got some data back
                let items = try JSONDecoder().decode(Result.self, from: data)
                
                // Success - Convert the array values to the pages array
                pages = items.query.pages.values.sorted()
                loadingState = .loaded
            } catch {
                loadingState = .failed
            }
        }
    }
}

struct Result: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Int: Page]
}

struct Page: Codable, Comparable {
    enum CodingKeys: String, CodingKey {
        case pageID = "pageid"
        case title
        case terms
    }
    
    let pageID: Int
    let title: String
    let terms: [String: [String]]?
    
    var description: String {
        terms?["description"]?.first ?? "No further information."
    }
    
    static func <(lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
}
