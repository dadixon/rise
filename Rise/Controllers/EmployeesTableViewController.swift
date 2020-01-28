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
    
    var employees = [Employee]()
    var filteredEmployees = [Employee]()
    let searchController = UISearchController(searchResultsController: nil)
    var deleteEmployeeIndexPath: IndexPath? = nil
    var selectedEmployeeIndexPath: IndexPath? = nil
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = true
        self.tableView.tableFooterView = UIView()

        setup()
        setupNavigation()
        
        if let employees = setEmployees() {
            self.employees = employees
            tableView.reloadData()
            resetTable(employees: employees)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Auth.auth().addStateDidChangeListener({ (auth, user) in
            guard let user = user else {
                self.performSegue(withIdentifier: "viewLogin", sender: nil)
                return
            }
            
            guard !UserDefaults.userUID.isEmpty else {
                self.performSegue(withIdentifier: "viewLogin", sender: nil)
                return
            }
            
            self.user = user
        })
        
        if let employees = setEmployees() {
            self.employees = employees
            tableView.reloadData()
            resetTable(employees: employees)
        }
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
    
    private func setEmployees() -> [Employee]? {
        let noNotePredicate = NSPredicate(format: "latest == nil AND userId == %@", UserDefaults.userUID)
        var mainPredicate = NSCompoundPredicate(type: .or, subpredicates: [noNotePredicate])
        
        if UserDefaults.storeDays < 101 {
            var calendar = Calendar.current
            calendar.timeZone = NSTimeZone.local
            let dateFrom = calendar.startOfDay(for: Date())
            let dateTo = calendar.date(byAdding: .day, value: -UserDefaults.storeDays, to: dateFrom)
            let storeDaysPredicate = NSPredicate(format: "latest >= %@ AND userId == %@", dateTo! as NSDate, UserDefaults.userUID)
            
            mainPredicate = NSCompoundPredicate(type: .or, subpredicates: [noNotePredicate, storeDaysPredicate])
        } else {
            let allUserEmployeesPredicate = NSPredicate(format: "userId == %@", UserDefaults.userUID)
            
            mainPredicate = NSCompoundPredicate(type: .or, subpredicates: [allUserEmployeesPredicate])
        }
        
        let sortDescriptor = NSSortDescriptor(key: "latest", ascending: UserDefaults.sortOrder)
        
        return CoreDataManager.shared.getEmployees(predicates: mainPredicate, sortedBy: [sortDescriptor], completion: { (error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: "Error fetching Employees")
            }
        })
    }
    
    private func resetTable(employees: [Employee]) {
        if employees.count == 0 {
            tableView.backgroundView = BackgroundView()
        } else {
            tableView.backgroundView = nil
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredEmployees = employees.filter({( employee : Employee) -> Bool in
            guard let fullName = employee.fullName else {
                return false
            }
            return (fullName.lowercased().contains(searchText.lowercased()))
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    @IBAction func unwindToEmployeesDashboard(segue:UIStoryboardSegue) {
        if let employees = setEmployees() {
            self.employees = employees
            tableView.reloadData()
            resetTable(employees: employees)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredEmployees.count
        }
        return employees.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell", for: indexPath) as! EmployeeTableViewCell
        let employee: Employee?
        
        if isFiltering() {
            employee = filteredEmployees[indexPath.row]
        } else {
            employee = employees[indexPath.row]
        }
        
        guard (employee?.fullName) != nil else {
            return cell
        }
        
        cell.nameLabel.text = employee?.fullName
        
        if let noteCount = employee?.notes?.count {
            cell.noteCountLabel.text = "\(noteCount) " + Utility.formatPlural(count: noteCount, object: "Note")
        }
        
        if let latest = employee?.latest {
            cell.createdLabel.text = Utility.textFormat(from: latest)
            cell.backgroundColor = Utility.cellColor(from: latest)
        } else {
            cell.createdLabel.text = ""
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        deleteEmployeeIndexPath = indexPath
        
        let deleteAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "Delete", handler: { (action, view, completionHandler) in
            
            let alert = UIAlertController(title: "Delete Employee?", message: "Delete Employee", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(_) in
                if let indexPath = self.deleteEmployeeIndexPath {
                    tableView.beginUpdates()
                    
                    var tableData = [Employee]()
                    
                    if self.isFiltering() {
                        tableData = self.filteredEmployees
//                        CoreDataManager.shared.deleteEmployee(employee: self.filteredEmployees[indexPath.row]) { (error) in
//                            if error != nil {
//                                SVProgressHUD.showError(withStatus: "Could not delete employee")
//                            } else {
//                                self.employees.removeAll { (employee) -> Bool in
//                                    employee == self.filteredEmployees[indexPath.row]
//                                }
//                                self.filteredEmployees.remove(at: indexPath.row)
//                                SVProgressHUD.showSuccess(withStatus: "Employee has been deleted")
//                            }
//                        }
                    } else {
                        tableData = self.employees
//                        CoreDataManager.shared.deleteEmployee(employee: self.employees[indexPath.row]) { (error) in
//                            if error != nil {
//                                SVProgressHUD.showError(withStatus: "Could not delete employee")
//                            } else {
//                                self.employees.remove(at: indexPath.row)
//                                SVProgressHUD.showSuccess(withStatus: "Employee has been deleted")
//                            }
//                        }
                    }
                    
                    CoreDataManager.shared.deleteEmployee(employee: tableData[indexPath.row]) { (error) in
                        if error != nil {
                            SVProgressHUD.showError(withStatus: "Could not delete employee")
                        } else {
                            self.employees.removeAll { (employee) -> Bool in
                                employee == tableData[indexPath.row]
                            }
                            self.filteredEmployees.removeAll { (employee) -> Bool in
                                employee == tableData[indexPath.row]
                            }
//                            self.filteredEmployees.remove(at: indexPath.row)
                            SVProgressHUD.showSuccess(withStatus: "Employee has been deleted")
                        }
                    }
                    
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.deleteEmployeeIndexPath = nil
                    self.resetTable(employees: tableData)
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        selectedEmployeeIndexPath = indexPath
        
        let viewAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "View", handler: { (action, view, completionHandler) in
            
            self.performSegue(withIdentifier: "showEmployee", sender: self)
            
            completionHandler(true)
        })
        
        viewAction.backgroundColor = Design.Color.Secondary.darkGrey
        
        let config = UISwipeActionsConfiguration(actions: [viewAction])
        
        return config
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedEmployeeIndexPath = indexPath
        
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
            if let indexPath = selectedEmployeeIndexPath {
                let vc = segue.destination as! EmployeeDetailsViewController
                let employee: Employee
                
                if isFiltering() {
                    employee = filteredEmployees[indexPath.row]
                } else {
                    employee = employees[indexPath.row]
                }
                
                vc.employee = employee
            }
        } else if segue.identifier == "showAddNote" {
            if let indexPath = selectedEmployeeIndexPath {
                let vc = segue.destination as! AddNoteViewController
                let employee: Employee
                
                if isFiltering() {
                    employee = filteredEmployees[indexPath.row]
                } else {
                    employee = employees[indexPath.row]
                }
                
                vc.employee = employee
                vc.backTo = "Dashboard"
            }
        }
    }
}

extension EmployeesTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
