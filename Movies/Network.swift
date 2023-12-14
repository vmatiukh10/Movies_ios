//
//  Network.swift
//  Movies
//
//  Created by Volodymyr Matiukh on 14.12.2023.
//

import Foundation

struct PagingResponse<T: Codable>: Codable {
    enum CodingKeys: String, CodingKey {
        case page, results, totalPages = "total_pages", totalResults = "total_results"
    }
    let page: Int
    let results: T
    let totaPages: Int
    let totalResults: Int
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.page = try values.decode(Int.self, forKey: .page)
        self.totaPages = try values.decode(Int.self, forKey: .totalPages)
        self.totalResults = try values.decode(Int.self, forKey: .totalResults)
        self.results = try values.decode(T.self, forKey: .results)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(page, forKey: .page)
        try container.encode(totaPages, forKey: .totalPages)
        try container.encode(totalResults, forKey: .totalResults)
        try container.encode(results, forKey: .results)
    }
}

class Network {
    
    private let session = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.requestCachePolicy = .useProtocolCachePolicy
        return URLSession(configuration: configuration)
    }()
    
    private let baseURL = "https://api.themoviedb.org/3/"
    
    enum Path: String {
        case popularMovies = "movie/popular"
    }
    
    enum RequestError: Error {
        case failed
    }
    
    enum Method: String {
        case GET, POST
    }
    
    private func urlForPath(_ path: Path, params: [String: Any]) -> URL {
        var components = URLComponents(string: baseURL + path.rawValue)!

        components.queryItems = params.compactMap {
            return URLQueryItem(name: $0.key, value: String(describing: $0.value))
        } + [URLQueryItem(name: "language", value: "en-US")]
        guard let url = components.url else {
            assert(true, "URL is broken")
            return URL.homeDirectory
        }
        return url
    }
    
    private let headers =  [
        "accept": "application/json",
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzMzA1ZjMyNGYyNjViNGZiNDdlNDhlYTAyZjcyMDdiZSIsInN1YiI6IjY1N2E0YmJiN2VjZDI4MDExZWYyMTIwMyIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.QoRCx98Wk4LXGsTrk2OfhBiSzLxqLIgNQ5lmSQr1pos"
      ]
    
    func loadMovies(page: Int = 1) async -> Result<[Movie], RequestError> {
        let result = await makeRequest(requestFor(.popularMovies, params: ["page": page]))
        switch result {
        case .success(let data):
            guard let data else {
                return .success([])
            }
            let decoder = JSONDecoder()
            let response = try! decoder.decode(PagingResponse<[Movie]>.self, from: data)
            return .success(response.results)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    private func requestFor(_ path: Path, method: Method = .GET, params: [String: Any]) -> URLRequest {
        var request = URLRequest(url: urlForPath(path, params: params))
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = headers
        return request
    }
    
    private func makeRequest(_ request: URLRequest) async -> Result<Data?, RequestError> {
        do {
            let response = try await session.data(for: request)
            print(response)
            return .success(response.0)
        } catch {
            return .failure(.failed)
        }
    }
}

