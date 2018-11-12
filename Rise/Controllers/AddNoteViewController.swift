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
import ChameleonFramework

class AddNoteViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var noteTextArea: UITextView!
    @IBOutlet weak var createdDate: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let dateFormatter = DateFormatter()
    
    var employee = Employee()
    var note: Note!
    var editNote: Bool!
    var backTo: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setup()
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
        
        if diffInDays > UserDefaults.storeDays {
           throw ErrorsToThrow.tooFarBehind
        } else {
            let note = Note(context: context)
            note.text = text
            note.created = dateFormatter.date(from: created)
            
            employee.addToNotes(note)
            
            let notes = employee.notes?.sorted(by: { (a, b) -> Bool in
                if (a as! Note) != nil, (b as! Note) != nil {
                    return (a as! Note).created?.compare((b as! Note).created!) == .orderedDescending
                } else {
                    return false
                }
            }) as! [Note]

            employee.latest = notes[0].created
            
            do {
                try context.save()
                SVProgressHUD.showSuccess(withStatus: "Note Saved")
            } catch {
                print("Error saving context \(error)")
                throw ErrorsToThrow.canNotSave
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
        
        if diffInDays > UserDefaults.storeDays {
            throw ErrorsToThrow.tooFarBehind
        } else {
            note.setValue(text, forKey: "text")
            note.setValue(dateFormatter.date(from: created), forKey: "created")
            
            let notes = employee.notes?.sorted(by: {($0 as! Note).created?.compare(($1 as! Note).created!) == .orderedDescending}) as! [Note]
            
            employee.latest = notes[0].created
            
            do {
                try context.save()
                SVProgressHUD.showSuccess(withStatus: "Note Updated")
            } catch {
                print("Error saving context \(error)")
                throw ErrorsToThrow.canNotSave
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
    
//    @IBAction func dateFieldClicked(_ sender: Any) {
//        let datePickerView:UIDatePicker = UIDatePicker()
//        datePickerView.datePickerMode = UIDatePicker.Mode.date
//        createdDate.inputView = datePickerView
//        datePickerView.addTarget(self, action: #selector(self.datePickerFromValueChanged), for: UIControl.Event.valueChanged)
//    }
//
//    @objc func datePickerFromValueChanged(sender:UIDatePicker) {
//        createdDate.text = dateFormatter.string(from: sender.date)
//    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
