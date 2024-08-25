

import UIKit
import Firebase
import FirebaseFirestore

class FavoritesQuotesController: UIViewController, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var tableView: UITableView!
    let db = Firestore.firestore()
        var favoriteQuotes: [String] = []
        
        override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.delegate = self
            
            // Enable dynamic cell height
                tableView.estimatedRowHeight = 44.0 // You can set any estimated height
                tableView.rowHeight = UITableView.automaticDimension

            fetchFavoriteQuotes()
        }
        
        func fetchFavoriteQuotes() {
            guard let user = Auth.auth().currentUser else { return }
            let uid = user.uid
            
            db.collection("users").document(uid).getDocument { (document, error) in
                if let document = document, document.exists {
                    self.favoriteQuotes = document.data()?["favoriteSentences"] as? [String] ?? []
                    self.tableView.reloadData()
                } else {
                    print("Document does not exist")
                }
            }
        }
        
        // MARK: - Table View Data Source
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return favoriteQuotes.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuoteCell", for: indexPath)
            cell.textLabel?.text = favoriteQuotes[indexPath.row]
            
            
            // Enable multi-line display
                cell.textLabel?.numberOfLines = 0
                cell.textLabel?.lineBreakMode = .byWordWrapping
            return cell
        }
    }
