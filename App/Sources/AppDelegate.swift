import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var lastActiveDate: Date?

    private func instantiateHomeViewController() -> UINavigationController {
        let nav = R.storyboard.portfolioViewController.instantiateInitialViewController()!
        let vc = nav.topViewController as! PortfolioViewController
        vc.inject(presenter: PortfolioViewPresenter(
            view: vc, portfolioService: ServiceDependencies.portfolioService
        ))
        return nav
    }

    func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = instantiateHomeViewController()
        window?.makeKeyAndVisible()
        return true
    }

    func applicationDidEnterBackground(_: UIApplication) {
        lastActiveDate = Date()
    }

    func applicationWillEnterForeground(_: UIApplication) {
        guard let lastActiveDate = lastActiveDate else { return }
        let currentTime = Date()
        let timeInterval = currentTime.timeIntervalSince(lastActiveDate)
        if timeInterval > 60 {
            if let window { window.rootViewController = instantiateHomeViewController() }
        }
    }
}
