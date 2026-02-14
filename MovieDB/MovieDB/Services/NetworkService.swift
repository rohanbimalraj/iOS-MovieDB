//
//  NetworkService.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import Foundation

// MARK: - Network Error
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case serverError(Int)
    case noData
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .noData:
            return "No data received"
        case .unknown(let error):
            return "Unknown error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Network Service Protocol
protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(from endpoint: String, queryItems: [URLQueryItem]?) async throws -> T
}

// MARK: - Network Service Implementation
class NetworkService: NetworkServiceProtocol {
    
    static let shared = NetworkService()
    
    private init() {}
    
    func fetch<T: Decodable>(from endpoint: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        // Construct URL
        guard var urlComponents = URLComponents(string: "\(Constants.baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        // Add API key and additional query items
        var items = [URLQueryItem(name: "api_key", value: Constants.apiKey)]
        if let queryItems = queryItems {
            items.append(contentsOf: queryItems)
        }
        urlComponents.queryItems = items
        
        guard let url = urlComponents.url else {
            throw NetworkError.invalidURL
        }
        
        // Perform request
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Validate response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            // Decode data
            do {
                let decoder = JSONDecoder()
                let decodedData = try decoder.decode(T.self, from: data)
                return decodedData
            } catch {
                throw NetworkError.decodingError(error)
            }
            
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.unknown(error)
        }
    }
}
