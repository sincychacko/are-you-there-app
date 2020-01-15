//
//  ViewController.swift
//  You'reThere
//
//  Created by SINCY on 11/12/19.
//  Copyright © 2019 SINCY. All rights reserved.
//

import UIKit
import MapKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var addAlertButton: UIButton!
    @IBOutlet weak var getStartedLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var geoAlerts: [GeoAlert] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        geoAlerts.removeAll()
        geoAlerts = Self.getAllGeoAlerts()
        updateView()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addGeoAlert" {
            let navigationController = segue.destination as! UINavigationController
            let vc = navigationController.viewControllers.first as! AddGeoAlertViewController
            vc.saveGeoAlertDelegate = self
        }
    }
    
    
    func updateView() {
        navigationController?.navigationBar.isHidden = geoAlerts.count == 0
        navigationItem.rightBarButtonItem?.isEnabled = (geoAlerts.count < 10)
        tableView.isHidden = geoAlerts.count == 0
        addAlertButton.isHidden = geoAlerts.count > 0
        getStartedLabel.isHidden = geoAlerts.count > 0
    }
    
    class func getAllGeoAlerts() -> [GeoAlert] {
        
        // Fetch from user defaults
        guard let savedData = UserDefaults.standard.data(forKey: Constants.savedAlerts) else { return [] }
        let decoder = JSONDecoder()
        if let savedGeoAlerts = try? decoder.decode(Array.self, from: savedData) as [GeoAlert] {
            return savedGeoAlerts
        }
        return []
    }
    
    func saveAllAlerts() {
      let encoder = JSONEncoder()
      do {
        let data = try encoder.encode(geoAlerts)
        UserDefaults.standard.set(data, forKey: Constants.savedAlerts)
      } catch {
        print("error encoding geotifications")
      }
    }

}

extension HomeViewController: AddGeoAlertDelegate {
    func createGeoAlert(with geoAlert: GeoAlert, controller: AddGeoAlertViewController) {
        controller.dismiss(animated: true, completion: nil)
        
        geoAlerts.append(geoAlert)
        updateView()
        tableView.reloadData()
        saveAllAlerts()
    }
    
}


extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return geoAlerts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.alertCellIdentifier, for: indexPath)
        
        cell.textLabel?.text = geoAlerts[indexPath.row].name
        
        return cell
    }
    
    
}


extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            let deletedAlert = self.geoAlerts.remove(at: indexPath.row)
            self.saveAllAlerts()
            GeoAlertLocationManager.shared.stopMonitoring(geoAlert: deletedAlert)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }

        return [delete]
    }
    
}
