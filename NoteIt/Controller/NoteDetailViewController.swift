//
//  NoteDetailViewController.swift
//  NoteIt
//
//  Created by Sanket Ughade on 18/05/25.
//

import UIKit
import CoreData

protocol NoteDetailViewControllerDelegate {
    func didSaveNote()
}

class NoteDetailViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    var context: NSManagedObjectContext!
    
    var delegate: NoteDetailViewControllerDelegate?
    
    private var isEditingBody = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.delegate = self
        
        //Start with title style
        textView.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        textView.typingAttributes = [
            .font: UIFont.systemFont(ofSize: 22, weight: .bold)
        ]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textView.becomeFirstResponder()
        }
    }
    
    @IBAction func saveNotePressed(_ sender: UIBarButtonItem) {
        let fullText = textView.text ?? ""
        
        if fullText == "" {
            navigationController?.popViewController(animated: true)
            return
        }
        
        let extractedTitleAndBody: (title: String, body: String) = extractTitleAndBody()
        
        let note = Note(context: context)
        note.title = extractedTitleAndBody.title
        note.body = extractedTitleAndBody.body
        note.date = Date()
        
        do {
            try context.save()
            delegate?.didSaveNote()
            navigationController?.popViewController(animated: true)
        } catch {
            print("There was an error saving the note \(error)")
        }
    }
    
    func extractTitleAndBody() -> (title: String, body: String) {
        let fullText = textView.text ?? ""
        
        //Split at the first newline
        if let newlineRange = fullText.range(of: "\n") {
            let title = String(fullText[..<newlineRange.lowerBound])
            let body = String(fullText[newlineRange.upperBound...])
            return (title, body)
        } else {
            //No newline: all text is considered title, body is empty
            return (fullText, "")
        }
    }
}

//MARK: - UITextViewDelegate
extension NoteDetailViewController: UITextViewDelegate {
    //When user types
    func textViewDidChange(_ textView: UITextView) {
        //Detect current cusrosr line
        let cursorlocation = textView.selectedRange.location
        let text = textView.text as NSString? ?? ""
        
        //Find the index of the first newline
        let newlineRange = text.range(of: "\n")
        
        let isCursorInTitle = (newlineRange.location == NSNotFound || cursorlocation <= newlineRange.location)
        
        if isCursorInTitle {
            textView.typingAttributes = [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold)
            ]
        } else {
            textView.typingAttributes = [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        }
    }
    
    //When user presses keys
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        //Detect when user presses Return for the first time
        if text == "\n" && !isEditingBody {
            isEditingBody = true
            
            let currentText = textView.text ?? ""
            let titleText = (currentText as NSString).substring(to: range.location)
            
            let attributed = NSMutableAttributedString(string: titleText + "\n", attributes: [
                .font: UIFont.systemFont(ofSize: 22, weight: .bold)
            ])
            
            attributed.append(NSAttributedString(string: "", attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]))
            
            textView.attributedText = attributed
            textView.selectedRange = NSRange(location: attributed.length, length: 0)
            
            return false //Don't insert newline again
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        textViewDidChange(textView)
    }
}
