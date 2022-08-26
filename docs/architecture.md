# Code Architecture

## Directory structure

The project hierarchy is described here. 

* 📂 `assets` – directory containing configuration files for Google Maps, application images, icons, and fonts.
* 📂 `docs` – project documentation.
* 📂 `lib` – source codes.

All sources are present in the 📂 `lib` folder It has the following structure.

* 📂 `blocs` – Source code of business logic components according to BLoC pattern, utilizing the BLoC library.
* 📂 `constants` – Files with global constants. Colors, themes, and sizes are defined here.
* 📂 `utils` – utility functions to read API keys, logging, etc.
* 📂 `widgets` – Folder with source code of Flutter widgets, organized in features.

Finally, the structure of 📂 `widgets` folder. Each folder represents a feature or part of the application and contains widgets implementing this feature.

* 📂 `app` – Root widget of the application
* 📂 `mainpage` – Map page.
* 📂 `preferences` – Page with application settings.
* 📂 `showcase` – Application tutorial, using the [ShowcaseView](https://pub.dev/packages/showcaseview) package.
* 📂 `sliders` – Panel that slides up from the bottom and contains aircraft list or detail, using the [SlidingUpPanel](https://pub.dev/packages/sliding_up_panel).
* 📂 `toolbars` – Bottom and right toolbar that is shown on the map.
