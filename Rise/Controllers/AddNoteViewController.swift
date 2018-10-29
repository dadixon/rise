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

        title = "Recognition Note"
        saveBtn.setTitle("Save Note", for: .normal)
        dateFormatter.dateFormat = "MM-dd-yyyy"
        createdDate.text = dateFormatter.string(from: Date())
        editNote = false
        
        noteTextArea.layer.borderColor = UIColor.black.cgColor
        noteTextArea.layer.borderWidth = 1.0
        
        if note != nil {
            editNote = true
            noteTextArea.text = note.text
            createdDate.text = dateFormatter.string(from: note.created!)
        }
    }
    
    private func saveNote() {
        let note = Note(context: context)
        
        guard let text = noteTextArea.text else {
            SVProgressHUD.showError(withStatus: "Please leave a note")
            return
        }
        
        guard let created = createdDate.text else {
            SVProgressHUD.showError(withStatus: "Please select a date")
            return
        }
        
        note.text = text
        note.created = dateFormatter.date(from: created)
        
        employee.addToNotes(note)
        
        let notes = employee.notes?.sorted(by: {($0 as! Note).created?.compare(($1 as! Note).created!) == .orderedDescending}) as! [Note]
        
        employee.latest = notes[0].created
        
        do {
            try context.save()
            print("saved")
            SVProgressHUD.showSuccess(withStatus: "Note Saved")
        } catch {
            SVProgressHUD.showError(withStatus: "Error saving item")
            print("Error saving context \(error)")
        }
    }
    
    private func updateNote(note: Note) {
        guard let text = noteTextArea.text else {
            SVProgressHUD.showError(withStatus: "Please leave a note")
            return
        }
        
        guard let created = createdDate.text else {
            SVProgressHUD.showError(withStatus: "Please select a date")
            return
        }
        
        note.setValue(text, forKey: "text")
        note.setValue(dateFormatter.date(from: created), forKey: "created")
        
        let notes = employee.notes?.sorted(by: {($0 as! Note).created?.compare(($1 as! Note).created!) == .orderedDescending}) as! [Note]
        
        employee.latest = notes[0].created
        
        do {
            try context.save()
            SVProgressHUD.showSuccess(withStatus: "Note Updated")
        } catch {
            SVProgressHUD.showError(withStatus: "Error saving item")
            print("Error saving context \(error)")
        }
    }
    
    @IBAction func saveNoteClicked(_ sender: Any) {
        if editNote {
            updateNote(note: self.note)
        } else {
            saveNote()
        }
        
        if backTo == "Dashboard" {
            performSegue(withIdentifier: "unwindToEmployeeDashboard", sender: self)
        } else if backTo == "Details" {
            performSegue(withIdentifier: "unwindToEmployeeDetails", sender: self)
        }
    }
    
    @IBAction func dateFieldClicked(_ sender: Any) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        createdDate.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(self.datePickerFromValueChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func datePickerFromValueChanged(sender:UIDatePicker) {
        createdDate.text = dateFormatter.string(from: sender.date)
    }
}
