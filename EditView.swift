//
//  EditView.swift
//  BucketList
//
//  Created by Kenneth Oliver Rathbun on 5/10/24.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    var location: Location
    
    @State private var name: String
    @State private var description: String
    
    var onSave: (Location) -> Void
    
    @State private var loadingState: LoadingState = .loading
    @State private var pages = [Page]()
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        self.location = location
        self.onSave = onSave
        
        _name = State(initialValue: location.name)
        _description = State(initialValue: location.description)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place Name", text: $name)
                    TextField("Description", text: $description)
                }
                
                Section("Nearby") {
                    switch loadingState {
                    case .loaded:
                        ForEach(pages, id: \.pageID) { page in
                            /*@START_MENU_TOKEN@*/Text(page.title)/*@END_MENU_TOKEN@*/
                                .font(.headline)
                            + Text(": ") +
                            Text("Page description here...")
                                .italic()
                        }
                    case .loading:
                        Text("Loading...")
                    case .failed:
                        Text("Please try again later.")
                    }
                }
            }
            .navigationTitle("Place Details")
            .toolbar {
                Button("Save") {
                    var newLocation = location
                    newLocation.id = UUID()
                    newLocation.name = name
                    newLocation.description = description
                    
                    onSave(newLocation)
                    dismiss()
                }
            }
            .task {
                await fetchNearbyPlaces()
            }
        }
    }
    
    func fetchNearbyPlaces() async {
//        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.coordinate.latitude)%7C\(location.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
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
            pages = items.query.pages.values.sorted { $0.title < $1.title }
            loadingState = .loaded
        } catch {
            loadingState = .failed
        }
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

#Preview {
    EditView(location: .example) { _ in }
}
