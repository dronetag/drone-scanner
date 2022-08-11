
## Dependencies

- GoogleMaps [pub.dev]() - used for map underlay
- ShowcaseView

## Google Maps

The application uses [https://mapsplatform.google.com](Google Maps Platform). In order for it to work, you need to obtain your [https://developers.google.com/maps/documentation/javascript/get-api-key](API key). In Google Maps API console, allow android and ios API.

In the project folder, duplicate files *android/app/src/main/AndroidManifest.example.xml * and *ios/Runner/AppDelegate.example.swift*, remove the *.example* suffix. Paste your key to both files. Then create a file *google_map_api.json* in *assets/config*, see example file to see the required structure.

The files which contain Google Maps API are added to .gitignore, so your key will not be accidentally commited. If you wish to commit changes in these files, use 'git add -f file'.

## Configuration Steps
1. Cloning the repository:

```
$ git clone https://github.com/dronetag/drone-scanner.git
```

2. Open the project and install dependencies (using terminal):

```
$ cd drone-scanner
$ flutter pub get
```
This installs all the required dependencies.


4. Now run the app on your connected device (using terminal):

`$ flutter run`
