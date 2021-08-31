//
//  TodoListViewController.swift
//  TodoList
//
//  Created by Дмитрий Скоробогаты on 30.08.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    let realm = try! Realm()
    var items: Results<Item>?
    var selectedCategory: Category? {
        didSet {
            loadData()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let hexColor = selectedCategory?.cellColor{
            guard let navBar = navigationController?.navigationBar else {fatalError("Navigtion controller does'n exist")}
            navBar.backgroundColor = UIColor.init(hexString: hexColor)
            title = selectedCategory!.name
        }
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let item = items?[indexPath.row]{
            cell.textLabel?.text = item.title
            cell.backgroundColor = UIColor.init(hexString: selectedCategory!.cellColor!)?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(items!.count))
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            cell.accessoryType = item.done ? .checkmark : .none //ternary operator
        } else {
            cell.textLabel?.text = "Not items yet"
        }
        return cell
        
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = items?[indexPath.row]{
            do {
                try realm.write{
                    item.done = !item.done
                }
            } catch {
                print("Updating error: \(error.localizedDescription)")
            }
        }
        tableView.reloadData()
    }
    
    //MARK: - Model manipulation methods
    
    func loadData(){ //provide default parametr
            
        items = selectedCategory?.items.sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let item = items?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(item)
                }
                
            } catch {
                print("Error deleting item: \(error.localizedDescription)")
            }
        }
    }

    //MARK: - Add button function
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new task.", message: "", preferredStyle: .alert)
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create task"
            textField = alertTextField
        }
        
        alert.addAction(UIAlertAction(title: "Add task.", style: .default, handler: { _ in
            if textField.text != ""{
                
                if let currentCategory = self.selectedCategory {
                    do {
                        try self.realm.write {
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            currentCategory.items.append(newItem)
                        }
                    } catch {
                        print("Error occure trying saving context: \(error.localizedDescription)")
                    }
                }
                self.tableView.reloadData()
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - SearchBar Delegate section

extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        items = items?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadData()
            DispatchQueue.main.async {
                self.searchBar.resignFirstResponder()
            }
        }
        
    }
}
