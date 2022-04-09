//
//  API.swift
//  WadizSearch
//

import Foundation

enum API {
    static let host: String = "https://nr89frnqk0.execute-api.ap-northeast-2.amazonaws.com/dev"

    /// 검색 API 호출
    ///
    /// - parameter keyword: 검색 키워드
    /// - returns: 키워드에 대한 검색 결과
    static func search(keyword: String) -> NetworkRequest<SearchResponse> {
        NetworkRequest<SearchResponse>(path: "/search", parameters: ["keyword": keyword])
    }
}
