//
//  GeoLocationsResultTableViewController.swift
//  You'reThere
//
//  Created by SINCY on 12/12/19.
//  Copyright © 2019 SINCY. All rights reserved.
//

import UIKit
import MapKit

protocol MapLocationSearchDelegate {
    func createPin(forPlacemark placemark: MKPlacemark)
}

class GeoLocationsResultTableViewController: UITableViewController {

    var matchingLocations: [MKMapItem] = []
    var mapView: MKMapView?
    var locationSearchDelegate: MapLocationSearchDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingLocations.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "geoLocationCell", for: indexPath)

        let selectedItem = matchingLocations[indexPath.row].placemark
        cell.textLabel?.text = selectedItem.name
        cell.detailTextLabel?.text = ""
        
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = matchingLocations[indexPath.row].placemark
        locationSearchDelegate?.createPin(forPlacemark: selectedPlacemark)
        dismiss(animated: true, completion: nil)
    }
}


extension GeoLocationsResultTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchBarText = searchController.searchBar.text, let geoMapView = mapView else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = geoMapView.region
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            self.matchingLocations = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    
}
