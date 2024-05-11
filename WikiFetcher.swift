//
//  WikiFetcher.swift
//  BucketList
//
//  Created by Kenneth Oliver Rathbun on 5/11/24.
//

import Foundation
import SwiftUI

struct WikiFetcher {
    var location: Location
    var loadingState: Binding<LoadingState>
    
    func fetchNearbyPlaces() async -> [Page] {
        var pages = [Page]()
        
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
            return []
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Got some data back
            let items = try JSONDecoder().decode(Result.self, from: data)
            
            // Success - Convert the array values to the pages array
            pages = items.query.pages.values.sorted { $0.title < $1.title }
            loadingState.wrappedValue = .loaded
        } catch {
            loadingState.wrappedValue = .failed
        }
        
        return pages
    }
}

struct Result: Codable {
    let query: Query
}

struct Query: Codable {
    let pages: [Int: Page]
}

struct Page: Codable {
    enum CodingKeys: String, CodingKey {
        case pageID = "pageid"
        case title
        case terms
    }
    
    let pageID: Int
    let title: String
    let terms: [String: [String]]?
}
