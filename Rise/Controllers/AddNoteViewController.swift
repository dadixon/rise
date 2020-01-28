//
//  AddNoteViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 9/14/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD

class AddNoteViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteTextArea: UITextView!
    @IBOutlet weak var createdDate: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var topConstraintDate: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintDate: NSLayoutConstraint!
    
//    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dateFormatter = DateFormatter()
    
    var employee = Employee()
    var note: Note!
    var editNote: Bool!
    var backTo: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
        
        if UIDevice.current.modelName == "iPhone 4" ||
            UIDevice.current.modelName == "iPhone 4s" ||
            UIDevice.current.modelName == "iPhone 5" ||
            UIDevice.current.modelName == "iPhone 5c" ||
            UIDevice.current.modelName == "iPhone 5s" {
            topConstraintDate.constant = 16
            bottomConstraintDate.constant = 16
        } else {
            topConstraintDate.constant = 28
            bottomConstraintDate.constant = 21
        }
    }
    
    private func setup() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
        
        titleLabel.text = "Note for " + employee.fullName!
        saveBtn.setTitle("Save Note", for: .normal)
        dateFormatter.dateFormat = "MM-dd-yyyy"
        createdDate.text = dateFormatter.string(from: Date())
        editNote = false
        
        noteTextArea.becomeFirstResponder()
        
        if note != nil {
            editNote = true
            noteTextArea.text = note.text
            createdDate.text = dateFormatter.string(from: note.created!)
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(AddEmployeeViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    private func saveNote() throws {
        guard let text = noteTextArea.text, !text.isEmpty else {
            throw ErrorsToThrow.noteTextNotFound
        }
        
        guard let created = createdDate.text, !created.isEmpty else {
            throw ErrorsToThrow.noteCreatedDateNotFound
        }
        
        guard let diffInDays = Calendar.current.dateComponents([.day], from: dateFormatter.date(from: created)!, to: Date()).day else {
            SVProgressHUD.showError(withStatus: "Unable to process")
            return
        }
        
        if diffInDays > UserDefaults.storeDays && UserDefaults.storeDays < 101 {
           throw ErrorsToThrow.tooFarBehind
        } else {
            CoreDataManager.shared.insertNote(text: text, created: dateFormatter.date(from: created), employee: employee) { (error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "Error saving item")
                } else {
                    SVProgressHUD.showSuccess(withStatus: "Note Saved")
                }
            }
        }
    }
    
    private func updateNote(note: Note) throws {
        guard let text = noteTextArea.text, !text.isEmpty else {
            throw ErrorsToThrow.noteTextNotFound
        }
        
        guard let created = createdDate.text, !created.isEmpty else {
            throw ErrorsToThrow.noteCreatedDateNotFound
        }
        
        guard let diffInDays = Calendar.current.dateComponents([.day], from: dateFormatter.date(from: created)!, to: Date()).day else {
            SVProgressHUD.showError(withStatus: "Unable to process")
            return
        }
        
        if diffInDays > UserDefaults.storeDays && UserDefaults.storeDays < 101 {
            throw ErrorsToThrow.tooFarBehind
        } else {
            CoreDataManager.shared.updateNote(text: text, created: dateFormatter.date(from: created), note: note, employee: employee) { (error) in
                if error != nil {
                    SVProgressHUD.showError(withStatus: "Error saving item")
                } else {
                    SVProgressHUD.showSuccess(withStatus: "Note Updated")
                }
            }
        }
    }
    
    @IBAction func saveNoteClicked(_ sender: Any) {
        if editNote {
            do {
                try updateNote(note: self.note)
                
                if backTo == "Dashboard" {
                    performSegue(withIdentifier: "unwindToEmployeeDashboard", sender: self)
                } else if backTo == "Details" {
                    performSegue(withIdentifier: "unwindToEmployeeDetails", sender: self)
                }
            } catch ErrorsToThrow.noteTextNotFound {
                SVProgressHUD.showError(withStatus: "Please leave a note")
            } catch ErrorsToThrow.noteCreatedDateNotFound {
                SVProgressHUD.showError(withStatus: "Please leave a note")
            } catch ErrorsToThrow.canNotSave {
                SVProgressHUD.showError(withStatus: "Error saving item")
            } catch ErrorsToThrow.tooFarBehind {
                SVProgressHUD.showError(withStatus: "Date is too far behind")
            } catch {
                
            }
        } else {
            do {
                try saveNote()
                
                if backTo == "Dashboard" {
                    performSegue(withIdentifier: "unwindToEmployeeDashboard", sender: self)
                } else if backTo == "Details" {
                    performSegue(withIdentifier: "unwindToEmployeeDetails", sender: self)
                }
            } catch ErrorsToThrow.noteTextNotFound {
                SVProgressHUD.showError(withStatus: "Please leave a note")
            } catch ErrorsToThrow.noteCreatedDateNotFound {
                SVProgressHUD.showError(withStatus: "Please leave a note")
            } catch ErrorsToThrow.canNotSave {
                SVProgressHUD.showError(withStatus: "Error saving item")
            } catch ErrorsToThrow.tooFarBehind {
                 SVProgressHUD.showError(withStatus: "Date is too far behind")
            } catch {
                
            }
        }
    }
    
    @IBAction func dateFieldClicked(_ sender: Any) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        var calendar = Calendar.current
        
        calendar.timeZone = NSTimeZone.local
        
        let dateFrom = calendar.startOfDay(for: Date())
        let minimumDate = calendar.date(byAdding: .day, value: -3, to: dateFrom)
        
        datePickerView.minimumDate = minimumDate
        datePickerView.maximumDate = dateFrom
        
        createdDate.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerFromValueChanged), for: UIControl.Event.valueChanged)
    }

    @objc func datePickerFromValueChanged(sender:UIDatePicker) {
        createdDate.text = dateFormatter.string(from: sender.date)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
