//
//  CityHistoryController.swift
//  Weatherverse
//
//  Created by Nabin Pun on 2023-08-03.
//

import UIKit

class CityHistoryController: UIViewController {
    
    @IBOutlet weak var citiesTableView: UITableView!
    
    var citiesArray: [ViewController.WeatherDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        citiesTableView.dataSource = self
        citiesTableView.delegate = self
    }
}

extension CityHistoryController: UITableViewDataSource,UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citiesArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "citiesViewCell", for: indexPath)
        
        let city = citiesArray[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = city.locationName
        content.secondaryText = String(city.tempInCelsius) + "°C"
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
}
