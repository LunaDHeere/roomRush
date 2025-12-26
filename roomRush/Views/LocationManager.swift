import CoreLocation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @Published var userLocation: CLLocation?
    @Published var city: String = ""
    @Published var isLoading = false // Add this line
    
    override init() {
        super.init()
        manager.delegate = self
        // Set accuracy to 'NearestTenMeters' for faster response on real devices
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
    }
    
    func requestLocation() {
        isLoading = true // Start loading
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()

    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            self.userLocation = location
            
            // Reverse geocode to get the city name
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                DispatchQueue.main.async {
                    self.isLoading = false // Stop the loading spinner
                    if let placemark = placemarks?.first {
                        self.city = placemark.locality ?? "Unknown"
                    }
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            print("Location error: \(error.localizedDescription)")
        }
    }
}
