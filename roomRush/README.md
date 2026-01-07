# roomRush
![Platform](https://img.shields.io/badge/Platform-iOS-lightgrey)
![iOS](https://img.shields.io/badge/iOS-18.6%2B-blue)
![License](https://img.shields.io/badge/License-Educational-orange)
## About the app
roomRush is a native iOS application designed for travelers looking for last-minute hotel deals. Built with SwiftUI and the Amadeus API, it helps users discover, filter, and save hotel deals in real-time, with full offline support and location-based searching.

## Requirements

* **iOS Target:** iOS 18.6 or higher
* **Device:** iPhone (Optimized for iPhone layout)
* **IDE:** Xcode (Latest version compatible with iOS 18.6)

## Getting Started
### 1. Clone the repository

Open xcode and clone the git repository or open your terminal and run the following command:

```bash
git clone [https://github.com/LunaDHeere/roomRush](https://github.com/LunaDHeere/roomRush)
cd roomRush 
```

### 2. Install Dependencies
Open the project in Xcode. This project uses Swift Package Manager so the packages should resolve automatically. If they do not, go to 
File > Packages > Resolve Package Versions

### 3. Setup Firebase
This app relies on and requires Firebase for authentication and db management.
1. Go to the Firebase console
2. Create a new project
3. Add an iOS app to your project using your Bundle ID
4. Download the GoogleService-Info.plist file provided by Firebase.
5. Drag and drop this file into the root of the Xcode project navigator

**!!IMPORTANT!! Ensure the GoogleService-Info.plist is listed in the .gitignore file. DO NOT commit this file to public version control.**

6. Enable the following services in the Firebase Console:
- Authentication: Enable the Email/Password sign-in providers
- Firebase Database

### 4. API Configuration (Amadeus)

This app uses the Amadeus API for hotel data.
1. Create a free developer account at Amadeus for Developers.
2. Create a new app in your own Amadeus workspace to generate your API Key and API Secret
3. Create a file named Secrets.xcconfig in the root of the project in Xcode.
4. Add your API keys in the following format:

AMADEUS_API_KEY = YOUR_API_KEY
AMADEUS_API_SECRET = YOUR_API_SECRET

5. Ensure these values are referenced in your Info.plist file so the app can read them at runtime.

**!!IMPORTANT!! Ensure the Secrets.xcconfig file is listed in the .gitignore file. DO NOT commit this file to public version control.**

## Features and Assignment Requirements
*>Note: This section is specifically for the project evaluator to verify that all assignment requirements have been met. If you are just browsing the repo, feel free to skip this part!*
### 1. Webservice (API)

The app integrates with the Amadeus Hotel Search API to fetch real-time hotel data based on geolocation.

implementation: See APIManager.swift. This file handles OAuth2 token generation and secure API requests.

### 2. MVVM Architecture
This project strictly follows the Model-View-ViewModel design pattern to seperate logic from the UI.

Models:
* Deal.swift
* User.swift
* AmadeusModels.swift

Views:
* HomeView
* DealsMapView
* FavouritesView
* ProfileView
* LoginView

ViewModels:
* HomeViewModel
* AuthViewModel

### 3. Offline Fallback
The app is fully functional without an internet connection

implementation: HomeViewModel detects API failures or network issues. if the API fails, it catches the error and automatically loads cached data from Core Data using loadFromCoreData()

User Feedback: The NetworkMonitor.swift file triggers an alert banner in ContentView to inform the user they are viewing cached data.

### 4. Location Usage
The app utilizes Core Location and MapKit to enhance the user experience.

Implementation: LocationManager.swift requests and handles user GPS coordinates

Usage:
* HomeView: sorts and fetches deals based on the user's current city
* DealsMapView: Displays deals as markers on a map.
* DealCardView: calculates and displays the distance from the user to each hotel.

### 5. Local Storage (Core Data)
Data is persisted locally using Core Data

Implementation: Persistence.swift manages the Core Data stack.

### 6. Multiple Screens & Input
The app features tabs to navigate the app with multiple interactive screens.

Screens:
* Home
* Map
* Favourites
* Profile

Input: Searchbar on the map to view hotels in different cities, toggles for settings (km/miles) and forms for User Authentication.

### 7. First Load Logic
On the very first launch, the app automatically determines the user's location (by first asking permission of course), fetches live data from the API and populates the local database.

### 8. Last Update Indicator
The user is informed about how recent the data is.

Implementation: A timestamp is saved to UserDefaults upon every successful fetch. A custom Date extension then converts this into a user friendly string (for example: "Updated 5 minutes ago") which is displayed in the HomeView header.

### 9. Manual Refresh
Users can force a data update.

Implementation: The HomeView supports the standard "Pull-to-Refresh" gesture (.refreshable) which triggers viewModel.manualRefresh()

### 10. Visualization
Data is presented in multiple visual formats.

* List: Detailed cards with images, badges and prices
* Map: Pins on a MapKit view
* Profile: User statistics and settings toggles

### 11. External Libraries
The project integrates standardized external dependencies via Swift Package Manager.
* Kingfisher: used for image loading.
* Firebase (Auth & Firestore): used for secure user authentication and certain user settings and favourites.

## License
This project is created for educational purposes only. It is not intended for commercial use.
