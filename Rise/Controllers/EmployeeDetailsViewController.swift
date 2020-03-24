//
//  EmployeeDetailsViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 9/14/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import SVProgressHUD
import CoreData

class EmployeeDetailsViewController: UIViewController {

    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var employeeDetailsLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    var memberId: String!
    var member: Member?
    var comments = [Comment]()
    var deleteEmployeeIndexPath: IndexPath? = nil
    var selectedEmployeeIndexPath: IndexPath? = nil
    var selectedComment: Comment? = nil
    let userDefault = UserDefaults.standard
    var tap: UIGestureRecognizer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        getNotes()
    }
    
    private func setup() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
        
        notesTable.delegate = self
        notesTable.dataSource = self
        notesTable.tableFooterView = UIView()
                
        nameTextField.delegate = self
        nameTextField.isHidden = true
        nameLabel.isUserInteractionEnabled = true
        
        let aSelector : Selector = #selector(lblTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        nameLabel.addGestureRecognizer(tapGesture)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(confirmUpdateEmployee))
        tap!.cancelsTouchesInView = false
    }
    
    func setupNavigation() {
        if let member = member {
            self.navigationController!.navigationItem.title = "\(member.fullName)"
        }
        
        let button1 = UIBarButtonItem(title: "+ Note", style: .plain, target: self, action: #selector(addNoteClicked))
        self.navigationItem.rightBarButtonItem  = button1
    }
    
    private func setNoteDetails(count: Int, days: Int) -> String {
        var noteText = String()
        var dayText = String()
        
        switch count {
        case 1:
            noteText = "Note"
        default:
            noteText = "Notes"
        }
        
        switch days {
        case 1:
            dayText = "day"
        default:
            dayText = "days"
        }
        
        if days > 100 {
            return "\(comments.count) " + noteText
        } else {
            return "\(comments.count) " + noteText + " in the past \(days) " + dayText
        }
    }
    
    @objc func confirmUpdateEmployee() {
        guard let fullName = nameTextField.text, !fullName.isEmpty else {
            SVProgressHUD.showSuccess(withStatus: "Please input a name")
            return
        }
        
        nameTextField.isHidden = true
        nameLabel.isHidden = false
        nameLabel.text = nameTextField.text
        
        FirebaseManager.shared.updateEmployee(eid: memberId, data: ["fullName": fullName.base64Encode() ?? "No Name"]) { (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "Could not save")
            } else {
                SVProgressHUD.showSuccess(withStatus: "Employee Updated")
            }
        }
        
        self.view.removeGestureRecognizer(tap!)
    }
    
    @objc func addNoteClicked() {
        performSegue(withIdentifier: "showAddNote", sender: nil)
    }
    
    @objc func lblTapped(){
        nameLabel.isHidden = true
        nameTextField.isHidden = false
        nameTextField.text = nameLabel.text
        nameTextField.becomeFirstResponder()
        
        self.view.addGestureRecognizer(tap!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAddNote" {
            let vc = segue.destination as! AddNoteViewController

            vc.member = member
            vc.comment = selectedComment
            vc.backTo = "Details"
        }
    }
    
    private func getNotes() {
        SVProgressHUD.show()
        FirebaseManager.shared.getEmployee(id: memberId) { (member, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "There was an error retrieving this data")
            } else {
                if let member = member {
                    self.member = member
                    self.comments = member.comments
                    self.notesTable.reloadData()
                    
                    self.nameLabel.text = member.fullName
                    self.employeeDetailsLabel.text = self.setNoteDetails(count: self.comments.count, days: UserDefaults.storeDays)
                    self.selectedComment = nil
                    
                    self.setupNavigation()
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    @IBAction func unwindToEmployeesDetails(segue:UIStoryboardSegue) {
        getNotes()
    }
}

extension EmployeeDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        deleteEmployeeIndexPath = indexPath

        let deleteAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Delete", handler: { (action, view, completionHandler) in

            let alert = UIAlertController(title: "Delete Note?", message: "Delete Note", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(_) in
                if let indexPath = self.deleteEmployeeIndexPath {
                    if let member = self.member {
                        FirebaseManager.shared.deleteNote(member: member, comment: self.comments[indexPath.row]) { (results, error) in
                            if error != nil {
                                SVProgressHUD.showError(withStatus: "Could not delete note")
                            } else {
                                self.getNotes()
                                SVProgressHUD.showSuccess(withStatus: "Note deleted")
                            }
                        }
                    }
                    
                    self.deleteEmployeeIndexPath = nil
                }
                completionHandler(true)
            }))

            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

            self.present(alert, animated: true)
        })

        deleteAction.backgroundColor = UIColor.red

        let config = UISwipeActionsConfiguration(actions: [deleteAction])

        config.performsFirstActionWithFullSwipe = false
        return config
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration.init()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedComment = comments[indexPath.row]

        performSegue(withIdentifier: "showAddNote", sender: nil)
    }
}

extension EmployeeDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeNoteCell", for: indexPath) as! NoteTableViewCell
        
        let comment = comments[indexPath.row]
        
        cell.previewLabel.text = comment.comment
        cell.createdLabel.text = Utility.textFormat(from: comment.date)
        cell.backgroundColor = Utility.cellColor(from: comment.date)
        
        return cell
    }
}

extension EmployeeDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        confirmUpdateEmployee()
        return true
    }
}
