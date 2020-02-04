//
//  AddContactController.swift
//  VisaCalAssignment
//
//  Created by Igor Korshunov on 04/02/2020.
//  Copyright © 2020 Igor Korshunov. All rights reserved.
//

import UIKit

fileprivate let paddingTop: CGFloat = 70

protocol AddContactControllerDelegate: AnyObject {
    func contactSavedSuccessfully(contact: Contact)
}

class AddContactController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    weak var delegate: AddContactControllerDelegate?
    
    private var imagePicker = UIImagePickerController()
    
    var contact: Contact? {
        didSet{
            if let contact = contact {
                emailTextField.text = contact.email
                phoneNumberTextField.text = contact.phoneNumber
                guard let imageData = contact.image else { return }
                contactImageView.image = UIImage(data: imageData)
            }
        }
    }
    
    private lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "email"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        textField.delegate = self
        return textField
    }()
    
    private lazy var phoneNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "phone number"
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.backgroundColor = UIColor(white: 0, alpha: 0.03)
        return textField
    }()
    
    private let contactImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .lightGray
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var addImageButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.addTarget(self, action: #selector(fetchPhotos), for: UIControl.Event.touchUpInside)
        button.setTitle("Add Photo", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.addTarget(self, action: #selector(cancelButtonAction), for: UIControl.Event.touchUpInside)
        button.setTitle("Cancel", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.addTarget(self, action: #selector(saveButtonAction), for: UIControl.Event.touchUpInside)
        button.setTitle("Save", for: UIControl.State.normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .white
        view.addSubview(contactImageView)
        
        contactImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: paddingTop, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 80)
        contactImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contactImageView.layer.cornerRadius = 80 / 2
        
        
        view.addSubview(saveButton)
        saveButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: view.trailingAnchor, paddingTop: paddingTop, paddingLeft: 0, paddingBottom: 0, paddingRight: 5, width: 80, height: 40)
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.topAnchor, left: view.leadingAnchor, bottom: nil, right: nil, paddingTop: paddingTop, paddingLeft: 0, paddingBottom: 0, paddingRight: 25, width: 80, height: 40)
        
        view.addSubview(addImageButton)
        addImageButton.anchor(top: contactImageView.bottomAnchor, left: nil, bottom: nil, right: nil, paddingTop: 16, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 80, height: 40)
        addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, phoneNumberTextField])
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.anchor(top: addImageButton.bottomAnchor, left: view.leadingAnchor, bottom: nil, right: view.trailingAnchor, paddingTop: 25, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 80)
        
        
    }
    
    @objc private func cancelButtonAction() {
        dismiss(animated: true, completion: nil)
    }
    
    
    @objc private func saveButtonAction() {
        guard let email = emailTextField.text,
            let phoneNumber = phoneNumberTextField.text else {
                showAlertWithTitle(title: "Missing data", message: "Email and phone are required")
                return
        }
        
        let imageData = contactImageView.image?.jpegData(compressionQuality: 1)
        
        if isContactDetailsValid(email: email, phone: phoneNumber) == false {
            showAlertWithTitle(title: "Missing data", message: "Email and phone are required")
            return
        }
        
        _ = textFieldShouldReturn(emailTextField)
        
        
        if let prevContact = contact {
            PersistentManager.shared.removeContact(contact: prevContact) { [weak self] (error: Error?) in
                if let error = error {
                    self?.showAlertWithTitle(title: "Error", message: "Failed update contact. \(error.localizedDescription)")
                    return
                }
            }
        }
        saveContact(email: email, phoneNumber: phoneNumber, imageData: imageData)
    }
    
    private func saveContact(email: String, phoneNumber: String, imageData: Data?){

        let contact = Contact(email: email, phoneNumber: phoneNumber, image: imageData)
        PersistentManager.shared.addContact(contact: contact) { [weak self] (error: Error?) in
            if let error = error {
                self?.showAlertWithTitle(title: "Error", message: error.localizedDescription)
                return
            }
            self?.delegate?.contactSavedSuccessfully(contact: contact)
            DispatchQueue.main.async {
                self?.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    private func isContactDetailsValid(email: String, phone: String) -> Bool{
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespaces)
        if trimmedEmail.isEmpty || trimmedPhone.isEmpty {
            return false
        }
        let charcterSet  = NSCharacterSet(charactersIn: "+0123456789").inverted
        let inputString = phone.components(separatedBy: charcterSet)
        let filtered = inputString.joined(separator: "")
        return  phone == filtered
    }
    
    @objc private func fetchPhotos(){
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.mediaTypes = ["public.image", "public.movie"]
            imagePicker.allowsEditing = false

            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        defer {
            picker.dismiss(animated: true, completion: nil)
        }
        self.contactImageView.image = image
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        //textField code

        textField.resignFirstResponder()  //if desired
        return true
    }

    private func showAlertWithTitle(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (_) in
            
        }
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    

}
