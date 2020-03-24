//
//  Library.swift
//  Rise
//
//  Created by Domonique Dixon on 2/21/20.
//  Copyright © 2020 Domonique Dixon. All rights reserved.
//

import Foundation

class Library {
    static let shared = Library()
    
    let backEnd = FirebaseManager.shared
    
    var data = DataModel(members: [])
    
    private init() {}
    
    func addMember(uid: String, fullName: String, notes: [[String: Any]], completionHandler: @escaping (_ error: Error?) -> Void) {
        backEnd.addEmployee(uid: uid, fullName: fullName, notes: notes) { (id, error) in
            if error != nil {
                completionHandler(error)
            } else {
                Library.shared.data.members.append(Member(id: id, fullName: fullName, latest: nil, comments: []))
                print("Add Member \(Library.shared.data)")
                completionHandler(nil)
            }
        }
    }
    
    func getMembers(uid: String, completionHandler: @escaping (_ error: Error?) -> Void) {
        backEnd.getEmployees(uid: uid) { (results, error) in
            if error != nil {
                completionHandler(error)
            } else {
                Library.shared.data = results
                    
                let sortedMembers = Utility.sortByLatestComment(members: results.members)
                
                Library.shared.data.members = sortedMembers
                
                print("Get Members \(Library.shared.data)")
                completionHandler(nil)
            }
        }
    }
    
    func updateMember(eid: String, data: [String: Any], completionHandler: @escaping (_ error: Error?) -> Void) {
        for (index, member) in Library.shared.data.members.enumerated() {
            if member.id == eid {
                Library.shared.data.members[index].fullName = data["fullName"] as! String
                break
            }
        }
        
        backEnd.updateEmployee(eid: eid, data: data) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                print("Update Member \(Library.shared.data)")
                completionHandler(nil)
            }
        }
    }
    
    func deleteMember(eid: String, completionHandler: @escaping (_ error: Error?) -> Void) {
        for (index, member) in Library.shared.data.members.enumerated() {
            if member.id == eid {
                Library.shared.data.members.remove(at: index)
                break
            }
        }
        
        backEnd.deleteEmployee(eid: eid) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                print("Delete Member \(Library.shared.data)")
                completionHandler(nil)
            }
        }
    }
    
    func deleteAllMembers(uid: String, completionHandler: @escaping (_ error: Error?) -> Void) {
        Library.shared.data = DataModel(members: [])
        
        backEnd.deleteEmployeesBatch(data: Library.shared.data.members) { (error) in
            if error != nil {
                completionHandler(error)
            }
        }
    }
    
    func addComment(eid: String, comment: Comment, completionHandler: @escaping (_ error: Error?) -> Void) {
        for (index, member) in Library.shared.data.members.enumerated() {
            if member.id == eid {
                Library.shared.data.members[index].comments.append(comment)
//                Utility.setLatest(eid: eid)
                break
            }
        }
        
        backEnd.addNote(eid: eid, note: comment) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                print("Add Comment \(Library.shared.data)")
                completionHandler(nil)
            }
        }
    }
    
    func updateComment(eid: String, comment: Comment, completionHandler: @escaping (_ error: Error?) -> Void) {
        for (index, member) in Library.shared.data.members.enumerated() {
            if member.id == eid {
                for (tempIndex, tempComment) in Library.shared.data.members[index].comments.enumerated() {
                    if tempComment.timestamp == comment.timestamp {
                        Library.shared.data.members[index].comments[tempIndex] = tempComment
                    }
                    break
                }
//                Utility.setLatest(eid: eid)
                break
            }
        }
        
//        backEnd.updateNotes(eid: eid, comment: comment) { (error) in
//            if error != nil {
//                completionHandler(error)
//            } else {
//                print("Update Comment \(Library.shared.data)")
//                completionHandler(nil)
//            }
//        }
    }
    
    func deleteComment(eid: String, comment: Comment, completionHandler: @escaping (_ error: Error?) -> Void) {
        for (index, member) in Library.shared.data.members.enumerated() {
            if member.id == eid {
                Library.shared.data.members[index].comments.removeAll { (note) -> Bool in
                    return note.timestamp == comment.timestamp
                }
//                Utility.setLatest(eid: eid)
                break
            }
        }
        
//        backEnd.deleteNote(eid: eid, comment: comment) { (error) in
//            if error != nil {
//                completionHandler(error)
//            } else {
//                print("Delete Comment \(Library.shared.data)")
//                completionHandler(nil)
//            }
//        }
    }
    
    func deleteCommentBatch(data: [DeleteModel], completionHandler: @escaping (_ error: Error?) -> Void) {
        var rv = [[String: Any]]()
        
        for model in data {
            var memberIndex = -1
            
            for (index, member) in Library.shared.data.members.enumerated() {
                if member.id == model.member.id {
                    memberIndex = index
                }
            }
            
            var notes = [[String: Any]]()
            
            Library.shared.data.members[memberIndex].comments.removeAll { (note) -> Bool in
                note.timestamp == model.comment.timestamp
            }
            
            for note in Library.shared.data.members[memberIndex].comments {
                notes.append(note.print())
            }
                        
            rv.append([model.member.id: notes])
        }
        
//        backEnd.deleteCommentBatch(data: rv) { (error) in
//            if error != nil {
//                completionHandler(error)
//            } else {
//                completionHandler(nil)
//            }
//        }
    }
    
    func addSettings(data: [String: Any], completionHandler: @escaping (_ error: Error?) -> Void) {
        backEnd.addSettings(data: data) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func updateSettings(uid: String, data: [String: Any], completionHandler: @escaping (_ error: Error?) -> Void) {
        backEnd.updateSettings(uid: uid, data: data) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
    
    func getSettings(uid: String, completionHandler: @escaping (_ error: Error?) -> Void) {
        backEnd.getSettings(uid: uid) { (error) in
            if error != nil {
                completionHandler(error)
            } else {
                completionHandler(nil)
            }
        }
    }
}
