//
//  ViewController.swift
//  Todoey
//
//  Created by Philipp Muellauer on 02/12/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
     
     var itemArray = [Item]()
     
     var selectedCategory: Category? {
          didSet{
               loadData()
          }
     }
     let defaults = UserDefaults.standard
     //let dataFilePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("Items.plist")
     @IBOutlet weak var searchTextBar: UISearchBar!
     let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
     override func viewDidLoad() {
          super.viewDidLoad()
          searchTextBar.delegate = self
          loadData()
          if let items = defaults.array(forKey: "TodoListItem") as? [Item] {
               itemArray = items
          }
          print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!)
          // Do any additional setup after loading the view.
     }
     
     //MARK: - Tableview datasource methods
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return itemArray.count
     }
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListItem", for: indexPath)
          cell.textLabel?.text = itemArray[indexPath.row].title
          cell.accessoryType = itemArray[indexPath.row].done ? .checkmark : .none
          return cell
     }
     
     //MARK: - Tableview Delegate methods
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          tableView.deselectRow(at: indexPath, animated: true)
          itemArray[indexPath.row].done = !itemArray[indexPath.row].done
          self.saveDataToFile()
          tableView.reloadData()
          //        if cellSelected?.accessoryType == UITableViewCell.AccessoryType.none {
          //            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
          //        } else {
          //            tableView.cellForRow(at: indexPath)?.accessoryType = .none
          //        }
          
     }
     //MARK: - Add New Item
     @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
          let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
          var textField = UITextField()
          let action = UIAlertAction(title: "Add Item", style: .default) { action in
               //What will happen when user presses Add button on alert
               if let safeText = textField.text {
                    //let item = Item(safeText, false)
                    
                    let item = Item(context: self.context)
                    item.title = safeText
                    item.done = false
                    item.parentCategory = self.selectedCategory
                    self.itemArray.append(item)
                    //self.defaults.set(self.itemArray, forKey: "TodoeyListArray")
                    self.saveDataToFile()
                    self.tableView.reloadData()
               }
          }
          alert.addAction(action)
          alert.addTextField { alertTextField in
               alertTextField.placeholder = "Create new item"
               textField = alertTextField
          }
          present(alert, animated: true, completion: nil)
     }
     func saveDataToFile() {
          do {
               try context.save()
          }catch {
               print(error)
          }
     }
     func loadData(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil) {
          var categoryPredicate:NSPredicate
          if let categorySelected = selectedCategory {
               let name = categorySelected.name!
               categoryPredicate = NSPredicate(format: "parentCategory.name CONTAINS %@", name)
               request.predicate = categoryPredicate
               if let safePredicate = predicate {
                    let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [safePredicate, categoryPredicate])
                    request.predicate = compoundPredicate
               }
          }
          
          do {
               itemArray = try context.fetch(request)
          } catch {
               print("Error fetching data \(error)")
          }
          tableView.reloadData()
     }
}
//MARK: - Search Bar Methods
extension TodoListViewController: UISearchBarDelegate {
     func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
          let request : NSFetchRequest<Item> = Item.fetchRequest()
          let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
          
          request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
          loadData(with: request, predicate: predicate)
     }
     func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
          if searchBar.text?.count == 0 {
               loadData()
               DispatchQueue.main.async {
                    //Tell searchbar to not have focus
                    searchBar.resignFirstResponder()
               }
          }
     }
}

