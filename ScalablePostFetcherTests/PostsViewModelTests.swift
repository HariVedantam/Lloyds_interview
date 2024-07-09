import XCTest
@testable import ScalablePostFetcher

class PostsViewModelTests: XCTestCase {
    
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
    
    // MARK: - Test Fetch Posts
    
    /// Tests the fetchPosts method of PostsViewModel.
    /// Verifies that after fetching posts, the table view is reloaded and the number of rows is greater than 0.
    func testFetchPosts() {
        let expectation = self.expectation(description: "Reload TableView")
        
        let viewModel = PostsViewModel()
        
        // Set up expectation to fulfill when reloadTableView closure is called
        viewModel.reloadTableView = {
            expectation.fulfill()
        }
        
        // Trigger fetchPosts method
        viewModel.fetchPosts()
        
        // Wait for the expectation to be fulfilled (tableView reload)
        waitForExpectations(timeout: 1, handler: nil)
        
        // Assert that number of rows is greater than 0
        XCTAssertGreaterThan(viewModel.numberOfRows(), 0)
    }
    
    /// Tests fetchPosts method for empty response.
    func testFetchPostsEmptyResponse() {
        let expectation = self.expectation(description: "Reload TableView")
        
        let viewModel = PostsViewModel()
        
        // Set up expectation to fulfill when reloadTableView closure is called
        viewModel.reloadTableView = {
            expectation.fulfill()
        }
        
        // Use a mock session to simulate an empty response
        let mockSession = MockSession()
        mockSession.data = "[]".data(using: .utf8)
        viewModel.networkManager = NetworkManager(session: mockSession)
        
        // Trigger fetchPosts method
        viewModel.fetchPosts()
        
        // Wait for the expectation to be fulfilled (tableView reload)
        waitForExpectations(timeout: 1, handler: nil)
        
        // Assert that number of rows is 0
        XCTAssertEqual(viewModel.numberOfRows(), 0)
    }
}
