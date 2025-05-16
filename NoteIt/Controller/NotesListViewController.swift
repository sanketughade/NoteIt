//
//  ViewController.swift
//  NoteIt
//
//  Created by Sanket Ughade on 13/05/25.
//

import UIKit

class NotesListViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //Temporary hardcoded notes
    let notes: [Note] = [
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
        
        Note(title: "Workout Plan",
             body: "Monday: Chest, Tuesday: Back, Wednesday: Legs. Add more core exercises.",
             date: Date().addingTimeInterval(-3600)), // 1 hour ago
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //Register the XIB
        let nib = UINib(nibName: "NoteCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "noteCard")
        
        // ⬇️ Add this line to disable automatic sizing
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize = .zero
    }
}

//MARK: - UICollectionViewDataSource
extension NotesListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noteCard", for: indexPath) as! NoteCollectionViewCell
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



