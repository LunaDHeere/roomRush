

import SwiftUI
import MapKit
import Combine

struct DealsMapView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var homeViewModel = HomeViewModel()
    
    @StateObject var locationManager = LocationManager()
    
    // Default to Mechelen, but this updates as the user searches
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.0259, longitude: 4.4776),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                // MARK: - The Map
                Map(position: $cameraPosition) {
                    // Show User Location
                    UserAnnotation()
                    
                    // Show Hotel Pins from Amadeus
                    ForEach(homeViewModel.deals) { deal in
                        Marker(deal.title, coordinate: CLLocationCoordinate2D(latitude: deal.latitude, longitude: deal.longitude))
                            .tint(.blue)
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                
                // MARK: - Search Bar Overlay
                VStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search for a city (e.g. Brussels)", text: $searchText)
                            .onSubmit {
                                performSearch()
                            }
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .padding()
                    
                    if isSearching {
                        ProgressView()
                            .padding()
                            .background(.white.opacity(0.8))
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Initially load deals for current location
                loadInitialDeals()
            }
        }
    }
    
    // MARK: - Search Logic
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                isSearching = false
                return
            }
            
            // 1. Move the camera to the new city
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
            
            // 2. Fetch real Amadeus hotels for this new location!
            let cityName = response?.mapItems.first?.name ?? authViewModel.currentUser?.city ?? "Explore"
            homeViewModel.testAmadeus(lat: coordinate.latitude, lon: coordinate.longitude, userCity: cityName)
            
            isSearching = false
        }
    }
    
    private func loadInitialDeals() {
        // If we have GPS, use it, otherwise use Mechelen
        let lat = locationManager.userLocation?.coordinate.latitude ?? 51.0259
        let lon = locationManager.userLocation?.coordinate.longitude ?? 4.4776
        let cityName = authViewModel.currentUser?.city ?? "Brussels"
        homeViewModel.testAmadeus(lat: lat, lon: lon, userCity: cityName)
    }
}
