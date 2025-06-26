import Foundation

class HomeViewModel {
    
    // MARK: - Constants
    struct Constants {
        static let authUrl = "https://tmeid.minv.sk/realms/meid/protocol/openid-connect/auth"
        static let logoutUrl = "https://tmeid.minv.sk/realms/meid/protocol/openid-connect/logout"
        static let clientId = "test-client"
        static let authRedirectUri = "sk.test.tmeid://account"
        static let logoutRedirectUri = "sk.test.tmeid://logout"
    }
    
    // MARK: - Properties
    
    private var pkce: PKCE?
    private var tokenResponse: TokenResponse?
    
    // MARK: - Functions
    
    func getAuthUrl(state:String, nonce: String) -> URL {
        var urlComps = URLComponents(string: Constants.authUrl)!
        urlComps.queryItems = [URLQueryItem(name: "client_id", value: Constants.clientId),
                               URLQueryItem(name: "redirect_uri", value: Constants.authRedirectUri),
                               URLQueryItem(name: "response_mode", value: "query"),
                               URLQueryItem(name: "response_type", value: "code"),
                               URLQueryItem(name: "scope", value: "openid"),
                               URLQueryItem(name: "nonce", value: nonce),
                               URLQueryItem(name: "state", value: state),
                               URLQueryItem(name: "code_challenge", value: getPKCE(generateNew: true)?.codeChallenge ?? ""),
                               URLQueryItem(name: "code_challenge_method", value: "S256")]
        return urlComps.url!
    }
    
    func getToken(code: String,
                  completion: @escaping (Result<TokenResponse, MeidError>)->()) {
        
        // authorization code should be passed to the server along with the PKCE verifier
        // server retrievs the access tokens and pass it back to the application in an response
        Server().getToken(code: code,
                          pkceVerifier: getPKCE(generateNew: false)?.codeVerifier ?? "") { [weak self] response in
            switch response {
            case .success(let tokenResponse):
                self?.tokenResponse = tokenResponse
                completion(.success(tokenResponse))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func getLogoutUrl() -> URL {
        var urlComps = URLComponents(string: Constants.logoutUrl)!
        urlComps.queryItems = [URLQueryItem(name: "client_id", value: Constants.clientId),
                               URLQueryItem(name: "post_logout_redirect_uri", value: Constants.logoutRedirectUri),
                               URLQueryItem(name: "id_token_hint", value: tokenResponse?.idToken ?? "")]
        return urlComps.url!
    }
    
    func removeTokens() {
        tokenResponse = nil
    }
    
    // MARK: - Private functions
    
    private func getPKCE(generateNew: Bool) -> PKCE? {
        if pkce == nil || generateNew {
            pkce = try? PKCE()
        }
        return pkce
    }
}
