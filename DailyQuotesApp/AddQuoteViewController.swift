import UIKit
import Firebase
import FirebaseFirestore

class AddQuoteViewController: UIViewController, UITextViewDelegate {
    
    
    
    @IBOutlet weak var quoteTextView: UITextView!
    
    @IBOutlet weak var addButton: UIButton!
   
    let placeholderText = "Enter your inspiring sentence here..."

        override func viewDidLoad() {
            super.viewDidLoad()
            print("Add quote class")

            quoteTextView.delegate = self
            quoteTextView.text = placeholderText
            quoteTextView.textColor = .lightGray
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == placeholderText {
                textView.text = ""
                textView.textColor = .black
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = placeholderText
                textView.textColor = .lightGray
            }
        }
    
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        guard let quote = quoteTextView.text, !quote.isEmpty, quote != placeholderText else {
            showAlert(message: "Please enter a quote.")
            return
        }

        // Validate that the quote contains only letters and spaces
        let allowedCharacterSet = CharacterSet.letters.union(.whitespaces).union(.punctuationCharacters)
        // Check if there are any characters in the quote that are not in the allowed character set
         if quote.rangeOfCharacter(from: allowedCharacterSet.inverted) != nil {
             // If invalid characters are found, show an alert
             showAlert(message: "Please enter a valid quote containing only letters, spaces, and punctuation.")
             return
        }

        // Save the quote to Firestore
        let db = Firestore.firestore()
        db.collection("inspirationalQuotes").addDocument(data: ["quote": quote]) { error in
            if let error = error {
                self.showAlert(message: "Error saving quote: \(error.localizedDescription)")
            } else {
                self.showAlert(message: "Quote added successfully!")
                self.quoteTextView.text = self.placeholderText
                self.quoteTextView.textColor = .lightGray
            }
        }
    }



        func showAlert(message: String) {
            let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
