//
//  SignUpViewController.swift
//  Smart List
//
//  Created by Haamed Sultani on Jun/1/19.
//  Copyright © 2019 Haamed Sultani. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    //MARK: - Properties
    var activeText : UITextField?
    var isPoppedUp : Bool = false
    private var coreData : CoreDataManager
    
    //MARK: - UI Elements
    var spinner = UIActivityIndicatorView()
    var spinnerContainer = UIView()
    
    
    var topContainer : SignUpTopContainer = {
        var view = SignUpTopContainer()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var bottomContainer : SignUpBottomContainer = {
        var view = SignUpBottomContainer()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var scrollView : UIScrollView = {
        var view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()

    
    init(coreDataManager: CoreDataManager) {
        self.coreData = coreDataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        registerForKeyboardEvents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    deinit {
        // Unregister for the keyboard notifications. Therefore, stop listening for the events
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        print("Deinitializing Sign Up View Controller")
    }
    
    
    
    //MARK: - Initialization Methods
    private func setupView() {
		view.backgroundColor = Constants.Visuals.ColorPalette.OffWhite
        
        // Adding top container and configuring
        view.addSubview(scrollView)
        
        // Constraints for scrollView
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.widthAnchor.constraint(equalTo: view.widthAnchor)
            ])
        
        scrollView.addSubview(topContainer)
        scrollView.addSubview(bottomContainer)
        
        // Constraints for topContainer
        NSLayoutConstraint.activate([
            topContainer.topAnchor.constraint(equalTo: scrollView.topAnchor),
            topContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            topContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.40),
            topContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
        
        
        // Constraint for bottomContainer
        NSLayoutConstraint.activate([
            NSLayoutConstraint(item: bottomContainer, attribute: .top, relatedBy: .equal, toItem: topContainer, attribute: .bottom, multiplier: 1, constant: 50),
            bottomContainer.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            bottomContainer.heightAnchor.constraint(equalTo: scrollView.heightAnchor, multiplier: 0.4),
            bottomContainer.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor)
            ])
    }
    
    private func registerForKeyboardEvents() {
        bottomContainer.nameField.delegate = self
        bottomContainer.emailField.delegate = self
        bottomContainer.passwordField.delegate = self
        
        // Listen for keyboard events that will adjust the view
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // Hide the keyboard if the user taps outside the keyboard
        self.hideKeyboardWhenTappedAround()
    }
    
    
    /// This method enables the Sign Up button iff all textFields are filled
    func toggleSignUp() {
        if (bottomContainer.nameField.text != "" && bottomContainer.emailField.text != "" && bottomContainer.passwordField.text != "") {
            bottomContainer.signUpButton.isEnabled = true
        } else {
            bottomContainer.signUpButton.isEnabled = false
        }
    }
    
    
    func toggleEmailImage(toggle : Bool) {
        if (toggle) {
            bottomContainer.emailImage.isHidden = false
            bottomContainer.emailImage.image = UIImage(named: "check")
        } else {
            bottomContainer.emailImage.isHidden = false
            bottomContainer.emailImage.image = UIImage(named: "warning")
            
        }
    }
    
    func togglePasswordImage(toggle : Bool) {
        if (toggle) {
            bottomContainer.passwordImage.isHidden = false
            bottomContainer.passwordImage.image = UIImage(named: "check")
        } else {
            bottomContainer.passwordImage.isHidden = false
            bottomContainer.passwordImage.image = UIImage(named: "warning")
            
        }
    }
    
    //MARK: - UI Event Handling
    /// Send server request to create a new user, upon success, save the user name and email in Core Data
    ///
    /// - Parameter sender: The button the user tapped to trigger this action
    @objc func signUpButtonTapped(_ sender: UIButton = UIButton()) {
        if (bottomContainer.nameField.text != nil &&
            bottomContainer.emailField.text != nil &&
            bottomContainer.passwordField.text != nil) {
            
            self.view.showLargeSpinner(spinner: self.spinner, container: self.spinnerContainer)                                 // Show the spinner
            
            
            // Make a request to Smartlist API to create a new User in the DB
            Server.shared.signUpNewUser(name: bottomContainer.nameField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                                        email: bottomContainer.emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines),
                                        password: bottomContainer.passwordField.text!.trimmingCharacters(in: .whitespacesAndNewlines)) {
                newUser in
                
                self.view.hideSpinner(spinner: self.spinner, container: self.spinnerContainer)                                  // Hide the spinner
                                            
                if let error = newUser["error"] {                                                                               // Server responded with error
                    
                    let alertController = UIAlertController(title: "Error signing up",                                              // Alert user of an error
                        message: error,
                        preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "Ok", style: .default)
                    alertController.addAction(okAction)
                    
                    DispatchQueue.main.async {
                        self.present(alertController, animated: true)                                                               // Show alert
                    }
                }
                else if (newUser["name"] != "" && newUser["email"] != "" && newUser["token"] != "") {                           // If the server response contains valid User information
                    self.coreData.addUser(name: newUser["name"]!, email: newUser["email"]!, token: newUser["token"]!)      // Save the user's information in Core Data
                    
                    DispatchQueue.main.async {
                        self.dismiss(animated: true) {                                                                               // Hide the Sign Up View
                            // If the sign up view wasn't created from the profile tab
                            // then, create the TabBar (we are assuming the tabbar hasn't been created yet)
                            if (!self.isPoppedUp) {
                                self.present(TabBarController(coreDataManager: self.coreData), animated: true)                                                        // Create and show the tabbar
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    /// Displays the login page
    ///
    @objc func loginButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            self.present(LoginViewController(coreDataManager: self.coreData), animated: true)
        }
    }
    
    //MARK: - UI Event Handling
    /// Skip sign up and show the Kitchen Tab
    ///
    /// - Parameter sender: The button the user tapped to trigger this action
    @objc func skipButtonTapped(_ sender: UIButton) {
        print("skip sign up")
        
        self.coreData.setOfflineMode(offlineMode: true)    // Set offline mode to true
        
        self.dismiss(animated: true) {
            if (!self.isPoppedUp) {
                self.present(TabBarController(coreDataManager: self.coreData), animated: true)
            }
        }
    }
}
