//
//  Network.swift
//  WadizSearch
//

import Foundation

enum NetworkError: Error {
    case unknown
    case invalidRequest
    case jsonError
    case serverError
}

struct NetworkRequest<T: Codable & NetworkResponse> {

    private let path: String
    private let parameters: [String: String]

    init(path: String, parameters: [String: String]) {
        self.path = path
        self.parameters = parameters
    }

    func get(completion: @escaping (Result<T, NetworkError>) -> Void) {
        var urlComponents = URLComponents(string: API.host + path)
        urlComponents?.setQueryItems(with: parameters)

        guard let url = urlComponents?.url else {
            completion(.failure(.invalidRequest))
            return
        }

        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                completion(.failure(.serverError))
                return
            }

            guard let data = data else {
                completion(.failure(.unknown))
                return
            }

            do {
                let json: T = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async {
                    completion(json.statusCode == 200 ? .success(json) : .failure(.serverError))
                }
            } catch {
                completion(.failure(.jsonError))
            }
        }).resume()
    }
}

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        self.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
