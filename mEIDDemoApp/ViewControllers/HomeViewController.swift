import UIKit
import SafariServices

class HomeViewController: UIViewController {

    // MARK: - Properties
    
    let viewModel = HomeViewModel()
    
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var logoutButton: UIButton!

    // MARK: - Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.isHidden = false
        logoutButton.isHidden = true
    }
    
    func handleDeeplink(_ deeplink: URL) {
        
        switch deeplink.host {
        case "account":
            if let code = deeplink.valueOf("code"), code.isEmpty == false {
                viewModel.getToken(code: code, completion: { [weak self] res in
                    DispatchQueue.main.async {
                        switch res {
                        case .success(let authResp):
                            UIAlertController.showMeidInfoAlert(title: "Prihlásenie úspešné", message: "ID token: \(authResp.idToken)", cancelButtonText: "OK")
                            self?.loginButton.isHidden = true
                            self?.logoutButton.isHidden = false
                        case .failure(let error):
                            UIAlertController.showMeidInfoAlert(title: "Chyba pri prihlásení", message: error.localizedDescription, cancelButtonText: "OK")
                        }
                    }
                })
            }
            else {
                UIAlertController.showMeidInfoAlert(title: "Chyba pri prihlasovaní", message: "Chýbajúci parameter 'code'.", cancelButtonText: "OK")
            }
            
        case "logout":
            viewModel.removeTokens()
            loginButton.isHidden = false
            logoutButton.isHidden = true
            UIAlertController.showMeidInfoAlert(title: "Boli ste odhlásený", message: nil, cancelButtonText: "OK")
            
        default:
            UIAlertController.showMeidInfoAlert(title: "Chyba", message: "Nepodporovaý deeplink", cancelButtonText: "OK")
        }
    }
    
    @IBAction private func authTapped() {
        let authUrl = viewModel.getAuthUrl(state: UUID().uuidString, nonce: UUID().uuidString)

        let safariVC = SFSafariViewController(url: authUrl)
        safariVC.modalPresentationStyle = .automatic
        present(safariVC, animated: true)
    }
    
    @IBAction private func logoutTapped() {
        let logoutUrl = viewModel.getLogoutUrl()
        
        let safariVC = SFSafariViewController(url: logoutUrl)
        safariVC.modalPresentationStyle = .automatic
        present(safariVC, animated: true)
    }
}

