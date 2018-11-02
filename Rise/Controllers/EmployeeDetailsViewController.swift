//
//  EmployeeDetailsViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 9/14/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import SVProgressHUD

class EmployeeDetailsViewController: UIViewController {

    @IBOutlet weak var notesTable: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var employeeDetailsLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    
    var employee = Employee()
    var notes = [Note]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var deleteEmployeeIndexPath: IndexPath? = nil
    var selectedEmployeeIndexPath: IndexPath? = nil
    var selectedNote: Note? = nil
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        setupNavigation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        notes = sortedNotes()
        self.notesTable.reloadData()
        
        nameLabel.text = employee.firstName! + " " + employee.lastName!
        employeeDetailsLabel.text = setNoteDetails(count: notes.count, days: userDefault.integer(forKey: "days"))
        selectedNote = nil
    }
    
    private func setup() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
        
        notesTable.delegate = self
        notesTable.dataSource = self
        notesTable.tableFooterView = UIView()
        
        notes = sortedNotes()
        
        nameTextField.delegate = self
        nameTextField.isHidden = true
        nameLabel.isUserInteractionEnabled = true
        let aSelector : Selector = #selector(lblTapped)
        let tapGesture = UITapGestureRecognizer(target: self, action: aSelector)
        tapGesture.numberOfTapsRequired = 1
        nameLabel.addGestureRecognizer(tapGesture)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(confirmUpdateEmployee))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func setupNavigation() {
        self.navigationController!.navigationItem.title = "\(employee.firstName!) \(employee.lastName!)"
        
        let button1 = UIBarButtonItem(title: "+ Note", style: .plain, target: self, action: #selector(addNoteClicked))
        self.navigationItem.rightBarButtonItem  = button1
    }
    
    private func sortedNotes() -> [Note] {
        return employee.notes?.sorted(by: {($0 as! Note).created?.compare(($1 as! Note).created!) == .orderedDescending}) as! [Note]
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
        
        return "\(notes.count) " + noteText + " in the past \(days) " + dayText
    }
    
    func deleteNote(note: Note) {
        context.delete(note)
        
        do {
            try context.save()
        } catch {
            SVProgressHUD.showSuccess(withStatus: "Note has been deleted")
        }
    }
    
    func updateLatestNote() {
        let notes = employee.notes?.sorted(by: {($0 as! Note).created?.compare(($1 as! Note).created!) == .orderedDescending}) as! [Note]
        
        if notes.count > 0 {
            employee.latest = notes[0].created
            
            do {
                try context.save()
            } catch {
                SVProgressHUD.showSuccess(withStatus: "Note has been deleted")
            }
        }
    }
    
    private func updateEmployee(employee: Employee) throws {
        guard let fullName = nameTextField.text, !fullName.isEmpty else {
            throw ErrorsToThrow.fullNameNotFound
        }
        
        let nameArray = fullName.components(separatedBy: " ")
        
        employee.setValue(nameArray[0], forKey: "firstName")
        employee.setValue(nameArray[1], forKey: "lastName")
        
        do {
            try context.save()
            SVProgressHUD.showSuccess(withStatus: "Employee Updated")
        } catch {
            print("Error saving context \(error)")
            throw ErrorsToThrow.canNotSave
        }
    }
    
    @objc func confirmUpdateEmployee() {
        nameTextField.isHidden = true
        nameLabel.isHidden = false
        nameLabel.text = nameTextField.text
        
        do {
            try updateEmployee(employee: employee)
        } catch ErrorsToThrow.fullNameNotFound {
            SVProgressHUD.showError(withStatus: "Please input a name")
        } catch ErrorsToThrow.canNotSave {
            SVProgressHUD.showError(withStatus: "Could not save")
        } catch {
            
        }
    }
    
    @objc func addNoteClicked() {
        performSegue(withIdentifier: "showAddNote", sender: nil)
    }
    
    @objc func lblTapped(){
        nameLabel.isHidden = true
        nameTextField.isHidden = false
        nameTextField.text = nameLabel.text
        nameTextField.becomeFirstResponder()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // navigationItem.title = nil
        
        if segue.identifier == "showAddNote" {
            let vc = segue.destination as! AddNoteViewController
                
            vc.employee = employee
            vc.note = selectedNote
            vc.backTo = "Details"
        }
    }
    
    @IBAction func unwindToEmployeesDetails(segue:UIStoryboardSegue) { }
}

extension EmployeeDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        deleteEmployeeIndexPath = indexPath
        
        let deleteAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Delete", handler: { (action, view, completionHandler) in
            
            let alert = UIAlertController(title: "Delete Note?", message: "Delete Note", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(_) in
                if let indexPath = self.deleteEmployeeIndexPath {
                    tableView.beginUpdates()
                    
                    self.deleteNote(note: self.notes[indexPath.row])
                    self.notes.remove(at: indexPath.row)
                    self.employeeDetailsLabel.text = self.setNoteDetails(count: self.notes.count, days: self.userDefault.integer(forKey: "days"))
                    self.updateLatestNote()
                    
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.deleteEmployeeIndexPath = nil
                    tableView.endUpdates()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedNote = notes[indexPath.row]
        
        performSegue(withIdentifier: "showAddNote", sender: nil)
    }
}

extension EmployeeDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeNoteCell", for: indexPath) as! NoteTableViewCell
        
        let note = notes[indexPath.row]
        
        cell.previewLabel.text = note.text
        cell.createdLabel.text = Utility.textFormat(from: note.created!)
        cell.backgroundColor = Utility.cellColor(from: note.created!)
        
        return cell
    }
}

extension EmployeeDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
//        nameTextField.isHidden = true
//        nameLabel.isHidden = false
//        nameLabel.text = nameTextField.text
//        updateEmployee(employee: employee)
        confirmUpdateEmployee()
        return true
    }
}
