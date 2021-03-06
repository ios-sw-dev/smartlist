//
//  Home+NavBarItems.swift
//  Smart List
//
//  Created by Haamed Sultani on Feb/1/19.
//  Copyright © 2019 Haamed Sultani. All rights reserved.
//
//
//  The methods for the navigation bar

import UIKit

extension HomeViewController {
    
    /// Sets up the navigation bar buttons
    func setupNavItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
		navigationItem.rightBarButtonItem?.tintColor = Constants.Visuals.ColorPalette.BabyBlue
        
        doneShoppingBarButtonItem = UIBarButtonItem(title: "Unload", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneShoppingButtonTapped))
        navigationItem.leftBarButtonItem = doneShoppingBarButtonItem
		navigationItem.leftBarButtonItem?.tintColor = Constants.Visuals.ColorPalette.SeaGreen
    }
    
    
    
    /// Goes throught all the Items in the list and adds the completed Items to our KitchenItem entity table
    /// Deletes the Items from the list if they are completed
    @objc func doneShoppingButtonTapped() {
        
        viewModel.items.forEach {                                                                            // Go through each category
            $0.forEach {                                                                                // Go through each item in that category
                if $0.completed                                                                         // If it is completed
                {
                    viewModel.coreData.addKitchenItem(item: $0)                                       // Add the completed Item to our Core Data KitchenItem entity table

                    let categoryIndex : Int = viewModel.categories.firstIndex(of: $0.category!)!             // Get the category index of the item
                    let itemIndex : Int = viewModel.items[categoryIndex].firstIndex(of: $0)!                 // Get the item index of the item
                    let indexPath: IndexPath = IndexPath(row: itemIndex, section: categoryIndex)        // Set the indexPath
                    
                    viewModel.items[categoryIndex].remove(at: itemIndex)                                     // Remove the item from the datasource array
                    self.tableView.deleteRows(at: [indexPath], with: .fade)                             // Remove from the cell from the tableview
                    viewModel.deleteItem(itemId: $0.id!, categoryName: $0.category!.name!)                   // Delete the Item entity from Core Data
                }
            }
        }
    }
    
    
    /// Description: This method is called when the user taps on the + sign at the top right
    ///
    /// Allows the user to add a category to the TableView
    /// They are presented with a list of options, one of them being an option to add their own
    @objc func addButtonTapped() {
        // Create the alert controller
        let alert = UIAlertController(title: "New category", message: "Which category would you like to create?", preferredStyle: .actionSheet)
        
        // Goes through the filtered list of categories and adds the action to the alert controller
        for cat in viewModel.validateCategories() {
            alert.addAction(UIAlertAction(title: cat, style: .default, handler: {
                [weak self] (UIAlertAction) in
                guard let self = self else {return}

                self.tableView.beginUpdates()
                
                // Add the Category entity to Core Data if it doesn't already exist
                if (self.viewModel.createAndSaveCategory(categoryName: cat)) {
                    self.toggleInstructions()
                }
                
                self.tableView.insertSections(NSIndexSet(index: self.viewModel.categories.count - 1) as IndexSet, with: .bottom)      // Insert the Category section into the table view
                self.addPlaceHolderCell(toCategory: self.viewModel.categories[self.viewModel.categories.count-1])                               // Insert the dummy cell into the new Category
                
                self.tableView.endUpdates()
                // Scroll to the category the user just added
                let indexPath = IndexPath(row: 0, section: self.viewModel.categories.count-1)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }))
        }
        
        
        /// Creates another alert where user can type a custom category
        alert.addAction(UIAlertAction(title: "Create my own", style: .default, handler: {
            [weak self] (UIAlertAction) in
            guard let `self` = self else {return}

            // Create another alert that allows the user to type a name for their category
            let customAlert = UIAlertController(title: "Title", message: "Enter the name of your category", preferredStyle: .alert)
            
            // Add a textfield to the alert
            customAlert.addTextField { (textField) in
                textField.placeholder = "Category name"
            }
            
            // Lets the user confirm and add their custom category
            let okAction = UIKit.UIAlertAction(title: "Ok", style: .default, handler: {(UIAlertAction) in
                let textField = customAlert.textFields![0]
                self.tableView.beginUpdates()
                
                // Add the Category entity to Core Data if it doesn't already exist
                if (self.viewModel.createAndSaveCategory(categoryName: textField.text!)) {
                    self.toggleInstructions()
                }
                
                self.tableView.insertSections(NSIndexSet(index: self.viewModel.categories.count - 1) as IndexSet, with: .bottom)      // Insert the Category section into the table view
                self.addPlaceHolderCell(toCategory: self.viewModel.categories[self.viewModel.categories.count-1])                               // Insert the dummy cell into the new Category
                
                self.tableView.endUpdates()
                
                // Scroll to the category the user just added
                let indexPath = IndexPath(row: 0, section: self.viewModel.categories.count-1)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            })
            
            // Disable the OK button in the alert
            okAction.isEnabled = false
            
            
            // Lets the user go back to the previous action sheet
            customAlert.addAction(UIKit.UIAlertAction(title: "Go back", style: .cancel, handler: {(UIAlertAction) in
                self.present(alert, animated: true, completion: nil)
            }))
            
            // Observe the text the user enters
            // If it isn't empty then enable the OK button, otherwise disable it
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: customAlert.textFields![0], queue: OperationQueue.main, using: {(notification) in
                
                if customAlert.textFields![0].text != "" {
                    okAction.isEnabled = true
                } else {
                    okAction.isEnabled = false
                }
            })
            
            // Present the nested alert
            customAlert.addAction(okAction)
            self.present(customAlert, animated: true, completion: nil)
        }))
        
        
        // Cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(UIAlertAction) in
        }))
        
        
        // Display the Alert Controller
        self.present(alert, animated: true, completion: {
        })
    }
}
