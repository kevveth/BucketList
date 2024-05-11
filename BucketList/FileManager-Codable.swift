//
//  FileManager-Codable.swift
//  BucketList
//
//  Created by Kenneth Oliver Rathbun on 5/9/24.
//

import Foundation

extension FileManager {
    var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func write<T: Encodable>(_ data: T, to file: String, options: Data.WritingOptions = [.atomic, .completeFileProtection]) {
        let url = documentsDirectory.appendingPathComponent(file)
        let encoder = JSONEncoder()
        
        // Returns a Data type
        guard let encodedData = try? encoder.encode(data) else {
            fatalError("Failed to encode data")
        }
        
        do {
            try encodedData.write(to: url, options: options)
        } catch {
            fatalError("Failed to write data to \(url): \(error.localizedDescription)")
        }
    }
    
    func read<T: Decodable>(from file: String) -> T? {
        let url = documentsDirectory.appendingPathComponent(file)
        
        let decoder = JSONDecoder()
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load data from \(file)")
        }
        
        guard let decodedData = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(file)")
        }
        
        return decodedData
    }
    
    static var test: String {
        FileManager.default.write("Test Message #1", to: "sampledata.txt")
        let result: String = FileManager.default.read(from: "sampledata.txt")!
        return result
    }
}
