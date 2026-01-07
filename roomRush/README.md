# roomRush

## About the app
## Requirements
## Getting Started
### 1. Clone the repository

Open xcode and clone the git repository or open your terminal and run the following command:

```bash
git clone [https://github.com/LunaDHeere/roomRush](https://github.com/LunaDHeere/roomRush)
cd roomRush```

### 2. Install Dependencies
Open the project in Xcode. This project uses Swift Package Manager so the packages should resolve automatically. If they do not, go to 
File > Packages > Resolve Package Versions


//explanation of what the app is about here
// features / requirements
// Requirements

- ios 18.6
- iphone for best results
// getting started

// 1. cloning the repository
// 2. installing the dependencies
// 3. firebase setup

create a firebase project at https://console.firebase.google.com
add an ios app to the project
download the provided GoogleService-info.plist and add it to the Xcode project. do NOT commit this file.
the required firebase services for this app are:
- firebase authentication
- firestore database

// 4. API configuration

This app uses a free version of an external hotel API called Amadeus.
create a free account on amadeus and follow their steps. afterwards, create a 
secrets file and include your API key and API secrets. the setup should look like this:
AMADEUS_API_KEY = YOUR_API_KEY
AMADEUS_API_SECRET = YOUR_API_SECRET

include the api key and secret into your info.plist file. 
DO NOT COMMIT THE SECRETS FILE
// screenshot here

//5. License
this project is for educational purposes only.

