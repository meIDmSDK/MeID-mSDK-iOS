import UIKit

extension UIAlertController {
    
    class func showMeidInfoAlert(title: String?,
                                 message: String?,
                                 cancelButtonText: String,
                                 from sourceViewController: UIViewController? = UIApplication.topViewController(),
                                 completion: (()->())? = nil) {
        
        let info = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        info.addAction(UIAlertAction(title: cancelButtonText, style: .default, handler: { _ in
            completion?()
        }))
        sourceViewController?.present(info, animated: true, completion: nil)
    }
}
