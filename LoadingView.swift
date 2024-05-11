//
//  LoadingView.swift
//  BucketList
//
//  Created by Kenneth Oliver Rathbun on 5/10/24.
//

import SwiftUI

enum LoadingState: String, CaseIterable {
    case loading = "Loading"
    case success = "Success"
    case failed = "Failed"
}

struct LoadingView: View {
    @State private var loadingState: LoadingState = .loading
    
    var body: some View {
        VStack {
            switch loadingState {
            case .loading:
                LoadView()
            case .success:
                SuccessView()
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

struct LoadView: View {
    var body: some View {
        Text("Loading...")
    }
}

struct SuccessView: View {
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
    LoadingView()
}
