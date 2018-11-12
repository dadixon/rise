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
import ChameleonFramework

class EmployeesTableViewController: UITableViewController {

    @IBOutlet weak var addEmployeeBtn: UIBarButtonItem!
    @IBOutlet weak var settingsBtn: UIBarButtonItem!
    
    let userDefaults = UserDefaults.standard
    
    var employees = [Employee]()
    var filteredEmployees = [Employee]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let searchController = UISearchController(searchResultsController: nil)
    var deleteEmployeeIndexPath: IndexPath? = nil
    var selectedEmployeeIndexPath: IndexPath? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = true
        self.tableView.tableFooterView = UIView()

        setup()
        setupNavigation()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = UserDefaults.mainTitle
        
        employees = getEmployees()
        self.tableView.reloadData()
    }
    
    private func setup() {
        SVProgressHUD.setDefaultStyle(.dark)
        SVProgressHUD.setMinimumDismissTimeInterval(3.0)
    }
    
    private func setupNavigation() {
        settingsBtn.title = "Settings"
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func getEmployees() -> [Employee] {
        var rv = [Employee]()
        var calendar = Calendar.current
        
        calendar.timeZone = NSTimeZone.local
        
        let dateFrom = calendar.startOfDay(for: Date())
        let dateTo = calendar.date(byAdding: .day, value: -UserDefaults.storeDays, to: dateFrom)
        let noNotePredicate = NSPredicate(format: "latest == nil")
        let storeDaysPredicate = NSPredicate(format: "latest >= %@", dateTo! as NSDate)
        let datePredicate = NSCompoundPredicate(type: .or, subpredicates: [noNotePredicate, storeDaysPredicate])
        let sortDescriptor = NSSortDescriptor(key: "latest", ascending: UserDefaults.sortOrder)
        let request: NSFetchRequest<Employee> = Employee.fetchRequest()
        
        request.predicate = datePredicate
        request.sortDescriptors = [sortDescriptor]
        
        do {
            rv = try context.fetch(request)
        } catch {
            print("Error fetching data from context \(error)")
        }
        
        return sortNoDateFirst(employees: rv)
    }
    
    func sortNoDateFirst(employees: [Employee]) -> [Employee] {
        var temp = employees
        
        temp = temp.filter { $0.latest != nil }
        
        for employee in employees {
            if employee.latest == nil {
                temp.insert(employee, at: 0)
            }
        }
        
        return temp
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredEmployees = employees.filter({( employee : Employee) -> Bool in
            return (employee.fullName?.lowercased().contains(searchText.lowercased()))!
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
//    private func deleteEmployeeHandler(alertAction: UIAlertAction!) -> Void {
//        if let indexPath = deleteEmployeeIndexPath {
//            tableView.beginUpdates()
//
//            if isFiltering() {
//                deleteEmployee(employee: filteredEmployees[indexPath.row])
//                filteredEmployees.remove(at: indexPath.row)
//            } else {
//                deleteEmployee(employee: employees[indexPath.row])
//                employees.remove(at: indexPath.row)
//            }
//
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            deleteEmployeeIndexPath = nil
//            tableView.endUpdates()
//        }
//    }
    
    func deleteEmployee(employee: Employee) {
        context.delete(employee)
        
        do {
            try context.save()
        } catch {
            SVProgressHUD.showSuccess(withStatus: "Employee has been deleted")
        }
    }
    
    @IBAction func unwindToEmployeesDashboard(segue:UIStoryboardSegue) { }
    
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
        let employee: Employee
        
        if isFiltering() {
            employee = filteredEmployees[indexPath.row]
        } else {
            employee = employees[indexPath.row]
        }
        
        cell.nameLabel.text = employee.fullName!
        
        if let noteCount = employee.notes?.count {
            cell.noteCountLabel.text = "\(noteCount) " + Utility.formatPlural(count: noteCount, object: "Note")
        }
        
        if let latest = employee.latest {
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
                    
                        if self.isFiltering() {
                            self.deleteEmployee(employee: self.filteredEmployees[indexPath.row])
                            self.filteredEmployees.remove(at: indexPath.row)
                    } else {
                            self.deleteEmployee(employee: self.employees[indexPath.row])
                            self.employees.remove(at: indexPath.row)
                    }
                    
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        selectedEmployeeIndexPath = indexPath
        
        let viewAction = UIContextualAction.init(style: UIContextualAction.Style.normal, title: "View", handler: { (action, view, completionHandler) in
            
            self.performSegue(withIdentifier: "showEmployee", sender: self)
            
            completionHandler(true)
        })
        
        viewAction.backgroundColor = HexColor("6F6F6F")
        
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
       // navigationItem.title = nil
        
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
