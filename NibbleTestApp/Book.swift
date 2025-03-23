//
//  Book.swift
//  NibbleTestApp
//
//  Created by Maxim Potapov on 20.03.2025.
//

import Foundation

struct Book: Decodable, Equatable {
    let author: String
    let name: String
    let bookCover: String
    let chapters: [Chapter]
    
    enum CodingKeys: String, CodingKey {
        case author
        case name
        case bookCover = "cover_image"
        case chapters
    }
}

struct Chapter: Decodable, Equatable {
    let number: Int
    let title: String
    let audio: String?
    let image: String
    let summary: String
    
    enum CodingKeys: String, CodingKey {
        case number
        case title
        case audio = "audio_file"
        case image
        case summary
    }
}

class BookDataProvider {
    static func loadBookData(from filename: String) -> Book? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("JSON file not found: \(filename).json")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let book = try decoder.decode(Book.self, from: data)
            return book
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
}
