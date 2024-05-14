//
//  EditView.swift
//  BucketList
//
//  Created by Kenneth Oliver Rathbun on 5/10/24.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    var onSave: (Location) -> Void
    
    @State private var viewModel: ViewModel
    
    init(location: Location, onSave: @escaping (Location) -> Void) {
        _viewModel = State(initialValue: ViewModel(location: location))
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place Name", text: $viewModel.name)
                    TextField("Description", text: $viewModel.description)
                }
                
                Section("Nearby") {
                    switch viewModel.loadingState {
                    case .loaded:
                        ForEach(viewModel.pages, id: \.pageID) { page in
                            VStack(alignment: .leading) {
                                /*@START_MENU_TOKEN@*/Text(page.title)/*@END_MENU_TOKEN@*/
                                    .font(.headline)
                                Text(page.description.localizedCapitalized)
                                    .italic()
                            }
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
                    viewModel.addNewLocation(onSave: onSave)
                    dismiss()
                }
            }
            .task {
                await viewModel.fetchNearbyPlaces()
            }
        }
    }
}



#Preview {
    EditView(location: .example) { _ in }
}
