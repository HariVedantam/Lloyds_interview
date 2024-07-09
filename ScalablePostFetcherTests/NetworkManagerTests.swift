//
//  NetworkManagerTests.swift
//  ScalablePostFetcher
//
//  Created by Hari Krishna Vedantham on 05/07/24.
//

import XCTest
@testable import ScalablePostFetcher

class NetworkManagerTests: XCTestCase {
    
    // MARK: - MockSession
    
    /// A mock URLSession conforming to NetworkSession protocol for testing purposes.
    class MockSession: NetworkSession {
        var data: Data?
        var error: Error?
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            completionHandler(data, nil, error)
            return URLSession.shared.dataTask(with: url) // Returning a dummy task
        }
    }
    
    // MARK: - Test Cases
    
    /// Tests the success scenario of fetching posts from the API.
    func testFetchPostsSuccess() {
        let mockSession = MockSession()
        mockSession.data = """
        [
            {"userId": 1, "id": 1, "title": "Post 1", "body": "Body 1"},
            {"userId": 1, "id": 2, "title": "Post 2", "body": "Body 2"}
        ]
        """.data(using: .utf8)
        
        let manager = NetworkManager(session: mockSession)
        let expectation = self.expectation(description: "Fetch Posts")
        
        manager.fetchPosts(offset: 0, limit: 10) { result in
            switch result {
            case .success(let posts):
                XCTAssertEqual(posts.count, 2)
                XCTAssertEqual(posts[0].title, "Post 1")
            case .failure:
                XCTFail("Expected success, got failure")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    /// Tests the failure scenario of fetching posts from the API.
    func testFetchPostsFailure() {
        let mockSession = MockSession()
        mockSession.error = NSError(domain: "", code: -1, userInfo: nil)
        
        let manager = NetworkManager(session: mockSession)
        let expectation = self.expectation(description: "Fetch Posts")
        
        manager.fetchPosts(offset: 0, limit: 10) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error):
                XCTAssertNotNil(error)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    /// Tests the scenario of network timeout.
    func testFetchPostsNetworkTimeout() {
        let mockSession = MockSession()
        mockSession.error = NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
        
        let manager = NetworkManager(session: mockSession)
        let expectation = self.expectation(description: "Fetch Posts")
        
        manager.fetchPosts(offset: 0, limit: 10) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error as NSError):
                XCTAssertEqual(error.code, NSURLErrorTimedOut)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    /// Tests the scenario of 404 error.
    func testFetchPostsNotFound() {
        let mockSession = MockSession()
        mockSession.error = NSError(domain: "", code: 404, userInfo: nil)
        
        let manager = NetworkManager(session: mockSession)
        let expectation = self.expectation(description: "Fetch Posts")
        
        manager.fetchPosts(offset: 0, limit: 10) { result in
            switch result {
            case .success:
                XCTFail("Expected failure, got success")
            case .failure(let error as NSError):
                XCTAssertEqual(error.code, 404)
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
