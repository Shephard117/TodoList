//
//  CategoryViewController.swift
//  TodoList
//
//  Created by Дмитрий Скоробогаты on 30.08.2021.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController{
    
    let realm = try! Realm()
    var categories: Results<Category>?

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        loadCategory()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        guard let navBar = navigationController?.navigationBar else {fatalError("Navigtion controller does'n exist")}
        navBar.backgroundColor = UIColor(hexString: "D4C4FB")
        searchBar.barTintColor = UIColor(hexString: "D4C4FB")
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = categories?[indexPath.row].name ?? "No categpries yet"
        guard let color = UIColor(hexString: (categories![indexPath.row].cellColor!)) else {fatalError()}
        cell.backgroundColor = color
        cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
        return cell
    }
    
    //MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "GoToItems", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categories?[indexPath.row]
        }
    }
    
    //MARK: - Data manipulation methods
    
    func loadCategory() {
        categories = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    func save(_ category: Category) {
        
        do {
            try realm.write {
                realm.add(category)
            }
        } catch {
            print("Error: \(error.localizedDescription)")
        }
        
    }
    
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row]{
            do{
                try self.realm.write {
                    self.realm.delete(category)
                }
            }catch {
                print("Error deleting category: \(error.localizedDescription)")
            }
        }
    }

    //MARK: - Add button function
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add new category", message: nil, preferredStyle: .alert)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "New category"
            textField = alertTextField
        }
        alert.addAction(UIAlertAction(title: "Add category", style: .default, handler: { _ in
            if textField.text != "" {
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.cellColor = UIColor.randomFlat().hexValue()
                self.save(newCategory)
                self.tableView.reloadData()
            }
        }
        ))
        self.present(alert, animated: true, completion: nil)
        
    }
    
}

//MARK: - SearchBar Delegate section

extension CategoryViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        categories = categories?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text?.count == 0 {
            loadCategory()
            DispatchQueue.main.async {
                self.searchBar.resignFirstResponder()
            }
        }
        
    }
}


