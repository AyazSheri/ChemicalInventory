//
//  Untitled.swift
//  ChemicalInventory
//
//  Created by Alex Vasiliev on 11/20/24.
//

import UIKit
import SwiftUI

class BaseViewController: UIViewController {
    private var hostingController: UIHostingController<Sidebar>?
    private var isMenuOpen = false
    private var dimmingView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        setupCustomNavigationBarButton()
        setupDimmingView()
        addSwipeGesture()
        setupSearchButton()
    }
    
    func setPageTitle(_ title: String) {
        navigationItem.title = title
    }
    
    private func setupSearchButton() {
        let searchButton = UIButton(type: .system)
        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        searchButton.addTarget(self, action: #selector(openSearch), for: .touchUpInside)

        let barButtonItem = UIBarButtonItem(customView: searchButton)
        navigationItem.rightBarButtonItem = barButtonItem

        print("DEBUG: Search button added to navigation bar.")
    }

    @objc private func openSearch() {
        let searchVC = SearchViewController()
        searchVC.modalPresentationStyle = .fullScreen
        present(searchVC, animated: true)
    }


    // Sets up the side menu as a SwiftUI overlay
    private func setupSideMenu() {
        let sidebar = Sidebar(isMenuOpen: .constant(isMenuOpen), onNavigate: { destination in
            print("DEBUG: Sidebar navigation selected: \(destination)")
            self.handleNavigation(destination: destination)
        })

        let sidebarWidth = UIScreen.main.bounds.width / 2.5

        let hostingController = UIHostingController(rootView: sidebar)
        hostingController.view.backgroundColor = UIColor.clear
        hostingController.view.frame = CGRect(
            x: -sidebarWidth, // Fully hidden offscreen initially
            y: 0,
            width: sidebarWidth,
            height: UIScreen.main.bounds.height
        )
        hostingController.view.isUserInteractionEnabled = true // Enable interactions on side menu

        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        
        self.hostingController = hostingController
        // Bring the side menu to the front
        view.bringSubviewToFront(hostingController.view)
        print("DEBUG: Side menu setup completed.")
    }

    private func setupCustomNavigationBarButton() {
        // Create a custom UIButton for the hamburger icon
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30) // Size of the button
        button.addTarget(self, action: #selector(toggleSideMenu), for: .touchUpInside)

        // Embed the button in a UIView to allow positioning
        let containerView = UIView(frame: button.frame)
        containerView.addSubview(button)

        // Add the custom view to the navigation bar
        let barButtonItem = UIBarButtonItem(customView: containerView)
        navigationItem.leftBarButtonItem = barButtonItem

        print("DEBUG: Custom hamburger button added to navigation bar.")
    }

    private func setupDimmingView() {
        // Create the dimming view
        let dimmingView = UIView(frame: view.bounds)
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.alpha = 0 // Hidden initially
        dimmingView.isHidden = true

        // Add a tap gesture recognizer for the dimming view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap))
        dimmingView.addGestureRecognizer(tapGesture)

        view.addSubview(dimmingView)
        self.dimmingView = dimmingView
    }
    
    @objc private func handleDimmingViewTap() {
        print("DEBUG: Dimming view tapped. Closing side menu.")
        if isMenuOpen {
            toggleSideMenu()
        }
    }



    private func addSwipeGesture() {
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        view.addGestureRecognizer(swipeGesture)
    }

    @objc private func handleSwipe(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view).x
        if isMenuOpen && translation < -50 { // Swipe left to close
            toggleSideMenu()
        }
    }

    @objc private func toggleSideMenu() {
        guard let hostingController = hostingController else {
            print("DEBUG: Hosting controller is nil. Side menu cannot be toggled.")
            return
        }

        isMenuOpen.toggle()
        print("DEBUG: Toggle side menu. isMenuOpen = \(isMenuOpen)")

        let sidebarWidth = UIScreen.main.bounds.width / 2.5

        UIView.animate(withDuration: 0.3, animations: {
            // Animate the side menu
            hostingController.view.frame.origin.x = self.isMenuOpen ? 0 : -sidebarWidth

            // Adjust the dimming view's frame to exclude the side menu
            self.dimmingView?.frame.origin.x = self.isMenuOpen ? sidebarWidth : 0

            // Show or hide the dimming view
            self.dimmingView?.alpha = self.isMenuOpen ? 1 : 0
        }) { _ in
            if !self.isMenuOpen {
                self.dimmingView?.isHidden = true
            } else {
                self.dimmingView?.isHidden = false
            }
        }
    }


    private func handleNavigation(destination: String) {
        print("DEBUG: Handling navigation to \(destination)")

        switch destination {
        case "Scan":
            navigateToScanPage()
        case "AddChemical":
            navigateToAddChemical()
        case "Profile":
            navigateToProfile()
        case "Logout":
                logout()
        default:
            print("DEBUG: Unknown destination: \(destination)")
        }

        // Close the menu after navigation
        toggleSideMenu()
    }

    private func navigateToScanPage() {
        if let scanPageVC = storyboard?.instantiateViewController(withIdentifier: "ScanPageViewController") as? ScanPageViewController {
            print("DEBUG: Navigating to ScanPageViewController")
            navigationController?.setViewControllers([scanPageVC], animated: true)
        } else {
            print("DEBUG: Failed to instantiate ScanPageViewController")
        }
    }
    
    private func navigateToAddChemical() {
        if let addChemicalVC = storyboard?.instantiateViewController(withIdentifier: "AddChemicalViewController") as? AddChemicalViewController {
            print("DEBUG: Navigating to AddChemicalViewController")
            navigationController?.setViewControllers([addChemicalVC], animated: true)
        } else {
            print("DEBUG: Failed to instantiate AddChemicalViewController")
        }
    }
    
    private func navigateToProfile() {
        if let profileVC = storyboard?.instantiateViewController(withIdentifier: "PIProfilePageViewController") as? PIProfilePageViewController {
            print("DEBUG: Navigating to PIProfilePageViewController")
            navigationController?.setViewControllers([profileVC], animated: true)
        } else {
            print("DEBUG: Failed to instantiate PIProfilePageViewController")
        }
    }
    
    
    
    private func logout() {
        print("DEBUG: Starting logout process...")
        UserSession.shared.clearSession()
        print("DEBUG: User session cleared.")
        
        // Navigate back to LoginView
        if let loginVC = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            print("DEBUG: Navigating to LoginViewController after logout")
            navigationController?.setViewControllers([loginVC], animated: true)
        }
    }


}
