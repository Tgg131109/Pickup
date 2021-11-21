//
//  CustomTableViewCell.swift
//  GambleToby_Pickup
//
//  Created by Toby Gamble on 11/18/21.
//

import UIKit

class SchoolTableViewCell: UITableViewCell {

    @IBOutlet weak var bkgdView: UIView!
    @IBOutlet weak var titleLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        bkgdView.layer.cornerRadius = bkgdView.layer.bounds.height/2
        bkgdView.layer.shadowColor = UIColor.systemGray.cgColor
        bkgdView.layer.shadowOpacity = 0.5
        bkgdView.layer.shadowRadius = 2
        bkgdView.layer.shadowOffset = CGSize(width: 4, height: 4)
        
        titleLbl.textColor = .systemBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var tokenTF: UITextField!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var detailsHeightConstraint: NSLayoutConstraint!
    
    var defaultHeight: CGFloat!
    var checkToken : (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Style addBtn.
        addBtn.layer.shadowOpacity = 0.2
        addBtn.layer.shadowRadius = 2
        addBtn.layer.shadowOffset = CGSize(width: 2, height: 4)
        
        defaultHeight = detailsHeightConstraint.constant
        detailsHeightConstraint.constant = 60
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            expand()
        } else {
            collapse()
        }
    }

    @IBAction func addBtnTapped(_ sender: UIButton) {
        // if the closure is defined (not nil)
        // then execute the code inside the checkToken closure
        checkToken?()
    }
    
    func expand() {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: {
            self.detailsHeightConstraint.constant = self.defaultHeight
            self.backgroundColor = .systemBackground.withAlphaComponent(0.5)
            self.layoutIfNeeded()
        })
        
        hideViews(show: false)
    }
    
    func collapse() {
        hideViews(show: true)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveLinear, animations: {
            self.detailsHeightConstraint.constant = CGFloat(60.0)
            self.backgroundColor = .clear
            self.layoutIfNeeded()
        })
    }
    
    func hideViews(show: Bool) {
        if show {
            self.tokenTF.isHidden = true
            self.addBtn.isHidden = true
        } else {
            self.tokenTF.isHidden = false
            self.addBtn.isHidden = false
        }
    }
}
