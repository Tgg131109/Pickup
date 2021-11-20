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

//    func updateStatusImage(status: Int) {
//        statusImgView.transform = CGAffineTransform(scaleX: 1, y: 1)
//
//        switch status {
//        case 1:
//            statusImgView.image = UIImage(systemName: "checkmark.seal.fill")
//            self.backgroundColor = .systemGreen
//        case 2:
//            statusImgView.image = UIImage(systemName: "checkmark.circle.fill")
//            self.backgroundColor = .systemYellow
//        case 3:
//            statusImgView.image = UIImage(systemName: "exclamationmark.triangle.fill")
//            self.backgroundColor = .systemRed
//        case 4:
//            statusImgView.image = nil
//            self.backgroundColor = .systemTeal
//            UIView.animate(
//                withDuration: 0.5,
//                animations: {
//                    self.statusImgView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
//                }
//            )
//        default:
//            print("Error setting status image.")
//            break
//        }
//    }
    
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
