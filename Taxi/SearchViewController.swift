//
//  SearchViewController.swift
//  Taxi
//
//  Created by Syria.Apple on 4/19/20.
//  Copyright © 2020 icanStudioz. All rights reserved.
//


///



import UIKit
import GooglePlaces

class SearchViewController: UIViewController {

  // TODO: Add a button to Main.storyboard to invoke onLaunchClicked.

  // Present the Autocomplete view controller when the button is pressed.
  @IBAction func onLaunchClicked(sender: UIButton) {
    let acController = GMSAutocompleteViewController()
    acController.delegate = self
    present(acController, animated: true, completion: nil)
  }
}

extension SearchViewController: GMSAutocompleteViewControllerDelegate {

  // Handle the user's selection.
  func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
    print("Place name: \(place.name)")
    print("Place address: \(place.formattedAddress)")
    print("Place attributions: \(place.attributions)")
    dismiss(animated: true, completion: nil)
  }

  func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
    // TODO: handle the error.
    print("Error: \(error)")
    dismiss(animated: true, completion: nil)
  }

  // User cancelled the operation.
  func wasCancelled(_ viewController: GMSAutocompleteViewController) {
    print("Autocomplete was cancelled.")
    dismiss(animated: true, completion: nil)
  }
}
