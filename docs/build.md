## Google Maps

The application uses Google Maps API. In order for it to work, you need to obtain your API key. Paste your key to *android/app/src/main/AndroidManifest.xml* and *ios/Runner/AppDelegate.swift*. Create file *google_map_api.json* in *assets/config*, see example file to see the required structure.

The files which contain Google Maps API are added to .gitignore, so your key will not be accidentally commited. If you wish to commit changes in these files, use 'git add -f file'.
