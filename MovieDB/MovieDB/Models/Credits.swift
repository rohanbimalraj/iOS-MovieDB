//
//  Credits.swift
//  MovieDB
//
//  Created by Rohan Bimal Raj on 14/02/26.
//

import Foundation

// MARK: - Credits Response
struct CreditsResponse: Codable {
    let id: Int
    let cast: [CastMember]
    let crew: [CrewMember]
}

// MARK: - Cast Member Model
struct CastMember: Codable, Identifiable {
    let id: Int
    let name: String
    let originalName: String?
    let character: String
    let profilePath: String?
    let order: Int
    let knownForDepartment: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, character, order
        case originalName = "original_name"
        case profilePath = "profile_path"
        case knownForDepartment = "known_for_department"
    }
    
    var profileURL: URL? {
        Constants.profileURL(for: profilePath)
    }
}

// MARK: - Crew Member Model
struct CrewMember: Codable, Identifiable {
    let id: Int
    let name: String
    let originalName: String?
    let job: String
    let department: String
    let profilePath: String?
    let knownForDepartment: String?
    
    enum CodingKeys: String, CodingKey {
        case id, name, job, department
        case originalName = "original_name"
        case profilePath = "profile_path"
        case knownForDepartment = "known_for_department"
    }
    
    var profileURL: URL? {
        Constants.profileURL(for: profilePath)
    }
    
    var isDirector: Bool {
        job.lowercased() == "director"
    }
}
