//
//  KitchenDetail+Extensions.swift
//  Smart List
//
//  Created by Haamed Sultani on Apr/1/19.
//  Copyright © 2019 Haamed Sultani. All rights reserved.
//

import UIKit

extension KitchenDetailViewController {
    
    /// Hide the quantity pop up view with animation
    ///
    /// - Parameter sender: the button clicked to trigger this action
    @objc override func doneButtonTapped(_ sender: UIButton) {
        
        // If the user was using the expiry pop up view
        if sender == expiryDateView.saveButton {
            
            // Set the expiration date's time to 9AM
            let roundedDate = Calendar.current.date(bySettingHour: 13, minute: 0, second: 0, of: expiryDateView.datePicker.date)
            
            self.item.expiryDate = roundedDate           // Set the expiration date of the Item
            
			
			// Save changes to core data
			self.coreData.saveContext()
			
            // Update the expiry UIButton's title with the new date
            self.midContainer.expiryDate.setTitle(DateHelper.shared.getDateString(of: (self.item.expiryDate)!), for: .normal)
            
            // Send a notification that will trigger when the item is expired
            NotificationHelper.shared.sendNotification(withExpiryDate: self.item.expiryDate!, itemName: self.item.name!, imageURL: self.item.imageThumbURL!)
            
            // Hide the pop up view
            self.expiryDateView.fadeOut()
            
            
        // If the user was using the quantity pop up view
        } else if sender == quantityView.saveButton {
            // Grab the quantity string
            let enteredQuantity : String = self.quantityView.quantityTextField.text! + " " + self.originalUnits[self.quantityView.pickerView.selectedRow(inComponent: 0)]
            // Set and save the Item's quantity
            self.item!.quantity = enteredQuantity
            
			// Save changes to Core Data
			self.coreData.saveContext()
            
            // Hide the keyboard
            quantityView.quantityTextField.resignFirstResponder()
            
            // Update the view with the new quantity
            self.midContainer.quantityButton.setTitle(self.item.quantity, for: .normal)
            
            // Hide the pop up view
            self.quantityView.fadeOut()
            
            // Change the unit of measurement to the short-hand version
            self.midContainer.quantityButton.setTitle(UnitHelper.shared.abbreviateUnit(u: ((self.item.quantity)!)), for: .normal)
            
        }
    }
    
    
    
    override func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView == midContainer.noteTextView {
            print("save notes to DB")
            
            
            // Update the notes in the Item entity
            self.item.notes = midContainer.noteTextView.text
            // Save to Core Data
			self.coreData.saveContext()
        }
    }
    
    override func textFieldDidEndEditing(_ textField: UITextField) {
        
        // If the user dismisses the keyboard or taps the Done key
        if textField == midContainer.storeTextField && textField.text?.trimmingCharacters(in: .whitespaces) != "" {
            if let store = midContainer.storeTextField.text {
                self.item.store = store
				// Save changes to Core Data
				self.coreData.saveContext()
            }
        } 
    }
}
