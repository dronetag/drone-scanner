
## Dependencies

- [Google Maps](https://pub.dev/packages/google_maps_flutter) - used for map underlay
- [Google Maps Places](https://pub.dev/packages/flutter_google_places_hoc081098) - searching for locations
- [ShowcaseView](https://pub.dev/packages/showcaseview) - application tutorial showcasing it's features
- [SlidingUpPanel](https://pub.dev/packages/sliding_up_panel) - widget used for panel with aircraft list or detail that slides up from the bottom of the screen
- [Flutter Bloc](https://pub.dev/packages/flutter_bloc) - business logic components
- [Permission Handler](https://pub.dev/packages/permission_handler) - managing system permissions
- [csv](https://pub.dev/packages/csv) - for exporting aircraft data in CSV format
- [Share Plus](https://pub.dev/packages/share_plus) - sharing exported CSV using native share dialog
- [Shared Preferences](https://pub.dev/packages/shared_preferences) - persistent storage to save user settings

## Google Maps

The application uses [Google Maps Platform](https://cloud.google.com/maps-platform/). In order for it to work, you need to obtain your API key. In [Google Developers Console](https://console.cloud.google.com/), enable API for each platform. To enable Google Maps for Android, select "Maps SDK for Android" in the "Additional APIs" section, then select "ENABLE". To enable Google Maps for iOS, select "Maps SDK for iOS" in the "Additional APIs" section, then select "ENABLE".

For more details, see [Getting started with Google Maps Platform](https://developers.google.com/maps/gmp-get-started).


In the project folder, duplicate files *android/app/src/main/AndroidManifest.example.xml* and *ios/Runner/AppDelegate.example.swift*, remove the *.example* suffix. Paste your key to both files. Then create a file *google_map_api.json* in *assets/config*, see the example file to see the required structure.

The files which contain Google Maps API are added to .gitignore, so your key will not be accidentally committed.

## Configuration Steps
1. Cloning the repository:

```
$ git clone https://github.com/dronetag/drone-scanner.git
```

2. Open the project and install dependencies (using a terminal):

```
$ cd drone-scanner
$ flutter pub get
```
This installs all the required dependencies.


4. Now run the app on your connected device (using terminal):

`$ flutter run`
