import UIKit
import Firebase
import FirebaseFirestore

class RegisterController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    
    let db = Firestore.firestore()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }


    @IBAction func registerButtonTapped(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
                      let password = passwordTextField.text, !password.isEmpty,
                      let username = usernameTextField.text, !username.isEmpty else {
                    showAlert(message: "All fields must be filled in.")
                    return
                }
    

            if !isValidEmail(email) {
                showAlert(message: "Invalid email format. Please enter a valid email.")
                return
            }

            if !isValidPassword(password) {
                showAlert(message: "Invalid password format. Password must be 8 digits long and contain only numbers.")
                return
            }



                Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                    if let error = error {
                        print("Error registering: \(error.localizedDescription)")
                        self.showAlert(message: "A user with this email already exists") 
                    } else {
                        guard let user = authResult?.user else { return }
                                        let uid = user.uid
                                        let favoriteSentences = [String]()
                                        
                                        self.saveUserInformation(uid: uid, username: username, favoriteSentences: favoriteSentences)
                                        self.showAlert(message: "Sign up success!") { [weak self] in
                                            guard let self = self else { return }
                                            
                                
                                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                            
                                            
                                            let vc = storyboard.instantiateViewController(withIdentifier: "MainNav")
                                            vc.modalPresentationStyle = .fullScreen
                                            present(vc, animated: true)
                                              
                                        }
                                    }
                                }
                            }
    func saveUserInformation(uid: String, username: String, favoriteSentences: [String]) {
            let userData: [String: Any] = [
                "username": username,
                "favoriteSentences": favoriteSentences
            ]
            
            db.collection("users").document(uid).setData(userData) { error in
                if let error = error {
                    print("Error saving user information: \(error.localizedDescription)")
                } else {
                    print("User information saved successfully!")
                }
            }
        }
    
    
    func showAlert(message: String, completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                completion?()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    
    
    
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.com$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^[0-9]{8}$"
        let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
        return passwordPredicate.evaluate(with: password)
    }
    
}
