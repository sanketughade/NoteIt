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
    @IBOutlet weak var selectAllButton: UIBarButtonItem!
    @IBOutlet weak var deleteMultipleButton: UIBarButtonItem!
    
    
    //Notes from NoteIt CoreData
    var notes: [Note] = [Note]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var isSelectionModeEnabled = false
    var selectedNotes = Set<Note>()
    
    var isAllSelected = false

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
        
        //Initially keep selectAllButton and deleteAllButton button hidden. Show them only when the Note Card is selected
        selectAllButton.isHidden = true
        deleteMultipleButton.isHidden = true
        
        loadNotes()
    }
    
    func allNotesUnselected() {
        isSelectionModeEnabled = false
        //As no note card is selected, hide both the buttons again
        selectAllButton.isHidden = true
        deleteMultipleButton.isHidden = true
        selectAllButton.image = UIImage(systemName: "checkmark.circle")
        selectedNotes.removeAll()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEmptyMessage()
    }
    
    @IBAction func onAddNotePressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToNote", sender: nil)
    }
    
    @IBAction func onSelectAllPressed(_ sender: UIBarButtonItem) {
        isAllSelected.toggle()
        if isAllSelected {
            selectAllButton.image = UIImage(systemName: "checkmark.circle.fill")
            selectedNotes = Set(notes)
            collectionView.reloadData()
        } else {
            //Select All unselected, so unselect all notes and hide the selectAll and deleteAll buttons
            allNotesUnselected()
        }
        
    }
    
    @IBAction func deleteMultiplePressed(_ sender: UIBarButtonItem) {
        guard !selectedNotes.isEmpty else { return }
        
        for note in selectedNotes {
            if let context = note.managedObjectContext {
                context.delete(note)
            }
        }
        
        do {
            try context.save()
            notes.removeAll(where: { selectedNotes.contains($0) })
            allNotesUnselected()
            updateEmptyMessage()
        } catch {
            print("Failed to delete selected notes \(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToNote" {
            if let destinationVC = segue.destination as? NoteDetailViewController {
                destinationVC.context = self.context
                destinationVC.delegate = self
                //Check if sender is a Note(editing)
                if let selectedNote = sender as? Note {
                    destinationVC.noteToEdit = selectedNote
                }
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
    
    func updateEmptyMessage(emptyMessage: String = "No notes yet") {
        emptyMessageLabel.text = emptyMessage
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
        
        let isSelected = selectedNotes.contains(note)
        cell.configureCheckbox(with: note, isSelectionMode: isSelectionModeEnabled, isSelected: isSelected)
        
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
            //Delete action
            let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { _ in
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
            
            //Select action
            let selectAction = UIAction(
                title: "Select",
                image: UIImage(systemName: "checkmark.circle")
            ) {_ in
                //Enter selection mode
                self.isSelectionModeEnabled = true
                self.selectedNotes.insert(self.notes[indexPath.item])
                collectionView.reloadData()
                //As the user has selected the note card, show the selecteAll and deleteAll buttons
                self.selectAllButton.isHidden = false
                self.deleteMultipleButton.isHidden = false
            }
            return UIMenu(title: "", children: [selectAction, deleteAction])
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (isSelectionModeEnabled) {
            let note = notes[indexPath.item]
            
            if selectedNotes.contains(note) {
                selectedNotes.remove(note)
                if (selectedNotes.count == 0) {
                    allNotesUnselected()
                    return
                } else {
                    if isAllSelected {
                        //User had selected all cards but now has unselected one of the card so change the selectAllButton image to "checkmark.circle"
                        isAllSelected = false
                        selectAllButton.image = UIImage(systemName: "checkmark.circle")
                    }
                }
            } else {
                selectedNotes.insert(note)
                if (selectedNotes.count == notes.count) {
                    //User has manually selected all notes to turn the allSelected image to "checkmark.circle.fill"
                    isAllSelected = true
                    selectAllButton.image = UIImage(systemName: "checkmark.circle.fill")
                }
            }
            collectionView.reloadItems(at: [indexPath])
        } else {
            //Handle the tap on the note card
            let selectedNote = notes[indexPath.row]
            performSegue(withIdentifier: "goToNote", sender: selectedNote)
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

//MARK: - UISearchBarDelegate
extension NotesListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        
        let titleSearchPredicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        let bodySearchPredicate = NSPredicate(format: "body CONTAINS[cd] %@", searchBar.text!)
        
        request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [titleSearchPredicate, bodySearchPredicate])
        
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true), NSSortDescriptor(key: "body", ascending: true)]
        
        loadNotes(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadNotes()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}



