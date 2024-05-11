//
//  LoadingView.swift
//  BucketList
//
//  Created by Kenneth Oliver Rathbun on 5/10/24.
//

import SwiftUI

enum LoadingState: String, CaseIterable {
    case loaded = "Loaded"
    case loading = "Loading"
    case failed = "Failed"
}

struct LoadStateView: View {
    @State private var loadingState: LoadingState = .loading
    
    var body: some View {
        VStack {
            switch loadingState {
            case .loading:
                LoadingView()
            case .loaded:
                LoadedView()
            case .failed:
                FailedView()
            }
            
            Picker("Loading State", selection: $loadingState) {
                ForEach(LoadingState.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        Text("Loading...")
    }
}

struct LoadedView: View {
    var body: some View {
        Text("Success!")
    }
}

struct FailedView: View {
    var body: some View {
        Text("Failed")
    }
}

#Preview {
    LoadStateView()
}
