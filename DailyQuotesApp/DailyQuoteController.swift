
import UIKit
import Firebase
import FirebaseFirestore


class DailyQuoteController: UIViewController {
    
    
    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var addToFavoritesButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var starButton1: UIButton!
    @IBOutlet weak var starButton2: UIButton!
    @IBOutlet weak var starButton3: UIButton!
    @IBOutlet weak var starButton4: UIButton!
    @IBOutlet weak var starButton5: UIButton!
    
    let db = Firestore.firestore()
    var currentQuote: String?
    var favoriteQuotes: Set<String> = Set<String>()
    var currentRating: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchFavoriteQuotes {  [weak self]  in
            self?.fetchRandomQuote()
        }
        
    }
    
    
    func fetchRandomQuote() {
        db.collection("inspirationalQuotes").getDocuments {[weak self] (querySnapshot, error) in
            guard let strongSelf  = self else {return}
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                var quotes: Set<String> = Set<String>()
                for document in querySnapshot!.documents {
                    if let quote = document.data()["quote"] as? String, !quote.isEmpty {
                        quotes.insert(quote)
                    }
                }
                
                // Print random element
                DispatchQueue.main.async {
                    let relevant = quotes.subtracting(strongSelf.favoriteQuotes)
                    if relevant.isEmpty {
                        
                        strongSelf.quoteLabel.text = "All Quotes are in favorites, go to favorites page to view em all"

                        strongSelf.hideElements()
                        return
                    }
                    strongSelf.currentQuote = relevant.randomElement()
                    strongSelf.quoteLabel.text = strongSelf.currentQuote
                    strongSelf.fetchCurrentRating()
                }
                
                // Print all quotes fetched from Firestore
                print("Quotes from Firestore: \(quotes)")
            }
        }
    }
    
    func hideElements() {
        // Hide all star buttons (assuming they are tagged 1 to 5)
        for i in 1...5 {
            if let starButton = self.view.viewWithTag(i) as? UIButton {
                starButton.isHidden = true
            }
        }
        
        // Hide the share button
        shareButton.isHidden = true
        
        //Hide the assToFavoritesButton
        addToFavoritesButton.isHidden = true
    }
    
    func fetchFavoriteQuotes(completion: @escaping () -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let uid = user.uid
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let favorites = document.data()?["favoriteSentences"] as? [String] ?? []
                self.favoriteQuotes = Set(favorites)
            } else {
                print("Document does not exist")
            }
            completion()
        }
    }
    
    
    
    @IBAction func addToFavoritesButtonTapped(_ sender: UIButton) {
      
        guard let user = Auth.auth().currentUser else { return }
        guard let currentQuote = currentQuote else {return}
        
        let uid = user.uid
        
        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                var favoriteSentences = document.data()?["favoriteSentences"] as? [String] ?? []
                
                
                if favoriteSentences.contains(currentQuote) {
                    self.view.showToast(message: "This quote is already in your favorites.")
                    return
                }
                
                favoriteSentences.append(currentQuote)
                
                
                
                self.db.collection("users").document(uid).updateData([
                    "favoriteSentences": favoriteSentences
                ]) { error in
                    if let error = error {
                        print("Error adding to favorites: \(error.localizedDescription)")
                    } else {
                        self.favoriteQuotes.insert(currentQuote)
                        self.fetchRandomQuote()
                        
                        //                               self.addToFavoritesButton.setImage(UIImage(named:"star.fill"), for: .normal)
                        self.view.showToast(message: "Quote added to favorites!")
                        
                        
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    @IBAction func viewFavoritesButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let favoriteQuotesVC = storyboard.instantiateViewController(identifier: "FavoritesQuotesController") as? FavoritesQuotesController {
            self.present(favoriteQuotesVC, animated: true)
        }
        
    }
    
    @IBAction func starTapped(_ sender: UIButton) {
        let rating = sender.tag
        updateStarUI(rating: rating)
        saveRating(rating: rating)
    }
    

    func updateStarUI(rating: Int) {
        DispatchQueue.main.async { // Ensure UI updates are on the main thread
            for i in 1...5 {
                if let starButton = self.view.viewWithTag(i) as? UIButton {
                    let imageName = i <= rating ? "star.fill" : "star"
                    starButton.setImage(UIImage(systemName: imageName), for: .normal)
                    print("Star \(i) set to \(imageName).") // Debugging
                } else {
                    print("No button found with tag \(i)")
                }
            }
        }
    }
        
        func saveRating(rating: Int) {
            guard let currentQuote = currentQuote else { return }
            
            db.collection("inspirationalQuotes").whereField("quote", isEqualTo: currentQuote).getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error getting documents: \(error)")
                    return
                }
                
                guard let document = querySnapshot?.documents.first else { return }
                let documentID = document.documentID
                
                let currentTotalRating = document.data()["totalRating"] as? Int ?? 0
                let currentRatingCount = document.data()["ratingCount"] as? Int ?? 0
                
                let newTotalRating = currentTotalRating + rating
                let newRatingCount = currentRatingCount + 1
                let newAverageRating = Double(newTotalRating) / Double(newRatingCount)
                
                self.db.collection("inspirationalQuotes").document(documentID).updateData([
                    "totalRating": newTotalRating,
                    "ratingCount": newRatingCount,
                    "averageRating": newAverageRating
                ]) { error in
                    if let error = error {
                        print("Error updating rating: \(error.localizedDescription)")
                    } else {
                        print("Rating updated successfully")
                        self.updateStarUI(rating: Int(newAverageRating.rounded()))
                    }
                }
            }
        }
        
        func fetchCurrentRating() {
            guard let currentQuote = currentQuote else { return }
            let quoteRef = db.collection("inspirationalQuotes").whereField("quote", isEqualTo: currentQuote)
            
            quoteRef.getDocuments { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                if let document = querySnapshot?.documents.first {
                    let currentAverageRating = document.data()["averageRating"] as? Double ?? 0
                    DispatchQueue.main.async {
                        self.updateStarUI(rating: Int(currentAverageRating.rounded()))
                    }
                }
            }
        }
    
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
    
            guard let quote = currentQuote else {
                return
            }
            
            // Prepare the content to share
            let message = "Share: \(quote)"
            
            // Create the UIActivityViewController
            let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
            
            // Present the Share Sheet
            present(activityViewController, animated: true, completion: nil)
        }
    }


