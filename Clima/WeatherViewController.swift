import UIKit
import CoreLocation// library to enable location to our app
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
//CLLocationManagerDelegate is the method use to recieve location from the CoreLocation library
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    /***Get your own App ID at https://openweathermap.org/appid ****/
    

    //TODO: Declare instance variables here
    let locationManager=CLLocationManager()
    let weatherDataModel=WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
    locationManager.delegate=self
    locationManager.desiredAccuracy=kCLLocationAccuracyHundredMeters
    locationManager.requestWhenInUseAuthorization()
    locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url:String, parameters:[String:String]){
        Alamofire.request(url, method: .get, parameters : parameters).responseJSON{
            response in
            if response.result.isSuccess{
                print("Sucess Got the data ! ")
                
                let weatherJSON:JSON=JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
                print(weatherJSON)
                
            }
            else{
                print("Problem with Connection ! \(String(describing: response.result.error)) ")
                self.cityLabel.text = "Connection Issue ! "
            }
        }
    }
    

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json:JSON){
        
        if let tempResult = json["main"]["temp"].double {
        
        weatherDataModel.temperature = Int(tempResult - 273.15)
        
        weatherDataModel.city=json["name"].stringValue
        
        weatherDataModel.condition=json["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName=weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
            updateUIWeatherData()
            
        }
        else{
           cityLabel.text="Unavailable ! "
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWeatherData(){
        
        cityLabel.text=weatherDataModel.city
        temperatureLabel.text="\(weatherDataModel.temperature)° "
        weatherIcon.image=UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location=locations[locations.count-1]
        
        if location.horizontalAccuracy>0{
            
            locationManager.stopUpdatingLocation()
            
            print("Longitude \(location.coordinate.longitude), Latitude \(location.coordinate.latitude)")
            
            let latitude=String(location.coordinate.latitude)
            let longitude=String(location.coordinate.longitude)
            
            let params:[String:String]=["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url : WEATHER_URL, parameters : params)
        }
        
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text="LOcation Unavailable ! "
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func userEnteredNewCityName(city: String) {
        let params:[String:String]=["q":city, "appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName"{
            let destinationVC=segue.destination as! ChangeCityViewController
            destinationVC.delegate=self 
        }
    }
    
    
    
}


