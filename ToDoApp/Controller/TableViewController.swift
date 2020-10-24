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
       
    }
    // Updating UserDefaults just Once here
    override func viewDidDisappear(_ animated: Bool) {
        itemArray.update()
    }
    // this methods for not showing second item in tabbar
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.delegate = self
    }
   //MARK: Search Bar
//    func setupSearchController() {
//        searchController = UISearchController(searchResultsController: nil)
//        searchController.searchResultsUpdater = self
//
//        searchController.delegate = self
//        searchController.searchBar.delegate = self
//
//        searchController.obscuresBackgroundDuringPresentation = false
//        searchController.searchBar.placeholder = "Search"
//
//        searchController.hidesNavigationBarDuringPresentation = false
//
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
//        definesPresentationContext = true
//
//        let searchBar = searchController.searchBar
//        searchBar.searchBarStyle = .prominent
//
//
//    }
   
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
                    
                    let item = itemArray.todos[indexPath.row]
                    addItemViewController.itemToEdit = item
                    addItemViewController.delegate = self
                }
            }
        }

    }
}


//MARK: Search Bar
//extension TableViewController: UISearchBarDelegate, UISearchControllerDelegate{
//
//}
//
//extension TableViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        self.itemArray.filteredItems.removeAll()
//
//        let whiteSpacesCharacterSet = CharacterSet.whitespaces
//        let stripedString = searchController.searchBar.text!.trimmingCharacters(in: whiteSpacesCharacterSet).lowercased()
//        self.itemArray.filteredItems = itemArray.todos.filter({ (title) -> Bool in
//            if itemArray.todos.contains(stripedString) {
//
//            }
//        })
//    }
//}


// MARK: Custom Table View
// This extension is used for making custom table view with custom table Cell
extension TableViewController: UITableViewDelegate, UITableViewDataSource{
    
    // height of cell
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    // number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.todos.count
    }
    // Cell as it's like
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = itemTableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTVC
        let indexPaths = itemArray.todos[indexPath.row]
        cell.titleLabel.text = indexPaths.title
        cell.descriptionLabel.text = indexPaths.description
        if indexPaths.done {
            cell.itemImageView.image = UIImage(named: "Done")
        } else {
            cell.itemImageView.image = UIImage(named: "NotDone")
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
        
        itemArray.todos[indexPath.row].checked()
        
        itemTableView.reloadData()
        itemTableView.deselectRow(at: indexPath, animated: true)
        
    }
  
    //Deleting Items
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        itemArray.todos.remove(at: indexPath.row)
        
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
        
        var index: Int = 0
        
        for i in 0 ..< itemArray.todos.count {
            if itemArray.todos[i].title == item.title {
                index = i
            }
        }
        
        itemArray.todos[index] = item
        if itemArray.todos[index].done {
            itemArray.todos[index].checked()
        }
        
        itemTableView.reloadData()

        dismiss(animated: true, completion: nil)
 
    }


}


