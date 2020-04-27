//
//  EmployeesTableViewController.swift
//  Rise
//
//  Created by Domonique Dixon on 9/13/18.
//  Copyright © 2018 Domonique Dixon. All rights reserved.
//

import UIKit
import CoreData
import SVProgressHUD
import Firebase

class EmployeesTableViewController: UITableViewController {

    @IBOutlet weak var addEmployeeBtn: UIBarButtonItem!
    @IBOutlet weak var settingsBtn: UIBarButtonItem!
    
    let userDefaults = UserDefaults.standard
    
    var members = [Member]()
    var filteredMembers = [Member]()
    let searchController = UISearchController(searchResultsController: nil)
    var deleteMemberIndexPath: IndexPath? = nil
    var selectedMemberIndexPath: IndexPath? = nil
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.tableFooterView = UIView()
        self.tableView.backgroundView = nil
        
        setup()
        setupNavigation()
        
        members = [Member]()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        members = [Member]()
        self.tableView.reloadData()
        
        Auth.auth().addStateDidChangeListener({ (auth, user) in
            guard let _ = auth.currentUser else {
                self.performSegue(withIdentifier: "viewLogin", sender: nil)
                return
            }
            guard let user = user else {
                self.performSegue(withIdentifier: "viewLogin", sender: nil)
                return
            }
            
            guard !UserDefaults.userUID.isEmpty else {
                self.performSegue(withIdentifier: "viewLogin", sender: nil)
                return
            }
            
            self.user = user
            self.migration(id: self.user.uid)
            
            
            FirebaseManager.shared.getSettings(uid: user.uid) { (error) in
                if error != nil {
                    
                } else {
                    self.title = UserDefaults.mainTitle
                    self.getMembers()
                }
            }
        })
    }
    
    private func setup() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
    }
    
    private func setupNavigation() {
        self.title = UserDefaults.mainTitle
        
        settingsBtn.title = "Settings"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func getMembers() {
        SVProgressHUD.show(withStatus: "Loading")
        FirebaseManager.shared.getEmployees(uid: self.user.uid) { (results, error) in
            if error != nil {
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: "There was a problem getting your data")
            } else {
                if UserDefaults.storeDays < 101 {
                    Utility.deleteAllOldNotes(members: results.members) { (error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        } else {
                            self.members = Utility.sortByLatestComment(members: results.members)
                            self.tableView.reloadData()
                            self.resetTable(members: self.members)
                            SVProgressHUD.dismiss()
                        }
                    }
                }
            }
        }
    }
    
    private func resetTable(members: [Member]) {
        if members.count == 0 {
            tableView.backgroundView = BackgroundView()
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredMembers = members.filter({( member : Member) -> Bool in
            return (member.fullName.lowercased().contains(searchText.lowercased()))
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    @IBAction func unwindToEmployeesDashboard(segue:UIStoryboardSegue) {
        self.title = UserDefaults.mainTitle
        self.getMembers()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredMembers.count
        }
        return members.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeTableViewCell
        let member: Member?
        
        if isFiltering() {
            member = filteredMembers[indexPath.row]
        } else {
            member = members[indexPath.row]
        }
        
        guard (member?.fullName) != nil else {
            return cell
        }
        
        cell.nameLabel.text = member?.fullName
        
        cell.noteCountLabel.text = "\(member!.comments.count) " + Utility.formatPlural(count: member!.comments.count, object: "Note")
        
        if let latest = member?.latest {
            cell.createdLabel.text = Utility.textFormat(from: latest)
            cell.backgroundColor = Utility.cellColor(from: latest)
        } else {
            cell.createdLabel.text = ""
            cell.backgroundColor = Design.Color.ListNotes.noNotes
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        deleteMemberIndexPath = indexPath
        
        let deleteAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Delete", handler: { (action, view, completionHandler) in
            
            let alert = UIAlertController(title: "Delete \(UserDefaults.mainTitle)?", message: "Delete \(UserDefaults.mainTitle)", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(_) in
                if let indexPath = self.deleteMemberIndexPath {
                    
                    var tableData = [Member]()
                    
                    if self.isFiltering() {
                        tableData = self.filteredMembers
                    } else {
                        tableData = self.members
                    }
                    
                    FirebaseManager.shared.deleteEmployee(eid: tableData[indexPath.row].id) { (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: "Could not delete \(UserDefaults.mainTitle)")
                        } else {
                            self.members.removeAll { (member) -> Bool in
                                member.id == tableData[indexPath.row].id
                            }

                            self.filteredMembers.removeAll { (member) -> Bool in
                                member.id == tableData[indexPath.row].id
                            }
                            
                            self.tableView.beginUpdates()
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            self.deleteMemberIndexPath = nil
                            self.tableView.endUpdates()
                            
                            if self.isFiltering() {
                                tableData = self.filteredMembers
                            } else {
                                tableData = self.members
                            }
                            
                            self.resetTable(members: tableData)
                            
                            SVProgressHUD.showSuccess(withStatus: "\(UserDefaults.mainTitle) has been deleted")
                        }
                    }
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        selectedMemberIndexPath = indexPath
        
        let viewAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "View", handler: { (action, view, completionHandler) in
            
            self.performSegue(withIdentifier: "showEmployee", sender: self)
            
            completionHandler(true)
        })
        
        viewAction.backgroundColor = Design.Color.Secondary.darkGrey
        
        let config = UISwipeActionsConfiguration(actions: [viewAction])
        
        return config
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedMemberIndexPath = indexPath
        
        performSegue(withIdentifier: "showAddNote", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellContentView  = cell.contentView
        let rotationAngleDegrees = -30
        let rotationAngleRadians = Double(rotationAngleDegrees) * (Double.pi/180)
        let offsetPositioning = CGPoint(x: 500, y: -20.0)
        var transform = CATransform3DIdentity
        transform = CATransform3DRotate(transform, CGFloat(rotationAngleRadians), -50.0, 0.0, 1.0)
        transform = CATransform3DTranslate(transform, offsetPositioning.x, offsetPositioning.y, -50.0)
        cellContentView.layer.transform = transform
        cellContentView.layer.opacity = 0.8
        
        UIView.animate(withDuration: 0.65, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.8, options: [], animations: {
            cellContentView.layer.transform = CATransform3DIdentity;
            cellContentView.layer.opacity = 1;
        }, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {        
        if segue.identifier == "showEmployee" {
            if let indexPath = selectedMemberIndexPath {
                let vc = segue.destination as! EmployeeDetailsViewController
                let member: Member

                if isFiltering() {
                    member = filteredMembers[indexPath.row]
                } else {
                    member = members[indexPath.row]
                }

                vc.memberId = member.id
            }
        } else if segue.identifier == "showAddNote" {
            if let indexPath = selectedMemberIndexPath {
                let vc = segue.destination as! AddNoteViewController
                let member: Member

                if isFiltering() {
                    member = filteredMembers[indexPath.row]
                } else {
                    member = members[indexPath.row]
                }

                vc.member = member
                vc.backTo = "Dashboard"
            }
        }
    }
    
    // Mark: Migration
    
    //    private func testData(id: String) {
    //        CoreDataManager.shared.insertEmployee(name: "Domonique", userID: id) { (error) in
    //            if error != nil {
    //                print(error?.localizedDescription)
    //            } else {
    //                print("Saved")
    //            }
    //        }
    //
    //        let employees = CoreDataManager.shared.getEmployees(predicates: nil, sortedBy: nil) { (error) in
    //            if error != nil {
    //                print(error?.localizedDescription)
    //            }
    //        }
    //
    //        CoreDataManager.shared.insertNote(text: "Beginning", created: Date(), employee: (employees?[0])!) { (error) in
    //            if error != nil {
    //                print(error?.localizedDescription)
    //            }
    //        }
    //    }
        
        private func migration(id: String) {
            SVProgressHUD.show()
            let employees = CoreDataManager.shared.getEmployees(predicates: nil, sortedBy: nil) { (error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
            }
                    
            var members = [Member]()
            
            if let employees = employees {
                for employee in employees {
                    if let notes = employee.notes?.array {
                        var comments = [Comment]()
                        for note in notes as! [Note] {
                            comments.append(Comment(date: note.created!, comment: note.text!, timestamp: Timestamp(date: note.created!).seconds))
                        }
                        
                        members.append(Member(id: id, fullName: employee.fullName!, latest: nil, comments: comments))
                    }
                    
                    members.append(Member(id: id, fullName: employee.fullName!, latest: nil, comments: []))
                }
                
                if employees.count > 0 {
                    // Move Settings over to new database
                    let date = UserDefaults.timeManagedReminder
                    let calendar = Calendar.current
                    let objectToSave = [
                        "First_Name": UserDefaults.userFirstName,
                        "Last_Name": UserDefaults.userLastName,
                        "Email": UserDefaults.userEmail,
                        "Phone": UserDefaults.userPhone,
                        "Company": UserDefaults.userCompany,
                        "Number_of_People": UserDefaults.userAmount,
//                        "New": false,
                        "UserId": UserDefaults.userUID,
                        "isOrderAscending": UserDefaults.sortOrder,
                        "headerName": UserDefaults.mainTitle,
                        "storeDays": UserDefaults.storeDays,
                        "reminderStartDay": UserDefaults.reminderStartDays,
                        "isReminder": UserDefaults.useTimeManagedReminder,
                        "reminderHours": calendar.component(.hour, from: date!),
                        "reminderMinutes": calendar.component(.minute, from: date!)
                    ] as [String : Any]
                    
                    FirebaseManager.shared.updateSettings(uid: UserDefaults.userUID, data: objectToSave) { (error) in
                        if error != nil {
                            print(error?.localizedDescription)
                        }
                    }
                }
            }
            
            for member in members {
                var notes = [[String: Any]]()
                
                for note in member.comments {
                    notes.append(note.print())
                }
                
                FirebaseManager.shared.addEmployee(uid: id, fullName: member.fullName, notes: notes) { (id, error) in
                    if error != nil {
                        print(error?.localizedDescription)
                    } else {
                        FirebaseManager.shared.getEmployees(uid: id) { (results, error) in
                            if error != nil {
                                print(error?.localizedDescription)
                            } else {
                                if UserDefaults.storeDays < 101 {
                                    Utility.deleteAllOldNotes(members: results.members) { (error) in
                                        if error != nil {
                                            print(error?.localizedDescription)
                                        } else {
                                            CoreDataManager.shared.deleteAllEmployees(predicate: nil) { (error) in
                                                if error != nil {
                                                    print(error?.localizedDescription)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            SVProgressHUD.dismiss()
        }
}

extension EmployeesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
