//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Pushparaj Samant on 25/3/22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController {
    var categoryItemArray = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    //MARK: - Add Button
    @IBAction func addCategoryButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        var textField = UITextField()
        let action = UIAlertAction(title: "Add", style: .default) { action in
            if let safeText = textField.text {
                let newCategory = Category(context: self.context)
                newCategory.name = safeText
                self.categoryItemArray.append(newCategory)
                self.saveData()
            }
        }
        alert.addAction(action)
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "Create New Category"
            textField = alertTextField
        }
        present(alert, animated: true)
    }
    //MARK: - Tableview delegate
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      performSegue(withIdentifier: "goToItems", sender: self)
   }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory = categoryItemArray[indexPath.row]
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryItemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = categoryItemArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryItem", for: indexPath)
        cell.textLabel?.text = item.name
        return cell
    }
    //MARK: - Coredata functions
    func saveData() {
        do {
            try context.save()
        } catch {
            print("Error saving data")
        }
        self.tableView.reloadData()
    }
    func loadData(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categoryItemArray = try context.fetch(request)
        } catch {
            print("Error loading data \(error)")
        }
    }
}
