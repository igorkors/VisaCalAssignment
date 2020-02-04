//
//  ContactCell.swift
//  VisaCalAssignment
//
//  Created by Igor Korshunov on 04/02/2020.
//  Copyright © 2020 Igor Korshunov. All rights reserved.
//

import UIKit

class ContactCell: UITableViewCell {
    
    var contact: Contact? {
        didSet{
            if let imageData = contact?.image {
                contactImageView.image = UIImage(data: imageData)
            }
            emailLabel.text = contact?.email
            phoneNumbeLabel.text = contact?.phoneNumber
        }
    }
    
    private let contactImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    private let phoneNumbeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initSubViews()
    }
    
    private func initSubViews() {
        self.addSubview(contactImageView)
        
        contactImageView.anchor(top: nil, left: leadingAnchor, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        contactImageView.layer.cornerRadius = 80 / 2
        contactImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [emailLabel, phoneNumbeLabel])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
        addSubview(stackView)
        
        stackView.anchor(top: nil, left: contactImageView.trailingAnchor, bottom: nil, right: trailingAnchor, paddingTop: 0, paddingLeft: 16, paddingBottom: 0, paddingRight: 16, width: 0, height: 50)
        stackView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
