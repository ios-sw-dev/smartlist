//
//  HomeViewController.swift
//  Smart List
//
//  Created by Haamed Sultani on Jan/1/19.
//  Copyright © 2019 Haamed Sultani. All rights reserved.
//


import UIKit
import CoreData

class HomeViewController: UITableViewController {
    
    /****************************************/
    /****************************************/
    //MARK: - Variables
    /****************************************/
    /****************************************/
    // Core Data Manager (Singleton)
    let coreDataManager = CoreDataManager.shared
    
    //MARK: - Constants
    let homeCellId: String = "homeCell"
    
    //MARK: - Variables
    var categories: [Category] = []
    var items: [[Item]] = [[],[],[],[],[],[],[]]
    
    
    
    
    /****************************************/
    /****************************************/
    //MARK: - View Methods
    /****************************************/
    /****************************************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register our cell to the tableview
        self.tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: homeCellId)
        

        // Initialization
        setupView() // Set up the view
        setupModels() // Set up the models
        
//        add(itemName: "", toCategory: categories[6])
        //deleteItem(itemName: "my new item 4")

        tableView.reloadData()
    }
    
    
    
    
    /****************************************/
    /****************************************/
    //MARK: - My Methods
    /****************************************/
    /****************************************/
    
    // Purpose: Sets up all the view elements of the list page
    // Called in viewDidLoad
    
    /// Sets all visual settings of this view
    private func setupView() {
        // Set the cell row height
        self.tableView.rowHeight = 50
        
        // Dismiss the keyboard when the user drags the table
        tableView.keyboardDismissMode = .interactive
        
        // Set navigation bar to big title
        self.navigationItem.title = "InteList"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    
    /// Purpose: Sets up all the models
    /// Called in viewDidLoad
    private func setupModels() {
        loadCategoriesFromContext() // Load the categories
        loadItemsFromContext() // Load the items
    }
    
//    func createPlaceHolderCells() {
//        for index in 0..<items.count {
//            if items[index].count == 0 {
//                items[index].append(<#T##newElement: Item##Item#>)
//            }
//        }
//    }
    
    
    /****************************************/
    /****************************************/
    //MARK: - General Core Data Methods
    /****************************************/
    /****************************************/
    
    /// Saves the current working data to the Data Model
    func saveContext() {
        coreDataManager.saveContext() // Go to Data Model and save context
        self.tableView.reloadData() // Update the view
    }
    
    /****************************************/
    /****************************************/
    //MARK: - Category Core Data Methods
    /****************************************/
    /****************************************/
    
    /// Loads the Categories from Data Model
    private func loadCategoriesFromContext() {
        categories = coreDataManager.loadCategories() // Make a request to fetch the Category entities in the database
        
        // Create our categories
        if !categoryExists(categoryName: CategoryEnum.Produce.rawValue) {
            addCategory(categoryName: CategoryEnum.Produce.rawValue)
        }
        if !categoryExists(categoryName: CategoryEnum.Bakery.rawValue) {
            addCategory(categoryName: CategoryEnum.Bakery.rawValue)
        }
        if !categoryExists(categoryName: CategoryEnum.Meat.rawValue) {
            addCategory(categoryName: CategoryEnum.Meat.rawValue)
        }
        if !categoryExists(categoryName: CategoryEnum.Dairy.rawValue) {
            addCategory(categoryName: CategoryEnum.Dairy.rawValue)
        }
        if !categoryExists(categoryName: CategoryEnum.Packaged.rawValue) {
            addCategory(categoryName: CategoryEnum.Packaged.rawValue)
        }
        if !categoryExists(categoryName: CategoryEnum.Frozen.rawValue) {
            addCategory(categoryName: CategoryEnum.Frozen.rawValue)
        }
        if !categoryExists(categoryName: CategoryEnum.Other.rawValue) {
            addCategory(categoryName: CategoryEnum.Other.rawValue)
        }
    }
    
    /// Adds a Category to the Data Model and the Table View
    ///
    /// - Parameter categoryName: The title of the Category entity
    private func addCategory(categoryName: String) {
        if !categoryExists(categoryName: categoryName) {
            // Get the new Category created
            if let newCategory = coreDataManager.addCategory(categoryName: categoryName) {
                // Add new category to table View's array
                self.categories.append(newCategory)
            }
        }
    }
    
    /// Deletes a Category entity
    ///
    /// - Parameter categoryName: The title of the Category entity
    private func deleteCategory(categoryName: String) {
        coreDataManager.deleteCategory(categoryName: categoryName)
    }
    
    /// Deletes all Category entities from the Data Model
    private func deleteAllCategory() {
        deleteCategory(categoryName: "Produce")
        deleteCategory(categoryName: "Bakery")
        deleteCategory(categoryName: "Meat/Seafood")
        deleteCategory(categoryName: "Dairy")
        deleteCategory(categoryName: "Packaged/Canned")
        deleteCategory(categoryName: "Frozen")
        deleteCategory(categoryName: "Other")
    }
    
    /// Checks if a Category exists in the Data Model
    ///
    /// - Parameter categoryName: Title of Category entity
    /// - Returns: A boolean of whether the Category with that title exists
    func categoryExists(categoryName: String) -> Bool {
        return coreDataManager.categoryExists(categoryName: categoryName)
    }
    

    
    
    /****************************************/
    /****************************************/
    //MARK: - Item Core Data Methods
    /****************************************/
    /****************************************/
    
    /// Adds an Item to the Data Model and the Table View
    ///
    /// - Parameters:
    ///   - name: Title of the Item entity
    ///   - category: The Category entity the Item relates to
    /// Make a fetch request for each Item entity related to the Category entities
    private func loadItemsFromContext() {
        let requestItems: NSFetchRequest<Item> = Item.fetchRequest()
        
        for index in 0..<7 {
            let itemPredicate = NSPredicate(format: "ANY category.name in %@", [categories[index].name])
            requestItems.predicate = itemPredicate
            
            items[index] = coreDataManager.loadItems(request: requestItems)
            
            // TODO: Add placeholder cells
            if items[index].count == 0 {
                let placeholderItem: Item = coreDataManager.addItem(toCategory: categories[index], withItemName: "")
                items[index].append(placeholderItem)
            }
        }
        
        
    }
    
    func add(itemName name:String, toCategory category: Category) {
        let index = categories.firstIndex(of: category)! // Get the index of the Category we are adding to
        let newItem = coreDataManager.addItem(toCategory: category, withItemName: name)
        
        items[index].append(newItem) // Add to items tableview array
    }
    
    
    /// Deletes an Item from the Data Model and the Table View
    ///
    /// - Parameter itemName: The title of the Item entity
    func deleteItem(itemName: String) {
        coreDataManager.deleteItem(itemName: itemName)
        tableView.reloadData()
    }
}
