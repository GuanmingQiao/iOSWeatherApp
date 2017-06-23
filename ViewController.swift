//
//  ViewController.swift
//  My App
//
//  Created by Guanming Qiao on 6/15/17.
//  Copyright © 2017 Guanming Qiao. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController,
                      WeatherGetterDelegate,
                      CLLocationManagerDelegate,
                      UITextFieldDelegate
{
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var countryLabel: UILabel!
  @IBOutlet weak var weatherLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  @IBOutlet weak var cityTextField: UITextField!
  @IBOutlet weak var getCityWeatherButton: UIButton!
  
  var weather: WeatherGetter!
  
  @IBOutlet weak var mapView: MKMapView!
  @IBOutlet weak var BackgroundColorView: UIImageView!
  
  
  @IBAction func getCurrentLocationButtonPressed(_ sender: Any) {
    getLocation()
  }
  
  @IBAction func unwindWithSelectedHistory (segue: UIStoryboardSegue){
    if let historyViewController = segue.source as? HistoryViewController, let selectedCity = historyViewController.selectedCity {
      weather.getWeatherByCity(city: selectedCity.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlUserAllowed)!)
    }
  }
  
  @IBAction func cancelToPlayersViewController(segue:UIStoryboardSegue) {
  }
  
  @IBAction func coordinatesWithLongPressOnMap (sender : UILongPressGestureRecognizer){
    if sender.state != UIGestureRecognizerState.began{return}
    let touchLocation = sender.location(in: mapView)
    let coordinates = mapView.convert(touchLocation, toCoordinateFrom: mapView)
    weather.getWeatherByCoordinates(latitude: coordinates.latitude, longitude: coordinates.longitude)
    addToHisByCoord (coordinates.latitude, coordinates.longitude)
  }
  
  let locationManager = CLLocationManager()

  // MARK: -
  
  override func viewDidLoad() {
    super.viewDidLoad()
    weather = WeatherGetter(delegate: self)
    
    // Initialize UI
    // -------------
    cityLabel.text = "simple weather"
    countryLabel.text = "Unknown Country"
    weatherLabel.text = "Unkown Weather"
    temperatureLabel.text = "Unknown"
    BackgroundColorView.image = self.imageForShaking(0)
   
    cityTextField.text = ""
    cityTextField.placeholder = "Enter city name"
    cityTextField.delegate = self
    cityTextField.enablesReturnKeyAutomatically = true
    getCityWeatherButton.isEnabled = false
    getLocation()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  // MARK: - Button events
  // ---------------------
  
  
  
  @IBAction func getWeatherForCityButtonTapped(sender: UIButton) {
    guard let text = cityTextField.text, !text.isEmpty else {
      return
    }
    weather.getWeatherByCity(city: cityTextField.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlUserAllowed)!)
    searchData.append(self.cityLabel.text!);
    defaults.set(searchData, forKey: "historyData")
  }
  
  
  func didGetWeather(weather: Weather) {
    DispatchQueue.main.async() {
      self.cityLabel.text = weather.city
      self.countryLabel.text = weather.country
      self.weatherLabel.text = weather.weatherDescription
      self.temperatureLabel.text = "\(Int(round(weather.tempCelsius)))°"
      let cityLocation = CLLocationCoordinate2DMake(weather.latitude, weather.longitude)
      let dropPin = MKPointAnnotation()
      dropPin.coordinate = cityLocation
      dropPin.title = weather.city
      self.mapView.addAnnotation(dropPin)
      
    }
  }
  
  func didNotGetWeather(error: Error) {
    DispatchQueue.main.async {
      let alert = UIAlertView()
      alert.title = "A Mistake!"
      alert.message = "The weather service isn't responding."
    }
    print("didNotGetWeather error: \(error)")
  }
  
  func getLocation(){
    guard CLLocationManager.locationServicesEnabled() else {
      print("Location Service Disabled")
      return
    }
    let authStatus = CLLocationManager.authorizationStatus()
    guard authStatus == .authorizedWhenInUse else {
      switch authStatus {
      case .denied, .restricted:
        print("This app is not authorized to use your location")
        
      case .notDetermined:
        locationManager.requestWhenInUseAuthorization()
      default:
        print("Oops! Shouldn't have come this far.")
      }
      return
    }
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.requestLocation()
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let newLocation = locations.last!
    weather.getWeatherByCoordinates(latitude: newLocation.coordinate.latitude, longitude: newLocation.coordinate.longitude)
  }
  
  // This is called if:
  // - the location manager is updating, and
  // - it WASN'T able to get the user's location.
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
    print("Error: \(error)")
  }

  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    let currentText = textField.text ?? ""
    let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
    
    getCityWeatherButton.isEnabled = prospectiveText.characters.count > 0
    print("Count: \(prospectiveText.characters.count)")
    return true
  }
  
  func textFieldShouldClear(_ textField: UITextField) -> Bool {
    // Even though pressing the clear button clears the text field,
    // this line is necessary. I'll explain in a later blog post.
    textField.text = ""
    
    getCityWeatherButton.isEnabled = false
    return true
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    view.endEditing(true)
  }
  
  func addToHisByCoord (_ long:Double, _ lat: Double){
    
    searchData.append(self.cityLabel.text!);
    defaults.set(searchData, forKey: "historyData")
  }
  
  func imageForShaking(_ number:Int) -> UIImage? {
    let imageName = "\(number)Shakes"
    return UIImage(named: imageName)
  }
  
  override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      self.BackgroundColorView.image = imageForShaking(Int(arc4random()) % 2)
    }
  }
}

