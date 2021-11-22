//
//  StudentCollectionViewCell.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/19/21.
//

import UIKit

class StudentCollectionViewCell: UICollectionViewCell {
    
//    @IBOutlet weak var bkgdView: UIView!
    @IBOutlet weak var studentImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var gradeLbl: UILabel!
    
    override var isSelected: Bool {
        didSet{
            if self.isSelected {
                brightCell()
            } else {
                dimCell()
            }
        }
    }
    
    func dimCell() {
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.contentView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                self.backgroundColor = .systemGray5
            }
        )
    }
    
    func brightCell() {
        UIView.animate(
            withDuration: 0.5,
            animations: {
                self.contentView.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.backgroundColor = .systemYellow
            }
        )
    }
}

class SectionHeaderView: UICollectionReusableView {
    
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    
    var deleteTag : (() -> ())?
    
    @IBAction func deleteBtnTapped(_ sender: UIButton) {
        // if the closure is defined (not nil)
        // then execute the code inside the checkToken closure
        deleteTag?()
    }
}
