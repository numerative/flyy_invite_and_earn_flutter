import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    var navigationController = UINavigationController() //1. Declare an instance of UINavigationController
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        //2. Place the following 6 lines of code.
        let flutterViewController: FlutterViewController = window?.rootViewController as! FlutterViewController
        self.navigationController = UINavigationController(rootViewController: flutterViewController);
        self.navigationController.setNavigationBarHidden(true, animated: false)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window.rootViewController = self.navigationController
        self.window.makeKeyAndVisible()
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
