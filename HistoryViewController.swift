//
//  HistoryViewController.swift
//  My App
//
//  Created by Guanming Qiao on 6/16/17.
//  Copyright © 2017 Guanming Qiao. All rights reserved.
//

import UIKit

class HistoryViewController: UITableViewController {
  
  
  var selectedCity:String?{
    didSet {
      if let city = selectedCity {
        selectedCityIndex = cities.index(of:city)
      }
    }
  }
  
  var selectedCityIndex : Int?
  
  var cities: [String] = defaults.stringArray(forKey: "historyData")!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return cities.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell", for: indexPath)
    cell.textLabel?.text=cities[indexPath.row]
    
    if indexPath.row == selectedCityIndex {
      cell.accessoryType = .checkmark
    } else {
      cell.accessoryType = .none
    }
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if let index = selectedCityIndex{
      let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
      cell?.accessoryType = .none
    }
    selectedCity = cities[indexPath.row]
    let cell = tableView.cellForRow(at: indexPath)
    cell?.accessoryType = .checkmark
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "LookUp" {
      if let cell = sender as? UITableViewCell {
        let indexPath = tableView.indexPath(for: cell)
        if let index = indexPath?.row {
          selectedCity = cities[index]
        }
      }
    }
  }
  
}
