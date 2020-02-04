//
//  ViewController.swift
//  VisaCalAssignment
//
//  Created by Igor Korshunov on 04/02/2020.
//  Copyright © 2020 Igor Korshunov. All rights reserved.
//

import UIKit

fileprivate let cellId = "cellId"

class ContactsMainViewController: UITableViewController, UISearchBarDelegate, AddContactControllerDelegate{
    
    private var contactsArr = [Contact]()
    
    private var filteredContactsArr = [Contact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getContacts()
        initSubviews()
    }
    
    func getContacts() {
        PersistentManager.shared.getContacts { [weak self] (contacts: [Contact]?, error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlertWithTitle(title: "Error", message: error.localizedDescription)
                    return
                }
                if let contacts = contacts {
                    self?.contactsArr = contacts
                    self?.filteredContactsArr = contacts
                    self?.tableView.reloadData()
                }else{
                    self?.showAlertWithTitle(title: "No contacts found", message: "")
                }
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        filteredContactsArr = contactsArr
        tableView.reloadData()
    }
    
    private func initSubviews() {
        self.view.backgroundColor = UIColor.white
        navigationItem.title = "Contacts"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchBar.delegate = self as UISearchBarDelegate
        
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addContactAction))
        navigationItem.rightBarButtonItem = rightBarButtonItem
        
        
        tableView.register(ContactCell.self, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContactsArr.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ContactCell
        cell.contact = filteredContactsArr[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ContactViewerController()
        vc.contact = filteredContactsArr[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
    }
        
        override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let delete = UIContextualAction(style: UIContextualAction.Style.destructive, title: "Delete") { [weak self] (action: UIContextualAction, view: UIView, nil) in
                self?.removeContactAtIndex(index: indexPath.row)
            }
            
            let edit = UIContextualAction(style: UIContextualAction.Style.normal, title: "Edit") { [weak self] (action: UIContextualAction, view: UIView, nil) in
                guard let contact = self?.filteredContactsArr[indexPath.row] else { return }
                self?.editContact(contact: contact)
            }
            return UISwipeActionsConfiguration(actions: [delete, edit])
        }
    
    @objc func addContactAction() {
        let vc = AddContactController()
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    func editContact(contact: Contact) {
        let vc = AddContactController()
        vc.contact = contact
        vc.delegate = self
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true, completion: nil)
    }
    
    private func showAlertWithTitle(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (_) in
            
        }
        
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func removeContactAtIndex(index: Int){
        let contact = filteredContactsArr[index]
        
        PersistentManager.shared.removeContact(contact: contact) { [weak self] (error: Error?) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlertWithTitle(title: "Failed delete contact", message: error.localizedDescription)
                    return
                }
                self?.getContacts()
            }
        }
    }
    
    //MARK: AddContactControllerDelegate

    func contactSavedSuccessfully(contact: Contact) {
        self.getContacts()
    }
    
    
    //MARK: UISearchBarDelegate
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar){
        filteredContactsArr = contactsArr
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        let filtered = contactsArr.filter { (contact: Contact) -> Bool in
            contact.email.lowercased().range(of: searchText.lowercased()) != nil ||
                contact.phoneNumber.range(of: searchText) != nil
        }
        filteredContactsArr = filtered
        tableView.reloadData()
    }
}
