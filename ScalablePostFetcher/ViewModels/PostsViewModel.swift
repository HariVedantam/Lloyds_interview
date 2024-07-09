//
//  PostsViewModel.swift
//  ScalablePostFetcher
//
//  Created by Hari Krishna Vedantham on 05/07/24.
//

import Foundation
import UIKit

/// ViewModel responsible for managing posts data and handling business logic.
class PostsViewModel {
    var posts: [Post] = []
    var currentPage = 0
    var isLoading = false
    var reloadTableView: (() -> Void)?
    var newPostsLoaded: (([IndexPath]) -> Void)?
    var loadingStatusChanged: ((Bool) -> Void)?
    var networkManager: NetworkManagerProtocol
    
    init(networkManager: NetworkManagerProtocol = NetworkManager()) {
        self.networkManager = networkManager
    }
    
    /// Fetches posts from the API.
    func fetchPosts() {
        guard !isLoading else { return }
        isLoading = true
        loadingStatusChanged?(true)
        
        networkManager.fetchPosts(offset: currentPage * 10, limit: 10) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.loadingStatusChanged?(false)
            
            switch result {
            case .success(let newPosts):
                let startIndex = self.posts.count
                self.posts.append(contentsOf: newPosts)
                self.currentPage += 1
                let indexPaths = (startIndex..<self.posts.count).map { IndexPath(row: $0, section: 0) }
                self.newPostsLoaded?(indexPaths)
            case .failure(let error):
                print("Failed to fetch posts: \(error)")
                self.handleFetchError(error)
            }
        }
    }
    
    /// Handles error during fetching posts.
    private func handleFetchError(_ error: Error) {
        // Implement error handling logic, e.g., show an alert to the user
        DispatchQueue.main.async {
            if let viewController = self.getTopViewController() {
                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                viewController.present(alert, animated: true)
            }
        }
    }
    /// Returns the top most view controller.
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        var topController: UIViewController = rootViewController
        while let presentedViewController = topController.presentedViewController {
            topController = presentedViewController
        }
        return topController
    }
    
    /// Returns the number of rows in the table view.
    func numberOfRows() -> Int {
        return posts.count
    }
    
    /// Returns the post at a specific indexPath.
    /// - Parameter indexPath: The indexPath of the post.
    /// - Returns: The post at the specified indexPath.
    func postAt(indexPath: IndexPath) -> Post {
        return posts[indexPath.row]
    }
    
    /// Determines whether more posts should be loaded based on the current indexPath.
    /// - Parameter indexPath: The current indexPath.
    /// - Returns: A Boolean indicating whether more posts should be loaded.
    func shouldLoadMorePosts(for indexPath: IndexPath) -> Bool {
        return indexPath.row == posts.count - 1 && !isLoading
    }
}
