//
//  PostsViewController.swift
//  ScalablePostFetcher
//
//  Created by Hari Krishna Vedantham on 05/07/24.
//

import UIKit

/// ViewController responsible for displaying and managing posts in a table view.
class PostsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    private let viewModel = PostsViewModel()
    private var loadingView: UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        bindViewModel()
        setupLoadingView()
        fetchInitialPosts()
    }
    
    /// Sets up the table view by assigning its data source and delegate, and registering the cell class.
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(PostCell.self, forCellReuseIdentifier: PostCell.reuseIdentifier)
    }
    
    /// Sets up the loading view (spinner) that appears at the bottom of the table view during data loading.
    private func setupLoadingView() {
        loadingView = UIActivityIndicatorView(style: .medium)
        loadingView?.hidesWhenStopped = true
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 50))
        loadingView?.center = footerView.center
        footerView.addSubview(loadingView!)
        tableView.tableFooterView = footerView
    }
    
    /// Binds the view model's callbacks to the view controller's UI updates.
    private func bindViewModel() {
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.newPostsLoaded = { [weak self] indexPaths in
            DispatchQueue.main.async {
                self?.tableView.insertRows(at: indexPaths, with: .automatic)
            }
        }
        
        viewModel.loadingStatusChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    self?.loadingView?.startAnimating()
                } else {
                    self?.loadingView?.stopAnimating()
                }
            }
        }
    }
    
    /// Fetches initial posts when the view is loaded.
    private func fetchInitialPosts() {
        viewModel.fetchPosts()
    }
}

// MARK: - UITableViewDataSource and UITableViewDelegate Methods
extension PostsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.reuseIdentifier, for: indexPath) as? PostCell else {
            return UITableViewCell()
        }
        
        let post = viewModel.postAt(indexPath: indexPath)
        cell.configure(with: post)
        
        if viewModel.shouldLoadMorePosts(for: indexPath) {
            viewModel.fetchPosts()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}

/*
 **Performance:**
 Efficient Data Fetching: Utilizes asynchronous network calls (URLSession) to fetch data from a remote API (jsonplaceholder.typicode.com). Data fetching is done on a background thread, and UI updates are dispatched to the main thread, ensuring smooth user experience. Additionally, data is fetched in batches of 15 posts at a time, reducing memory usage and enhancing performance.
 
 **Readability:**
 Clear and Structured Code: Code is organized into separate files (Post.swift, NetworkManager.swift, PostsViewModel.swift, PostsViewController.swift, PostCell.swift) with clear responsibilities for each class. Each component (model, network manager, view model, view controller, cell) focuses on a single responsibility, enhancing code readability and maintainability.
 
 **Maintainability:**
 Dependency Injection: NetworkManager accepts NetworkSession protocol in its initializer, allowing flexibility to mock dependencies for testing and facilitating future changes in network handling without modifying the NetworkManager class itself.
 
 **Testability:**
 Unit Tests: Includes unit tests (NetworkManagerTests.swift, PostsViewModelTests.swift) that validate the behavior of critical components (NetworkManager, PostsViewModel) using mock sessions (MockSession). Tests cover both success and failure scenarios for fetching posts, ensuring robustness of the network and business logic layers.
 
 **Scalability:**
 Scalable Architecture: The architecture allows easy extension by adhering to separation of concerns and employing protocols. Adding new features or modifying existing ones (e.g., adding image fetching) can be done without significant changes to the existing codebase, thanks to modular components and clear dependencies. The use of pagination for data fetching further enhances scalability.
 
 **Simplicity:**
 Straightforward Implementation: Code is kept simple and concise while meeting all specified requirements. Each class (Post, NetworkManager, PostsViewModel, PostsViewController, PostCell) focuses on its specific role, avoiding unnecessary complexity and ensuring clarity in implementation. The addition of a loader to the table view's footer view ensures a user-friendly experience during data loading.
 */
