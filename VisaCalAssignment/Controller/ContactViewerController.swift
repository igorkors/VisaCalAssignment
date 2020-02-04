//
//  ContactViewerController.swift
//  VisaCalAssignment
//
//  Created by Igor Korshunov on 04/02/2020.
//  Copyright © 2020 Igor Korshunov. All rights reserved.
//

import UIKit

class ContactViewerController: UIViewController, UITextFieldDelegate {

    var contact: Contact! {
        didSet{
            emailLabel.text = contact.email
            phoneNumbeLabel.text = contact.phoneNumber
        }
    }
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 21)
        label.textAlignment = .left
        return label
    }()
    
    let phoneNumbeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 21)
        label.textAlignment = .left
        label.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        return label
    }()
    
    let emailDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = "email"
        return label
    }()
    
    let phoneNumbeDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textAlignment = .left
        label.text = "phone"
        return label
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.addTarget(self, action: #selector(cancelButtonAction), for: UIControl.Event.touchUpInside)
        button.setTitle("Cancel", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initSubviews()
    }
    
    @objc func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    private func initSubviews() {
        view.backgroundColor = .white
        navigationItem.title = "Contact Details"
        
        let emailStackView = UIStackView(arrangedSubviews: [emailDescriptionLabel, emailLabel])
        view.addSubview(emailStackView)
        emailStackView.axis = .vertical
        emailStackView.spacing = 10
        emailStackView.distribution = .fillEqually
        
        emailStackView.anchor(top: view.topAnchor, left: view.leadingAnchor, bottom: nil, right: view.trailingAnchor, paddingTop: 200, paddingLeft: 25, paddingBottom: 0, paddingRight: 25, width: 0, height: 50)
        
        let phoneStackView = UIStackView(arrangedSubviews: [phoneNumbeDescriptionLabel, phoneNumbeLabel])
        view.addSubview(phoneStackView)
        phoneStackView.axis = .vertical
        phoneStackView.spacing = 10
        phoneStackView.distribution = .fillEqually
        
        phoneStackView.anchor(top: emailStackView.bottomAnchor, left: view.leadingAnchor, bottom: nil, right: view.trailingAnchor, paddingTop: 25, paddingLeft: 25, paddingBottom: 0, paddingRight: 25, width: 0, height: 50)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(phoneCallAction))
        phoneStackView.addGestureRecognizer(tap)
        
    }

    @objc private func phoneCallAction(){
        if let url = URL(string: "tel://\(phoneNumbeLabel.text!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

}
