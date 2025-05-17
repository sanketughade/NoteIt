//
//  ViewController.swift
//  NoteIt
//
//  Created by Sanket Ughade on 13/05/25.
//

import UIKit

class NotesListViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addNoteButton: UIButton!
    
    
    //Temporary hardcoded notes
    let notes: [Note] = [
        Note(title: "Buy groceries",
             body: "Milk, Eggs, Bread, Butter, Fruits, and Vegetables.",
             date: Date().addingTimeInterval(-3600)),
        
        Note(title: "Quick Idea",
             body: "Launch a podcast for book summaries.",
             date: Date().addingTimeInterval(-86400)),
        
        Note(title: "Workout Routine for the Next Three Months",
             body: "Monday: Chest and Triceps, Tuesday: Back and Biceps, Wednesday: Legs, Thursday: Shoulders, Friday: Core. Add stretching sessions twice a week.",
             date: Date().addingTimeInterval(-400000)),
        
        Note(title: "Read",
             body: "Atomic Habits",
             date: Date().addingTimeInterval(-7200)),
        
        Note(title: "UI Design Meeting Notes",
             body: "Align on colors, spacing, component behavior. Review Figma mockups and ensure accessibility standards are met. Mobile-first layout preferred.",
             date: Date().addingTimeInterval(-604800 * 2)),
        
        Note(title: "Travel Checklist",
             body: "Passport, Visa, Chargers, Toiletries, Casual Wear, Formal Wear, Snacks, Travel Pillow, IDs, Currency, Cards, Hotel Bookings, COVID Certificate.",
             date: Date().addingTimeInterval(-86000)),
        
        Note(title: "To Do",
             body: "Wash car",
             date: Date().addingTimeInterval(-300000)),
        
        Note(title: "Project Retrospective: Sprint 5",
             body: "What went well: Team coordination. What didn't: Testing delays. Action items: Improve unit test coverage, communicate blockers sooner.",
             date: Date().addingTimeInterval(-5400)),
        
        Note(title: "Short",
             body: "Note.",
             date: Date().addingTimeInterval(-100000)),
        
        Note(title: "Books I Want to Read in 2025",
             body: "The Psychology of Money, Deep Work, Thinking Fast and Slow, The Almanack of Naval Ravikant, Sapiens, Hooked, The Lean Startup, 48 Laws of Power, Rework.",
             date: Date().addingTimeInterval(-604800 * 3))
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    }
    
    func truncated(_ text: String, maxLength: Int) -> String {
        return text.count > maxLength
            ? String(text.prefix(maxLength)) + "..."
            : text
    }
    
    func formattedDate(_ date: Date) -> String {
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
        cell.titleLabel.text = truncated(note.title, maxLength: 30)
        cell.bodyLabel.text = truncated(note.body, maxLength: 80)
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



