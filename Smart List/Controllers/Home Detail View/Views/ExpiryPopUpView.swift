//
//  ExpiryPopUpView.swift
//  Smart List
//
//  Created by Haamed Sultani on Feb/1/19.
//  Copyright © 2019 Haamed Sultani. All rights reserved.
//

import UIKit

class ExpiryPopUpView: PopUpCardView {
    
    /****************************************/
    //MARK: - 1: Title Section
    /****************************************/
    var viewTitleLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Expiration Date"
        label.textColor = Constants.ColorPalette.Orange
        label.font = UIFont(name: Constants.Visuals.fontName, size: 20)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 10
        
        return label
    }()
    
    var saveButton: UIButton = {
        var button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Done", for: .normal)
        button.setTitleColor(Constants.ColorPalette.Charcoal, for: .normal)
        button.titleLabel!.font = UIFont(name: Constants.Visuals.fontName, size: 20)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(DetailViewController.doneButtonTapped(_:)), for: .touchUpInside)
        
        return button
    }()
    
    var titleStackView: UIStackView = {
        var view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 0
        
        return view
    }()
    
    /****************************************/
    //MARK: - 2: Date Picker Section
    /****************************************/
    
    var datePicker: UIDatePicker = {
        var picker = UIDatePicker()
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.datePickerMode = .date
        
        return picker
    }()
    
    
    
    /****************************************/
    //MARK: Setup Methods
    /****************************************/
    override func setupUIComponents() {
        //
        // Title Stack View
        //
        titleStackView.addArrangedSubview(viewTitleLabel)   // Add 'Expiration Date' title to stack
        titleStackView.addArrangedSubview(saveButton)       // Add SAVE button to stack
        addSubview(titleStackView)                          // Add the stack to the view
        
        // Button's height = 'Quantity' label height
        saveButton.heightAnchor.constraint(equalTo: viewTitleLabel.heightAnchor).isActive = true
        // Set the width of the stack's components
        saveButton.widthAnchor.constraint(equalTo: titleStackView.widthAnchor, multiplier: 0.3).isActive = true
        viewTitleLabel.widthAnchor.constraint(equalTo: titleStackView.widthAnchor, multiplier: 0.7).isActive = true
        // Activate the constraints on the stackview
        NSLayoutConstraint.activate([
            titleStackView.topAnchor.constraint(equalTo: topAnchor),
            titleStackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleStackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            titleStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.15)
            ])
        
        
        //
        // Date Picker View
        //
        addSubview(datePicker)
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            NSLayoutConstraint(item: datePicker, attribute: .top, relatedBy: .equal, toItem: titleStackView, attribute: .bottom, multiplier: 1, constant: 0)
            ])
    }
}