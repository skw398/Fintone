import UIKit

final class InfoViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!

    private struct Content {
        let title: String
        let icon: UIImage?
        let action: () -> Void
    }

    private let contents: [Content] = [
        .init(
            title: "Language",
            icon: .init(systemName: "globe"),
            action: {
                if let url: URL = .init(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        ),
        .init(
            title: R.string.localizable.reportFeedbackOrIssues(),
            icon: .init(systemName: "ellipsis.message"),
            action: {
                UIApplication.shared.open(.init(string: "https://docs.google.com/forms/d/e/1FAIpQLSfj1dp5SyGLR0T1F7Wms1KkMWK7ERWOBxYHCHw1lqWJy3jK1g/viewform?usp=sf_link")!)
            }
        ),
        .init(
            title: R.string.localizable.termsOfUseAndPrivacyPolicy(),
            icon: .init(systemName: "doc"),
            action: {
                UIApplication.shared.open(.init(string: "https://skw398.github.io/Fintone/terms_and_privacy_policy.html")!)
            }
        ),
    ]

    private func makeContentConfiguration(with content: Content) -> UIListContentConfiguration {
        var config = UIListContentConfiguration.cell()
        config.text = content.title
        config.textProperties.color = .white
        config.textProperties.font = .systemFont(ofSize: 15, weight: .semibold)
        config.image = content.icon
        config.imageProperties.tintColor = .white
        return config
    }
}

extension InfoViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        contents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell")!
        cell.contentConfiguration = makeContentConfiguration(with: contents[indexPath.row])
        return cell
    }

    func tableView(_: UITableView, heightForRowAt _: IndexPath) -> CGFloat {
        50
    }

    func tableView(_: UITableView, viewForFooterInSection _: Int) -> UIView? {
        LogoView()
    }

    func tableView(_: UITableView, heightForFooterInSection _: Int) -> CGFloat {
        90
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contents[indexPath.row].action()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
