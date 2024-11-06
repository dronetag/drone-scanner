import UIKit
import Flutter
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    guard let secretsFilePath = Bundle.main.path(forResource: "Secrets", ofType: "plist") else {
        NSLog("Secrets.plist file was not found, make sure you've copied the Secrets.example.plist")
        exit(1)
    }

    let secrets = NSDictionary(contentsOfFile: secretsFilePath)

    guard let googleMapsKey = secrets?["GoogleMapsAPIKey"] else {
        NSLog("There is no GoogleMapsAPIKey key in Secrets.plist")
        exit(1)
    }

    GMSServices.provideAPIKey(googleMapsKey as! String)
    GeneratedPluginRegistrant.register(with: self)

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
