<p align="center">
  <img src="assets/images/icon.png" width="96" />
</p>
<h1 align="center">Drone Scanner</h1>

Drone Scanner is an application for scanning surroundings for data broadcasted by Unmanned Aerial Vehicle, such as identification and location. It gathers the data and presents them to the user on a map.

Drone Scanner can track all the nearby flights over Direct Remote ID standards. Browse real-time data about drones on a detailed map highlighting specific flying space zones. 

The application is inspired by [OpenDroneID Android receiver application](https://github.com/opendroneid/receiver-android). In contrast to the OpenDroneID application, DroneScanner is multiplatform. DroneScanner offers refreshed design as well as more features, such as drone labeling and tracking, or exporting data to CSV format.

For a more in-depth description, refer to the [documentation](./docs/) folder.

## Documentation Contents

* [Application Features and Regulatory Compliance](./docs/features.md)
    * Description of application features and explanations of Remote ID regulations 
* [Code Architecture](./docs/architecture.md)
    * Declares the directory structure and overall architecture
* [Project Setup and Building](./docs/build.md)
    * Instructions on how to set up and build the project, information about used dependencies
* [Resources](./docs/resources.md)
    * Resources for developers

## Google Maps

The application uses [Google Maps Platform](https://cloud.google.com/maps-platform/). In order for it to work, you need to obtain your API key. In [Google Developers Console](https://console.cloud.google.com/), enable API for each platform. To enable Google Maps for Android, select "Maps SDK for Android" in the "Additional APIs" section, then select "ENABLE". To enable Google Maps for iOS, select "Maps SDK for iOS" in the "Additional APIs" section, then select "ENABLE".

For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).


In the project folder, duplicate files *android/app/src/main/AndroidManifest.example.xml* and *ios/Runner/AppDelegate.example.swift*, remove the *.example* suffix. Paste your key to both files. Then create a file *google_map_api.json* in *assets/config*, see the example file to see the required structure.

The files which contain Google Maps API are added to .gitignore, so your key will not be accidentally committed.

> 💡 _This README is a work-in-progress and will be soon updated with all necessary information about the application architecture, ways to build the project, and ways to contribute to this project._

---

## Screenshots


| Map View       | Aircraft Detail           |
| ------------- |:-------------:|
|<img src="/assets/screenshots/map_page.jpg" width="200"/>| <img src="/assets/screenshots/detail.jpg" width="200"/> |

| Animated GIF      |
| ------------- |
|<img src="/assets/screenshots/app-usage.gif" width="200"/>|


---

© 2022, [Dronetag s.r.o.](https://dronetag.cz)
