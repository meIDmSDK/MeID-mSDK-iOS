import Foundation

/// this class illustrates how to get access/refresh/user tokens on the server side using the authorization_code grant type
class Server {
    
    struct Constants {
        static let clientId = "test-client"
        static let clientSecret = "udPb01a5N6f8cq1hMv9IqQIoEE0SMt6S"
        static let authRedirectUri = "sk.test.tmeid://account"
        static let tokenUrl = "https://tmeid.minv.sk/realms/meid/protocol/openid-connect/token"
    }
    
    func getToken(code: String,
                  pkceVerifier: String,
                  completion: @escaping (Result<TokenResponse, MeidError>)->()) {
    
        var request : URLRequest = URLRequest(url: URL(string:Constants.tokenUrl)!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField:"Content-Type");

        let params: [String : String] = ["client_id": Constants.clientId,
                                         "client_secret": Constants.clientSecret,
                                         "scope": "openid",
                                         "grant_type": "authorization_code",
                                         "redirect_uri": Constants.authRedirectUri,
                                         "code": code,
                                         "code_verifier": pkceVerifier]

        request.httpBody = params.map { "\($0)=\($1.urlEncoded ?? "")" }.joined(separator: "&").data(using: .utf8)
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard error == nil else {
                completion(.failure(.authError))
                return
            }
            if let jsonData = data,
               let authResponse = try? JSONDecoder().decode(TokenResponse.self, from: jsonData) {
                completion(.success(authResponse))
            }
            else {
                completion(.failure(.authError))
            }
        }).resume()
    }
}
