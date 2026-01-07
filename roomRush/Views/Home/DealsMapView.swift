import SwiftUI
import MapKit

struct DealsMapView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject private var homeViewModel : HomeViewModel
    @EnvironmentObject var locationManager : LocationManager
    
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.0259, longitude: 4.4776),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    ))
    
    @State private var searchText = ""
    @State private var isSearching = false
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Map(position: $cameraPosition) {
                    UserAnnotation()
                    
                    ForEach(homeViewModel.allDeals) { deal in
                        Marker(deal.title, coordinate: CLLocationCoordinate2D(latitude: deal.latitude, longitude: deal.longitude))
                            .tint(.blue)
                    }
                }
                
                searchBarOverlay
                VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: goToUserLocation) {
                        Image(systemName: "location.fill")
                            .font(.title2)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 30) // Push up slightly to avoid TabBar
                }
            }
        }
            .navigationTitle("Explore")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func goToUserLocation() {
            guard let location = locationManager.userLocation else {
                print("User location not available yet")
                locationManager.requestLocation() // Try to kickstart it if missing
                return
            }
            
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                ))
            }
            
            Task {
                print("Refreshing and fetching deals for current location")
                let cityName = locationManager.city.isEmpty ? "Current Location" : locationManager.city
                
                await homeViewModel.fetchDealsFromAPI(
                    lat: location.coordinate.latitude,
                    lon: location.coordinate.longitude,
                    city: cityName
                )
            }
        }
    
    private var searchBarOverlay: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass").foregroundColor(.gray)
                TextField("Search for a city", text: $searchText)
                    .onSubmit { performSearch() }
                    .foregroundColor(.black)
                
                if !searchText.isEmpty {
                    Button { searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.gray)
                    }
                    .foregroundColor(.black)
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
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        
        MKLocalSearch(request: searchRequest).start { response, _ in
            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                isSearching = false
                return
            }
            
            withAnimation {
                cameraPosition = .region(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)))
            }
            
            let cityName = response?.mapItems.first?.name ?? "Explore"
            Task {
                await homeViewModel.fetchDealsFromAPI(lat: coordinate.latitude, lon: coordinate.longitude, city: cityName)
                isSearching = false
            }
        }
    }
    
    private func loadInitialDeals() {
        let lat = locationManager.userLocation?.coordinate.latitude ?? 51.0259
        let lon = locationManager.userLocation?.coordinate.longitude ?? 4.4776
        let city = authViewModel.currentUser?.city ?? "Brussels"
        Task { await homeViewModel.fetchDealsFromAPI(lat: lat, lon: lon, city: city) }
    }
}
