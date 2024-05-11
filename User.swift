//
//  Users.swift
//  BucketList
//
//  Created by Kenneth Oliver Rathbun on 5/10/24.
//

import Foundation

struct User: Identifiable, Comparable {
    let id = UUID()
    var firstName: String
    var lastName: String
    
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.lastName < rhs.lastName
    }
}

extension [User] {
    static let sampleUsers: [User] = [
        User(firstName: "Arnold", lastName: "Rimmer"),
        User(firstName: "Kristine", lastName: "Kochanski"),
        User(firstName: "David", lastName: "Lister"),
    ].sorted()
}
