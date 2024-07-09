//
//  Post.swift
//  ScalablePostFetcher
//
//  Created by Hari Krishna Vedantham on 05/07/24.
//

import Foundation

/// Model representing a post.
struct Post: Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}
