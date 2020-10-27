//
//  ViewController.swift
//  ToDoApp
//
//  Created by tami on 10/21/20.
//

import UIKit

class TableViewController: UIViewController, UITabBarControllerDelegate{
    
    var itemArray = ToDoList()
    var searchController: UISearchController!
    
    @IBOutlet weak var searchBar: UISearchBar!
    //Outlets
    @IBOutlet weak var itemTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // setupSearchController()
        if let items = itemArray.defaults.array(forKey: "ToDoList") as? [String]{
            itemArray.todos = itemArray.gettingData(array: items)
            
        }
        //Delegates
        itemTableView.delegate = self
        itemTableView.dataSource = self
        //Taking off the separetors and vertical indicator
        itemTableView.separatorStyle = .none
        itemTableView.showsVerticalScrollIndicator = false
        
        searchBar.delegate = self
        
    }
    
    // this methods for not showing second item in tabbar
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.delegate = self
        
    }
    
    
    
    //MARK: ADDING ITEM
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if tabBarController.selectedIndex == 1{
            tabBarController.selectedIndex = 0
            var textField = UITextField()
            var textField2 = UITextField()
            let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
            let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
                // what will happen once when the user will click ADD Button UIALERT
                var newItem = Item()
                newItem.title = textField.text!
                newItem.description = textField2.text!
                self.itemArray.todos.append(newItem)
                self.itemTableView.reloadData()
                self.itemArray.update()
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
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
            cell.descriptionLabel.text = indexPaths.description
            if indexPaths.done {
                cell.itemImageView.image = UIImage(named: "Done")
            } else {
                cell.itemImageView.image = UIImage(named: "NotDone")
            }
        } else {
            let indexPaths = itemArray.filteredItems[indexPath.row]
            cell.titleLabel.text = indexPaths.title
            cell.descriptionLabel.text = indexPaths.description
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
            itemArray.todos[indexPath.row].checked()
        } else {
            let item = itemArray.filteredItems[indexPath.row]
            let index = itemArray.todos.firstIndex(of: item)!
            itemArray.todos[index].checked()
            itemArray.filteredItems[indexPath.row].checked()
        }
        
        
        
        itemTableView.reloadData()
        itemArray.update()
        itemTableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    //Deleting Items
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if searchBar.text == "" {
            itemArray.todos.remove(at: indexPath.row)
            itemArray.update()
            
        } else {
            
            let item = itemArray.filteredItems[indexPath.row]
            let index = itemArray.todos.firstIndex(of: item)!
            itemArray.filteredItems.remove(at: indexPath.row)
            itemArray.todos.remove(at: index)
            
            itemArray.update()
            
        }
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
    }
    
    
    
    
}

// MARK: Editing Items
extension TableViewController: ItemDetailViewControllerDelegate{
    func addItemViewControllerDidCancel(_ controller: ItemDetailViewController) {
        dismiss(animated: true, completion: itemTableView.reloadData)
    }
    
    func addItemViewController(_ controller: ItemDetailViewController, didFinishEditing item: Item) {
        if searchBar.text == "" {
            var index: Int = 0
            
            for i in 0 ..< itemArray.todos.count {
                if itemArray.todos[i].title == item.title {
                    index = i
                }
            }
            itemArray.todos[index] = item
        } else {
            var filteredIndex: Int = 0
            for i in 0 ..< itemArray.filteredItems.count {
                if itemArray.filteredItems[i].title == item.title {
                    filteredIndex = i
                }
            }
            itemArray.filteredItems[filteredIndex] = item
        }
        itemTableView.reloadData()
        itemArray.update()
        
        dismiss(animated: true, completion: nil)
        
    }
    
    
}


extension TableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        itemArray.filteredItems = itemArray.todos
        itemArray.filteredItems = []
        if searchText == "" {
            itemArray.filteredItems.removeAll()
        } else {
            for item in itemArray.todos {
                if item.title.lowercased().contains(searchText.lowercased()){
                    
                    itemArray.filteredItems.append(item)
                }
            }
            
        }
        itemTableView.reloadData()
    }
    
    
}



