//
//  NoteCollectionViewCell.swift
//  NoteIt
//
//  Created by Sanket Ughade on 16/05/25.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //contentView styles
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        //layer styles
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        backgroundColor = .clear
        
        //titleLabel styles
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        titleLabel.numberOfLines = 1
        titleLabel.textColor = .label
        
        //bodyLabel styles
        bodyLabel.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        bodyLabel.numberOfLines = 3
        bodyLabel.textColor = .darkGray
        bodyLabel.lineBreakMode = .byTruncatingTail
        
        //dateLabel styles
        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .light)
        dateLabel.textColor = .gray
        dateLabel.numberOfLines = 1
    }

}
