import UIKit
import Firebase
import FirebaseFirestore

class HomePageController: UIViewController
{
    

    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var addQuoteButton: UIButton!
    @IBOutlet weak var viewFavoritesButton: UIButton!
    
    
    let db = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUsernameAndUpdateUI()
    }
            
   func fetchUsernameAndUpdateUI() {
            guard let user = Auth.auth().currentUser else { return }
            let uid = user.uid
                
                db.collection("users").document(uid).getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let username = document.data()?["username"] as? String {
                            self.welcomeLabel.text = "Welcome, \(username)"
                        } else {
                            self.welcomeLabel.text = "Welcome, User"
                        }
                    } else {
                        self.welcomeLabel.text = "Welcome, User"
                    }
                }
            }
}



