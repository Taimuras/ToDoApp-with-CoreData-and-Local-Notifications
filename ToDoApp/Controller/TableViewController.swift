
import UIKit
import CoreData
import UserNotifications

class TableViewController: UIViewController, UITabBarControllerDelegate{
    
    var itemArray = ToDoList()
    var searchController: UISearchController!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let center = UNUserNotificationCenter.current()
    //Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var itemTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        // Notification Center
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (grabted, error) in
            
        }
        
        // Core Data Loading Items
        loadItems()
        
        //Delegates
        itemTableView.delegate = self
        itemTableView.dataSource = self
        //Taking off the separetors and vertical indicator
        itemTableView.separatorStyle = .none
        itemTableView.showsVerticalScrollIndicator = false
        
        searchBar.delegate = self
        
        // this methods for not showing second item in tabbar
        self.tabBarController?.delegate = self
    }
    
    //MARK: ADDING ITEM
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if tabBarController.selectedIndex == 1{
            tabBarController.selectedIndex = 0
            
            // Adding TextFields into Alert Dialog
            var textField = UITextField()
            var textField2 = UITextField()
            let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
            
            
            // Custom Height of Alert Dialog window
            let height:NSLayoutConstraint = NSLayoutConstraint(item: alert.view!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 250)
            alert.view.addConstraint(height)
            
            // Adding Date Picker to an alert Dialog and possitioned
            let myDatePicker: UIDatePicker = UIDatePicker()
            myDatePicker.timeZone = .current
            myDatePicker.frame = CGRect(x: 20, y: 150, width: 280, height: 50)
            alert.view.addSubview(myDatePicker)
            
            let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
                // what will happen once when the user will click ADD Button UIALERT
                
                
                let newItem = Item(context: self.context)
                newItem.title = textField.text!
                newItem.titleDescription = textField2.text!
                newItem.done = false
                self.itemArray.todos.append(newItem)
                
                for i in 0 ..< self.itemArray.todos.count{
                    self.itemArray.todos[i].itemIndex = Int32(i)
                }
                
                
                // Notification Set
                let content = UNMutableNotificationContent()
                content.title = newItem.title!
                content.body = newItem.titleDescription!
                content.sound = UNNotificationSound.default
                
                
                let date = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: myDatePicker.date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: false)
                
                let uuidString = UUID().uuidString
                let notificationRequest = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
                self.center.add(notificationRequest) { (error) in
                    
                }
                
                self.saveItems()
                
                
            }
            alert.message = "Add title and description"
            alert.addTextField { (alertTextField) in
                alertTextField.placeholder = "Create New Item"
                textField = alertTextField
            }
            
            alert.addTextField { (alertTextField2) in
                alertTextField2.placeholder = "Type Details"
                textField2 = alertTextField2
            }
            
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    func saveItems(){
        do {
            try context.save()
        } catch  {
            print("Error saving context \(error)")
        }
        self.itemTableView.reloadData()
    }
    
    func loadItems() {
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        do {
            itemArray.todos = try context.fetch(request)
        } catch  {
            print("Error with loading context \(error)")
        }
        
    }
    
    // Segue Preparation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ItemToEdit" {
            if let addItemViewController = segue.destination as? ItemDetailViewController {
                if let cell = sender as? UITableViewCell, let indexPath = itemTableView.indexPath(for: cell) {
                    
                    let item: Item
                    if searchBar.text == "" {
                        item = itemArray.todos[indexPath.row]
                        
                    } else {
                        item = itemArray.filteredItems[indexPath.row]
                        
                    }
                    addItemViewController.itemToEdit = item
                    addItemViewController.delegate = self
                    
                }
            }
        }
        
    }
}

// MARK: Custom Table View
// This extension is used for making custom table view with custom table Cell
extension TableViewController: UITableViewDelegate, UITableViewDataSource{
    
    // height of cell
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 60
    //    }
    // number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchBar.text == "" {
            return itemArray.todos.count
        } else {
            return itemArray.filteredItems.count
        }
    }
    // Cell as it's like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTVC
        if searchBar.text == "" {
            let indexPaths = itemArray.todos[indexPath.row]
            cell.titleLabel.text = indexPaths.title
            cell.descriptionLabel.text = indexPaths.titleDescription
            if indexPaths.done {
                cell.itemImageView.image = UIImage(named: "Done")
            } else {
                cell.itemImageView.image = UIImage(named: "NotDone")
            }
        } else {
            let indexPaths = itemArray.filteredItems[indexPath.row]
            cell.titleLabel.text = indexPaths.title
            cell.descriptionLabel.text = indexPaths.titleDescription
            if indexPaths.done {
                cell.itemImageView.image = UIImage(named: "Done")
            } else {
                cell.itemImageView.image = UIImage(named: "NotDone")
            }
            
        }
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.systemGray5
        } else {
            cell.backgroundColor = UIColor.systemGray6
            cell.alpha = 0.6
        }
        cell.layer.cornerRadius = cell.frame.height / 2
        
        return cell
    }
    
    // taping cells ( in this way just adding animation of taping on a cell )
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchBar.text == "" {
            itemArray.todos[indexPath.row].done = !itemArray.todos[indexPath.row].done
        } else {
            for i in itemArray.todos {
                let item = itemArray.filteredItems[indexPath.row]
                if i.itemIndex == item.itemIndex {
                    i.done = !i.done
                }
            }
        }
        
        saveItems()
        
        itemTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    //Deleting Items
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if searchBar.text == "" {
            
            context.delete(itemArray.todos[indexPath.row])
            itemArray.todos.remove(at: indexPath.row)
            
            for i in 0 ..< self.itemArray.todos.count{
                self.itemArray.todos[i].itemIndex = Int32(i)
            }
        } else {
            let deleteItemIndex = Int(itemArray.filteredItems[indexPath.row].itemIndex)
            context.delete(itemArray.todos[deleteItemIndex])
            itemArray.todos.remove(at: deleteItemIndex)
            
            for i in 0 ..< self.itemArray.todos.count{
                self.itemArray.todos[i].itemIndex = Int32(i)
            }
            itemArray.filteredItems.remove(at: indexPath.row)
        }
        
        saveItems()
        
    }
}

// MARK: Editing Items
extension TableViewController: ItemDetailViewControllerDelegate{
    
    func addItemViewControllerDidCancel(_ controller: ItemDetailViewController) {
        dismiss(animated: true, completion: itemTableView.reloadData)
    }
    
    func addItemViewController(_ controller: ItemDetailViewController, didFinishEditing item: Item) {
        if searchBar.text == "" {
            
            itemArray.todos[Int(item.itemIndex)] = item
        } else {
            itemArray.todos[Int(item.itemIndex)] = item
            for i in 0 ..< itemArray.filteredItems.count{
                if itemArray.filteredItems[i].itemIndex == item.itemIndex {
                    itemArray.filteredItems[i] = item
                }
            }
        }
        
        saveItems()
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: Search Bar Delegate
extension TableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        itemArray.filteredItems = itemArray.todos
        itemArray.filteredItems = []
        if searchText == "" {
            itemArray.filteredItems.removeAll()
        } else {
            for item in itemArray.todos {
                if item.title!.lowercased().contains(searchText.lowercased()){
                    itemArray.filteredItems.append(item)
                }
            }
            
        }
        itemTableView.reloadData()
    }
}
extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


