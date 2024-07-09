import Foundation

/// Protocol defining the contract for network manager.
protocol NetworkManagerProtocol {
    func fetchPosts(offset: Int, limit: Int, completion: @escaping (Result<[Post], Error>) -> Void)
}

/// Protocol defining the contract for network session.
protocol NetworkSession {
    func dataTask(with url: URL, completionHandler: @escaping @Sendable (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: NetworkSession {}

/// Network manager responsible for fetching posts from the API.
class NetworkManager: NetworkManagerProtocol {
    private let session: NetworkSession
    private let baseURL = URL(string: "https://jsonplaceholder.typicode.com/posts")!
    private var cache: [Int: [Post]] = [:]
    private let retryLimit = 3
    
    init(session: NetworkSession = URLSession.shared) {
        self.session = session
    }
    
    /// Fetches posts from the API.
    /// - Parameters:
    ///   - offset: The offset for pagination.
    ///   - limit: The limit for pagination.
    ///   - completion: Completion handler with result.
    func fetchPosts(offset: Int, limit: Int, completion: @escaping (Result<[Post], Error>) -> Void) {
        if let cachedPosts = cache[offset] {
            completion(.success(cachedPosts))
            return
        }
        
        let urlString = "\(baseURL)?_start=\(offset)&_limit=\(limit)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        fetchData(from: url, retryCount: 0, completion: completion)
    }
    
    /// Fetches data from the given URL with retry mechanism.
    private func fetchData(from url: URL, retryCount: Int, completion: @escaping (Result<[Post], Error>) -> Void) {
        session.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            if let error = error {
                if retryCount < self.retryLimit {
                    self.fetchData(from: url, retryCount: retryCount + 1, completion: completion)
                } else {
                    completion(.failure(error))
                }
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                self.cache[url.hashValue] = posts
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

/// Enum representing network errors.
enum NetworkError: Error {
    case invalidURL
    case noData
}
