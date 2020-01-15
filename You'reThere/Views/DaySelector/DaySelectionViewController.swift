//
//  DaySelectionViewController.swift
//  You'reThere
//
//  Created by SINCY on 02/01/20.
//  Copyright © 2020 SINCY. All rights reserved.
//

import UIKit

class DaySelectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var days = [
        ["title": "Sunday", "abb": "S", "isSelected": true],
        ["title": "Monday", "abb": "M", "isSelected": true],
        ["title": "Tuesday", "abb": "T", "isSelected": true],
        ["title": "Wednesday", "abb": "W", "isSelected": true],
        ["title": "Thursday", "abb": "T", "isSelected": true],
        ["title": "Friday", "abb": "F", "isSelected": true],
        ["title": "Saturday", "abb": "S", "isSelected": true]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(UINib(nibName: "DaySelectorCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: Constants.daySelectorCellId)
    }
    

}

extension DaySelectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.daySelectorCellId, for: indexPath) as! DaySelectorCollectionViewCell
        
        let cellData = days[indexPath.row]
        
        cell.title.text = cellData["abb"] as? String
        cell.isDaySelected = cellData["isSelected"] as? Bool ?? true
        
        return cell
    }
    
    
}

extension DaySelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        days[indexPath.row]["isSelected"] = !(days[indexPath.row]["isSelected"] as? Bool ?? true)
        collectionView.reloadData()
    }
}
