
## Dependencies

Here is a list of the significant dependencies and their role in this project.
- [Google Maps](https://pub.dev/packages/google_maps_flutter) - used for map underlay
- [Google Maps Places](https://pub.dev/packages/flutter_google_places_hoc081098) - searching for locations
- [ShowcaseView](https://pub.dev/packages/showcaseview) - application tutorial showcasing it's features
- [SlidingUpPanel](https://pub.dev/packages/sliding_up_panel) - widget used for panel with aircraft list or detail that slides up from the bottom of the screen
- [Flutter Bloc](https://pub.dev/packages/flutter_bloc) - business logic components
- [csv](https://pub.dev/packages/csv) - for exporting aircraft data in CSV format
- [Share Plus](https://pub.dev/packages/share_plus) - sharing exported CSV using native share dialog
- [Shared Preferences](https://pub.dev/packages/shared_preferences) - persistent storage to save user settings

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
