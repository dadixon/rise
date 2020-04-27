//
//  FirebaseManager.swift
//  Rise
//
//  Created by Domonique Dixon on 2/19/20.
//  Copyright © 2020 Domonique Dixon. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    private let collectionName = "employees"
    
    private init() {
//        let settings = db.settings
//        settings.areTimestampsInSnapshotsEnabled = true
//        db.settings = settings
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true

        db.settings = settings
    }
    
    func addEmployee(uid: String, fullName: String, notes: [[String: Any]], completionHandler: @escaping (_ id: String, _ error: Error?) -> Void) {
        let newMember = db.collection(collectionName).document()
        
        newMember.setData([
            "fullName": fullName.base64Encode()!,
            "userId": uid,
            "timestamp": Timestamp().seconds,
            "notes" : notes
        ]) { (error) in
            if error != nil {
                completionHandler("", error)
            } else {
                completionHandler(newMember.documentID, nil)
            }
        }
    }
    
    func getEmployees(uid: String, completionHandler: @escaping (_ result: DataModel, _ error: Error?) -> Void) {
        db.collection(collectionName).whereField("userId", isEqualTo: uid)
            .getDocuments() { (querySnapshot, err) in

                if querySnapshot != nil {
                    var dataModel = DataModel(members: [])
                    var members = [Member]()
                    
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        
                        var comments: [Comment] = []

                        for comment in data["notes"] as! [Any] {
                            let value = comment as! [String: Any]
                            let date = value["date"] as! String
                            let timestamp = value["timestamp"] as! Int64
                            let note = value["note"] as! String
                            
                            let formatter = DateFormatter()
                            formatter.dateFormat = "yyyy-M-dd"
                            let dateFromString = formatter.date(from: date)
                                                    
                            comments.append(Comment(date: dateFromString!, comment: note.base64Decode() ?? "No note", timestamp: timestamp))
                        }
                        
                        var member: Member
                        let fullName = data["fullName"] as! String
                        
                        if comments.count > 0 {
                            let orderedComments = comments.sorted(by: {($0).date.compare(($1).date) == .orderedDescending})
                            
                            member = Member(id: document.documentID, fullName: fullName.base64Decode() ?? "", latest: orderedComments[0].date, comments: orderedComments)
                        } else {
                            member = Member(id: document.documentID, fullName: fullName.base64Decode() ?? "", latest: nil, comments: [])
                        }
                        
                        members.append(member)
                    }
                                    
                    dataModel.members = Utility.sortByLatestComment(members: members)
                    completionHandler(dataModel, err)
                } else {
                    completionHandler(DataModel(members: []), err)
                }
        }
    }
    
    func getEmployee(id: String, completionHandler: @escaping (_ result: Member?, _ error: Error?) -> Void) {
        db.collection(collectionName).document(id)
            .getDocument() { (document, err) in
            if let document = document, document.exists {
                let data = document.data()
                var member: Member
                var comments: [Comment] = []

                for comment in data!["notes"] as! [Any] {
                    let value = comment as! [String: Any]
                    let date = value["date"] as! String
                    let timestamp = value["timestamp"] as! Int64
                    let note = value["note"] as! String
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-M-dd"
                    let dateFromString = formatter.date(from: date)
                    
                    comments.append(Comment(date: dateFromString!, comment: note.base64Decode() ?? "No note", timestamp: timestamp))
                }
                
                let fullName = data!["fullName"] as! String
                
                if comments.count > 0 {
                    let orderedComments = comments.sorted(by: {($0).date.compare(($1).date) == .orderedDescending})
                    
                    member = Member(id: document.documentID, fullName: fullName.base64Decode() ?? "", latest: orderedComments[0].date, comments: orderedComments)
                } else {
                    member = Member(id: document.documentID, fullName: fullName.base64Decode() ?? "", latest: nil, comments: [])
                }
                completionHandler(member, nil)
            } else {
                completionHandler(nil, err)
            }
        }
    }

    func updateEmployee(eid: String, data: [String: Any], completionHandler: @escaping (_ error: Error?) -> Void) {
        db.collection(collectionName).document(eid).updateData(data) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func deleteEmployee(eid: String, completionHandler: @escaping (_ error: Error?) -> Void) {
        db.collection(collectionName).document(eid).delete { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func deleteEmployeesBatch(data: [Member], completionHandler: @escaping (_ error: Error?) -> Void) {
        let batch = db.batch()

        for member in data {
            let sfRef = db.collection(collectionName).document(member.id)
            batch.deleteDocument(sfRef)
        }

        batch.commit() { err in
            if let err = err {
                completionHandler(err)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func addNote(eid: String, note: Comment, completionHandler: @escaping (_ error: Error?) -> Void) {
        db.collection(collectionName).document(eid).updateData([
            "notes" : FieldValue.arrayUnion([note.print()])]) { (error) in
                if error != nil {
                    completionHandler(error)
                } else {
                    completionHandler(nil)
                }
        }
    }
    
    func updateNotes(member: Member, comment: Comment, completionHandler: @escaping (_ error: Error?) -> Void) {
        var notes = [[String: Any]]()
        
        for note in member.comments {
            if note.timestamp == comment.timestamp {
                let tempComment = Comment(date: comment.date, comment: comment.comment, timestamp: comment.timestamp)
                notes.append(tempComment.print())
            } else {
                notes.append(note.print())
            }
        }
        
        db.collection(collectionName).document(member.id).updateData(["notes": notes]) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func deleteNote(member: Member, comment: Comment, completionHandler: @escaping (_ results: [Comment]?, _ erorr: Error?) -> Void) {
        var notes = [[String: Any]]()
        var comments = member.comments
        
        comments.removeAll { (note) -> Bool in
            note.timestamp == comment.timestamp
        }
        
        for note in comments {
            notes.append(note.print())
        }
        
        db.collection(collectionName).document(member.id).updateData(["notes": notes]) { (error) in
            if error != nil {
                completionHandler(nil, error)
            } else {
                completionHandler(comments, nil)
            }
        }
    }
    
    func deleteCommentBatch(data: [DeleteModel], completionHandler: @escaping (_ error: Error?) -> Void) {
        let batch = db.batch()
        
        for model in data {
            var notes = [[String: Any]]()
            var comments = model.member.comments
            
            comments.removeAll { (note) -> Bool in
                note.timestamp == model.comment.timestamp
            }
            
            for note in comments {
                notes.append(note.print())
            }
        
            let sfRef = db.collection(collectionName).document(model.member.id)
            
            batch.updateData(["notes": notes], forDocument: sfRef)
        }

        batch.commit() { err in
            if let err = err {
                completionHandler(err)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func batchAdd(data: [[String: Any]]) {
        let batch = db.batch()

        for item in data {
            let nycRef = db.collection("users").document(item["UserId"] as! String)
            batch.setData(item, forDocument: nycRef)

        }
        // Commit the batch
        batch.commit() { err in
            if let err = err {
                print("Error writing batch \(err)")
            } else {
                print("Batch write succeeded.")
            }
        }
    }
    
    func addSettings(data: [String: Any], completionHandler: @escaping (_ error: Error?) -> Void) {
        let newSettings = db.collection("users").document(data["UserId"] as! String)
        var tempData = data
        
        tempData["Date"] = Timestamp(date: Date()).seconds
        
        newSettings.setData(tempData) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func deleteSettings(uid: String, completionHandler: @escaping (_ error: Error?) -> Void) {
        db.collection("users").document(uid).delete { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func updateSettings(uid: String, data: [String: Any], completionHandler: @escaping (_ error: Error?) -> Void) {
        let settings = db.collection("users").document(uid)
        
        settings.updateData(data) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func getSettings(uid: String, completionHandler: @escaping (_ error: Error?) -> Void) {
        db.collection("users").whereField("UserId", isEqualTo: uid)
            .getDocuments() { (querySnapshot, err) in
        
            for document in querySnapshot!.documents {
                let data = document.data()
                
                if let mainTitle = data["headerName"] as? String {
                    UserDefaults.set(mainTitle: mainTitle)
                }
                
                if let reminderStartDays = data["reminderStartDay"] as? Int {
                    UserDefaults.set(reminderStartDays: reminderStartDays)
                }
                
                if let email = data["Email"] as? String {
                    UserDefaults.set(userEmail: email)
                }
                
                if let fName = data["First_Name"] as? String {
                    UserDefaults.set(userFirstName: fName)
                }
                
                if let order = data["isOrderAscending"] as? Bool {
                    UserDefaults.set(sortOrder: order)
                }
                
                if let company = data["Company"] as? String {
                    UserDefaults.set(userCompany: company)
                }
                
                if let isReminder = data["isReminder"] as? Bool {
                    UserDefaults.set(useTimeManagedReminder: isReminder)
                }
                
                if let storeDays = data["storeDays"] as? Int {
                    UserDefaults.set(storeDays: storeDays)
                }
                
                if let lName = data["Last_Name"] as? String {
                    UserDefaults.set(userLastName: lName)
                }
                
                if let people = data["Number_of_People"] as? String {
                    UserDefaults.set(userAmount: people)
                }
                
                if let phone = data["Phone"] as? String {
                    UserDefaults.set(userPhone: phone)
                }
                
//                if let isNew = data["New"] as? Bool {
//                    UserDefaults.set(userIsNew: isNew)
//                }
                
                if let hour = data["reminderHours"] as? Int,
                    let mintues = data["reminderMinutes"] as? Int {
                    let testDate = "\(self.addIntegerPrefix(number: hour)):\(self.addIntegerPrefix(number: mintues))"
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "H:mm"
                    dateFormatter.calendar = NSCalendar.current
                    dateFormatter.timeZone = TimeZone.current
                                    
                    let dt = dateFormatter.date(from: testDate)
                    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
                    dateFormatter.dateFormat = "H:mm"

                    UserDefaults.set(timeManagedReminder: dt!)
                }
            }
            
            completionHandler(err)
        }
    }
    
    private func addIntegerPrefix(number: Int) -> String {
        if number < 10 {
            return "0\(number)"
        } else {
            return "\(number)"
        }
    }
}
