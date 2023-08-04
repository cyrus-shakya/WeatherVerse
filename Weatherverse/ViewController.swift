//
//  ViewController.swift
//  Weatherverse
//
//  Created by Cyrus Shakya on 2023-07-27.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,UITextFieldDelegate,CLLocationManagerDelegate {
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var weatherCondition: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var bgImg: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    
    var locationManager: CLLocationManager?
    
    struct CurrentLocationWrapper: Decodable {
        let location:locationData
        let current: currentLocationData
    }
    
    struct locationData: Decodable {
        let name: String
    }
    
    struct currentLocationData: Decodable {
        let temp_c: Double
        let temp_f: Double
        let is_day: Int
        let condition: conditionData
    }
    
    struct conditionData: Decodable {
        let text: String
        let code: Int
    }
    
    
    struct WeatherData {
        let locationName: String
        let tempCelsius: Double
        let tempFahrenheit: Double
        let conditionText: String
        let conditionCode: Int
        let isDay: Int
    }
    
    struct SearchHistory{
        var history:[WeatherData]
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtSearch.delegate = self
        
        initWeatherIcon()
        
        setupLocationManager()
    }
    
    func initWeatherIcon(){
        // ocnfiguration of colors in imgIcons
        let config = UIImage.SymbolConfiguration(paletteColors: [.cyan, .systemTeal])
        weatherIcon.preferredSymbolConfiguration = config
        
        // setting img from system SF symbols
        weatherIcon.image = UIImage(systemName: "cloud.sun.fill")
    }
    
    
    //    current location
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
    }
    
    
    
    @IBAction func getCurrentLocation(_ sender: UIButton) {
        locationManager?.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            print("Latitude: \(latitude)\nLongitude: \(longitude)")
            
            searchWeather("\(latitude),\(longitude)")
            
        }
        locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update error: \(error.localizedDescription)")
    }
    
    
    var searchHistory = SearchHistory(history: [])
    
    func parseWeather(data: Data) -> CurrentLocationWrapper? {
        let decoder = JSONDecoder()
        var wrapper: CurrentLocationWrapper?
        
        do{
            wrapper = try decoder.decode(CurrentLocationWrapper.self, from: data)
        }
        catch{
            print (error)
        }
        return wrapper
    }
    
    func getWeatherData(data:Data?,response:URLResponse?,error:Error?){
        
        guard error == nil else{
            print(error ?? "there is a error")
            return
        }
        
        guard let data = data else{
            print("No data received")
            return
        }
        
        
        if let locationWrapper = parseWeather(data: data){
            //            print(locationWrapper.location.name)
            
            let weatherData = WeatherData(
                locationName: locationWrapper.location.name,
                tempCelsius: locationWrapper.current.temp_c,
                tempFahrenheit: locationWrapper.current.temp_f,
                conditionText: locationWrapper.current.condition.text,
                conditionCode: locationWrapper.current.condition.code,
                isDay: locationWrapper.current.is_day
            )
            
            searchHistory.history.append(weatherData)
            
            DispatchQueue.main.async {
                self.temperatureLabel.text = String(weatherData.tempCelsius)
                self.weatherCondition.text = weatherData.conditionText
                self.cityLabel.text = weatherData.locationName
                self.bgImg.image = UIImage(named: locationWrapper.current.is_day == 0 ? "night_time": "bg")
                self.changeWeatherIcon(locationWrapper.current.condition.code)
            }
            
        }
    }
    
    func changeWeatherIcon(_ weatherCode:Int){
        
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
        
        weatherIcon.image = UIImage(systemName: conditionName)
        
    }
    
    
    
    func getUrl(_ location:String)->URL{
        
        let baseUrl="https://api.weatherapi.com/v1/current.json"
        let key="a753f78778fb409bab4235010230108"
        let locationParam = location.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let endPoint:String = "\(baseUrl)?q=\(locationParam)&key=\(key)"
        
        return URL(string: endPoint) ?? URL(string: "")!
    }
    
    
    func searchWeather(_ txtSearch: String){
        // 1. Create URL
        let url: URL? = getUrl(txtSearch)
        
        // 2. Create URLsession
        
        let urlSession=URLSession(configuration: .default)
        
        // 3. Create task for URLsession
        if let url = url{
            let dataTask=urlSession.dataTask(with: url, completionHandler: getWeatherData(data:response:error:))
            
            // 4. Start task
            dataTask.resume()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        searchWeather(txtSearch.text ?? "")
        return true
    }
    
    
    
    @IBAction func btnSearchClicked(_ sender: UIButton) {
        
        searchWeather(txtSearch.text ?? "")
    }
    
    
    @IBAction func onTempUnitChanged(_ sender: UISegmentedControl) {
        guard let weatherData = searchHistory.history.last else {
                    return
                }

                switch sender.selectedSegmentIndex {
                case 0:
                    temperatureLabel.text = String(weatherData.tempCelsius)
                case 1:
                    temperatureLabel.text = String(weatherData.tempFahrenheit)
                default:
                    break
                }
    }
    
    @IBAction func btnCitiesClicked(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCities", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "goToCities" {
                if let citiesViewController = segue.destination as? CityHistoryController {
                    citiesViewController.citiesArray = searchHistory.history
                }
            }
        }
    
}
    
    
    

