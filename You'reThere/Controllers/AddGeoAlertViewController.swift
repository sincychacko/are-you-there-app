//
//  AddGeoAlertViewController.swift
//  You'reThere
//
//  Created by SINCY on 12/12/19.
//  Copyright © 2019 SINCY. All rights reserved.
//

import UIKit
import MapKit

protocol AddGeoAlertDelegate {
    func createGeoAlert(with geoAlert: GeoAlert, controller: AddGeoAlertViewController)
}

class AddGeoAlertViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBarContainerView: UIView!
    @IBOutlet weak var alertNameTF: UITextField!
    @IBOutlet weak var alertRepeatMode: UISwitch!
    @IBOutlet weak var alertDateLabel: UILabel!
    @IBOutlet weak var navBarSaveButton: UIBarButtonItem!
    @IBOutlet weak var daySelectorView: UIView!
    
    
    // MARK: - Properties
        
    var searchController: UISearchController?
    var selectedPin: MKPlacemark?
    var shouldEnableSave = false {
        willSet(newValue) {
            navBarSaveButton.isEnabled = newValue
        }
    }
    var saveGeoAlertDelegate: AddGeoAlertDelegate?
    var lastContentOffset = CGPoint(x: 0, y: 0)
    var keyboardHt: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        shouldEnableSave = false
        sharedLocationManager.delegate = self
        sharedLocationManager.requestAlwaysAuthorization()
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddGeoAlertViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddGeoAlertViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func initialSetup() {
        alertRepeatMode.isOn = true
        alertDateLabel.isHidden = true
        daySelectorView.isHidden = true
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "GeoLocationsResultTable") as! GeoLocationsResultTableViewController
        searchController = UISearchController(searchResultsController: locationSearchTable)
        locationSearchTable.mapView = mapView
        locationSearchTable.locationSearchDelegate = self
        searchController?.searchResultsUpdater = locationSearchTable
        searchController?.dimsBackgroundDuringPresentation = true
        searchController?.hidesNavigationBarDuringPresentation = false
        
        guard searchController != nil else {
            return
        }
        searchController?.searchBar.placeholder = "Search for places"
        searchBarContainerView.addSubview(searchController!.searchBar)
        definesPresentationContext = true
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func repeatModeChanged(_ sender: Any) {
        if alertRepeatMode.isOn {
            alertDateLabel.isHidden = true
            daySelectorView.isHidden = true
        } else {
            alertDateLabel.isHidden = false
            daySelectorView.isHidden = false
        }
    }
    
    @IBAction func onZoom(_ sender: Any) {
        mapView.zoomToUserLocation()
    }

    @IBAction func onSave(_ sender: Any) {
//        let clampedRadius = min(100, locationManager.maximumRegionMonitoringDistance)
        let repeatM: GeoAlert.RepeatMode = alertRepeatMode.isOn ? .always : .justOnce
        let newGeoAlert = GeoAlert(coordinate: mapView.centerCoordinate, name: alertNameTF.text ?? "", repeatMode: repeatM)
        let result = GeoAlertLocationManager.shared.startMonitoring(geoAlert: newGeoAlert)
        switch result {
        case .failure(let error):
            showGeoAlertError(withGeoError: error)
        default:
            saveGeoAlertDelegate?.createGeoAlert(with: newGeoAlert, controller: self)
        }
    }
    

}


// MARK: - CLLocationManagerDelegate

extension AddGeoAlertViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedAlways else {
            return
        }
        DispatchQueue.main.async {
            self.mapView.showsUserLocation = true
            sharedLocationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mapView.zoomToUserLocation()
        
        sharedLocationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
       print("Monitoring failed for region with identifier: \(region!.identifier)")
     }
     
     func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
       print("Location Manager failed with the following error: \(error)")
     }
}


// MARK: - MapLocationSearchDelegate

extension AddGeoAlertViewController: MapLocationSearchDelegate {
    func createPin(forPlacemark placemark: MKPlacemark) {
        selectedPin = placemark
        // clear existing pins
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
        let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
            alertNameTF.text = "\(placemark.name ?? ""), \(city) \(state)"
        }
        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        shouldEnableSave = true
    }
    
    
}

// MARK: - TextField Delegate methods

extension AddGeoAlertViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        lastContentOffset = scrollView.contentOffset
        
        return true
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let name = textField.text, name.count > 0 {
            shouldEnableSave = true
        } else {
            shouldEnableSave = false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}


// MARK: - Keyboard show/hide

extension AddGeoAlertViewController {
    @objc func keyboardWillShow(notification: Notification) {
        self.keyboardHt = keyboardHeight(notification: notification)
        
        if keyboardHt == 0 {
            return
        }
        
        // so increase contentView's height by keyboard height
        UIView.animate(withDuration: 0.3, animations: {
            self.scrollView.contentSize.height += self.keyboardHt
        })
        // move if keyboard hide input field
        let distanceToBottom = self.scrollView.frame.size.height - (alertNameTF?.frame.origin.y)! - (alertNameTF?.frame.size.height)!
        let collapseSpace = keyboardHt - distanceToBottom
        if collapseSpace < 0 {
            // no collapse
            return
        }
        // set new offset for scroll view
        UIView.animate(withDuration: 0.3, animations: {
        // scroll to the position above keyboard 10 points
            self.scrollView.contentOffset = CGPoint(x: self.lastContentOffset.x, y: collapseSpace + 10)
        })
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.scrollView.contentSize.height -= self.keyboardHt
            self.scrollView.contentOffset = self.lastContentOffset
        }
        keyboardHt = 0
    }
}


extension MKMapView {
  func zoomToUserLocation() {
    guard let coordinate = userLocation.location?.coordinate else { return }
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
    setRegion(region, animated: true)
  }
}
