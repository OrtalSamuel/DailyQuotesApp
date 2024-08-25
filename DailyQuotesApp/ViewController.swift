import UIKit
import Firebase
import FirebaseFirestore

class ViewController: UIViewController {
    
   
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var logginButton: UIButton!
    @IBOutlet weak var registerLable: UILabel!
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        print("View did")
        super.viewDidLoad()
        
        
        setupRegisterLabel()
            
    }
    
    
    private func setupRegisterLabel(){
        // Create and configure the tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(registerLabelTapped))
        registerLable.isUserInteractionEnabled = true
        registerLable.addGestureRecognizer(tapGesture)
    }
    
    @IBAction func logginButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            showAlert(message: "All fields must be filled in.")
            return
        }
        
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        print("Error signing in: \(error.localizedDescription)")
                        self.showAlert(message: "Username or password is incorrect")
                    } else {
                        self.goToMainScreen()
                    }
                }
            }
    
    private func goToMainScreen() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let mainNavVC = storyboard.instantiateViewController(withIdentifier: "MainNav") as? UINavigationController else {
                print("MainNav view controller not found")
                return
            }
            mainNavVC.modalPresentationStyle = .fullScreen
            present(mainNavVC, animated: true, completion: nil)
        }
        
        private func showAlert(message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion?()
            }))
            present(alert, animated: true, completion: nil)
        }
    
    @objc func registerLabelTapped(){
        performSegue(withIdentifier: "toRegister", sender: self)
    }
}
