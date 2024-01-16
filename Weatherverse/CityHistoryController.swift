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
        
        let config = UIImage.SymbolConfiguration(paletteColors: [.gray, .systemTeal])
        let symbolName :String = String(changeWeatherIcon(city.conditionCode))
        let symbolImage = UIImage(systemName:symbolName, withConfiguration: config)
        content.image = symbolImage
        
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func changeWeatherIcon(_ weatherCode:Int)-> String{
        
        var conditionName: String{
            switch weatherCode{
            case 1000:
                return "sun.max.fill"
            case 1003...1009:
                return "cloud.fill"
            case 1030:
                return "cloud.fog.fill"
            case 1183...1207:
                return "cloud.rain.fill"
            case 1210...1237:
                return "cloud.snow.fill"
            case 1273...1282:
                return "cloud.bolt.rain"
            default:
                return "cloud.sun.fill"
            }
        }
        
        return conditionName;
        
    }
    
}
