//
//  ViewController.swift
//  NoteIt
//
//  Created by Sanket Ughade on 13/05/25.
//

import UIKit
import CoreData

class NotesListViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addNoteButton: UIButton!
    @IBOutlet weak var emptyMessageLabel: UILabel!
    
    
    //Notes from NoteIt CoreData
    var notes: [Note] = [Note]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let storeURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
//            print("Core Data store path: \(storeURL.path)")
//        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Register the XIB
        let nib = UINib(nibName: "NoteCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "noteCard")
        
        // The below code will disable automatic sizing
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = .zero
        
        //Style the Add Note("+") button
        addNoteButton.layer.cornerRadius = 25
        addNoteButton.clipsToBounds = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        loadNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEmptyMessage()
    }
    
    @IBAction func onAddNotePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToNote", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNote" {
            if let destinationVC = segue.destination as? NoteDetailViewController {
                destinationVC.context = self.context
                destinationVC.delegate = self
//                if let note = sender as? Note {
//                    //Editing existing note
//                    destinationVC.note = note
//                } else {
//                    //Adding new note
//                    destinationVC.note = nil
//                }
            }
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func loadNotes(with request: NSFetchRequest<Note> = Note.fetchRequest()) {
        do {
            notes = try context.fetch(request)
        } catch {
            print("Error loading notes: \(error)")
        }
        collectionView.reloadData()
    }
    
    func updateEmptyMessage() {
        emptyMessageLabel.isHidden = !notes.isEmpty
    }
    
    func truncated(_ text: String, maxLength: Int) -> String {
        return text.count > maxLength
            ? String(text.prefix(maxLength)) + "..."
            : text
    }
    
    func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "" }
        
        let calendar = Calendar.current
        let now = Date()
        
        if let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: now), date >= oneWeekAgo {
            //Recent: within the last 7 days
            let formatter = DateFormatter()
            formatter.dateFormat = "E h:mm a" //Example: Wed 2:40 PM
            return formatter.string(from: date)
        } else {
            //Older: show as dd/MM/yyyy
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy" //Example: 17/05/2025
            return formatter.string(from: date)
        }
    }
}

//MARK: - UICollectionViewDataSource
extension NotesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCard", for: indexPath) as! NoteCollectionViewCell
        
        let note = notes[indexPath.row]
        cell.titleLabel.text = truncated(note.title!, maxLength: 30)
        cell.bodyLabel.text = truncated(note.body!, maxLength: 80)
        cell.dateLabel.text = formattedDate(note.date)
        
        return cell
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension NotesListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.size.width/2)-22, height: 160)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 12 // Horizontal spacing between columns
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16 // Vertical spacing between rows
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
}

//MARK: - UICollectionViewDelegate
extension NotesListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, previewProvider: nil) { _ in
            let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
                let noteToDelete = self.notes[indexPath.item]
                
                //1. Delete from Core Data context
                if let context = noteToDelete.managedObjectContext {
                    context.delete(noteToDelete)
                    do {
                        //2. Save the context
                        try context.save()
                        
                        //3.Remove from data source
                        self.notes.remove(at: indexPath.item)
                        
                        //4. Delete from collection view
                        collectionView.deleteItems(at: [indexPath])
                        self.updateEmptyMessage()
                    } catch {
                        print("Failed to delete note: \(error.localizedDescription)")
                    }
                }
            }
            return UIMenu(title: "", children: [delete])
        }
    }
}

//MARK: - NoteDetailViewControllerDelegate
extension NotesListViewController: NoteDetailViewControllerDelegate {
    func didSaveNote() {
        print("About to reload data in UICollectionView")
        loadNotes()
    }
}



