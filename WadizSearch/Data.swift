//
//  Data.swift
//  WadizSearch
//

import Foundation

protocol NetworkResponse {
    var statusCode: Int { get }
}

struct SearchResponse: NetworkResponse, Codable {
    let statusCode: Int
    let body: SearchResult
}

struct SearchResult: Codable {
    let list: [Product]
}

struct Product: Codable ,Identifiable{
    var id = UUID()
    let projectID: Int
    let title: String
    let type: ProductType
    let photoURL: String?
    let makerName: String
    let additionalInfo: String?
    let makerPage: String
    let category: Category?
    let price: Int?
    let landingURL: String
    let targetAmount: Int?
    let periodFinishDate: String?
    
    
    enum ProductType: String, Codable {
        case funding
        case fundingOpen
        case store
    }

    struct Category: Codable {
        let code: String
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case projectID = "projectId"
        case title
        case type
        case photoURL = "photoUrl"
        case makerName
        case additionalInfo
        case makerPage
        case category
        case price
        case landingURL = "landingUrl"
        case targetAmount
        case periodFinishDate
    }
}
