import UIKit

enum NetworkError: Error {
    case badUrl
    case noData
    case decodingError
}

struct Post: Decodable {
    let title: String
}

func getPosts(completion: @escaping (Result<[Post], NetworkError>) -> ()) {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts") else {
        completion(.failure(.badUrl))
        return
    }
    
    URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            completion(.failure(.noData))
            return
        }
        
        do {
            let post = try JSONDecoder().decode([Post].self, from: data)
            completion(.success(post))
        } catch {
            completion(.failure(.decodingError))
        }
        
    }.resume()
}

func getPosts() async throws -> [Post] {
    
    return try await withCheckedThrowingContinuation({ continuation in
        getPosts { result in
            switch result {
            case let .success(post):
                continuation.resume(returning: post)
            case let .failure(error):
                continuation.resume(throwing: error)
            }
        }
    })
}

Task.init(priority: .background) {
    do {
        let posts = try await getPosts()
        print(posts)
    } catch {
        print(error)
    }
}





