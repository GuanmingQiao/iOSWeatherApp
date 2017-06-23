//
//  WeatherGetter.swift
//  My App
//
//  Created by Guanming Qiao on 6/15/17.
//  Copyright © 2017 Guanming Qiao. All rights reserved.
//

import Foundation

struct Weather {
  let dateAndTime: NSDate
  
  let city: String
  let country: String?
  let longitude: Double
  let latitude: Double
  let weatherDescription: String

  
  // OpenWeatherMap reports temperature in Kelvin,
  // which is why we provide celsius and fahrenheit
  // computed properties.
  private let temp: Double
  var tempCelsius: Double {
    get {
      return temp - 273.15
    }
  }
  var tempFahrenheit: Double {
    get {
      return (temp - 273.15) * 1.8 + 32
    }
  }
  
  init(weatherData:[String: AnyObject]){
    dateAndTime = NSDate(timeIntervalSince1970: weatherData["dt"] as! TimeInterval)
    city = weatherData["name"] as! String
    
    let sysDict = weatherData["sys"] as! [String:AnyObject]
    country = sysDict["country"] as? String
    
    let coordDict = weatherData["coord"] as! [String: AnyObject]
    longitude = coordDict["lon"] as! Double
    latitude = coordDict["lat"] as! Double
    
    let weatherDict = weatherData["weather"]![0] as! [String: AnyObject]
    weatherDescription = weatherDict["description"] as! String
    
    let mainDict = weatherData["main"] as! [String: AnyObject]
    temp = mainDict["temp"] as! Double
  }
}

protocol WeatherGetterDelegate {
  func didGetWeather(weather: Weather)
  func didNotGetWeather(error: Error)
}

class WeatherGetter {
  
  // API Information
  private let openWeawtherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
  private let openWeatherMapBaseKey = "5501843b943c40b64e0e55b1a8003264"
  
  private var delegate : WeatherGetterDelegate
  
  // Initialize a delegate
  init(delegate:WeatherGetterDelegate){
    self.delegate = delegate
  }
  
  // Function to get weather from API
  private func getWeather(_ weatherRequestURL: URL){
    let session = URLSession.shared
    session.configuration.timeoutIntervalForRequest = 3
    
    let dataTask = session.dataTask(with: weatherRequestURL) {
      (data:Data?,response:URLResponse?,error:Error?) in
      if let networkError = error {
        self.delegate.didNotGetWeather(error: networkError)
      }
      else {
        // Convert JSON code to [Strings]
        do {
          let weatherData = try JSONSerialization.jsonObject(
            with: data!,
            options: .mutableContainers)
            as! [String: AnyObject]
          let weather = Weather(weatherData:weatherData)
          self.delegate.didGetWeather(weather: weather)
        }
        catch let jsonError as NSError {
          // An error occurred while trying to convert the data into a Swift dictionary.
          self.delegate.didNotGetWeather(error: jsonError)
          
        }
      }
    }
    dataTask.resume()
  }
  
  func getWeatherByCoordinates(latitude: Double, longitude: Double) {
    let weatherRequestURL = URL(string: "\(openWeawtherMapBaseURL)?APPID=\(openWeatherMapBaseKey)&lat=\(latitude)&lon=\(longitude)")!
    getWeather(weatherRequestURL)
  }
  
  func getWeatherByCity (city: String){
    let weatherRequestURL = URL(string: "\(openWeawtherMapBaseURL)?APPID=\(openWeatherMapBaseKey)&q=\(city)")!
    getWeather(weatherRequestURL)
  }
  
}
