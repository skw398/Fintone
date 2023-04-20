import Foundation

@MainActor protocol PortfolioViewPresenterOutput: AnyObject {
    func showLaunchView()
    func hideLaunchView()
    func updateLaunchViewForLoadFailureState(title: String)
    func startIndicator()
    func stopIndicator()
    func scrollToTop()
    func playWarningNotificationFeedback()
    func playSuccessNotificationFeedback()
    func updateView()
    func updatePortfolioNameButton()
    func toggleHelpViewVisibility()
    func presentInputAmountViewController(with: Stock)
    func presentStockSearchViewController()
    func presentSortViewController()
    func presentPortfolioListView()
    func presentInfoView()
    func showAlert(title: String, message: String?)
    func showAlertOnPresentedViewController(title: String)
    func showDeleteStockAlert(title: String, message: String, deleteActionHandler: @escaping () -> Void)
    func showPortfolioNameInputAlert(title: String, doneActionHandler: @escaping (_ name: String) -> Void)
}
