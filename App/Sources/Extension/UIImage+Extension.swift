import UIKit

extension UIImageView {
    func setLogoImage(for stock: Stock) {
        if stock.symbol == "AAPL" {
            contentMode = .center
            image = .init(systemName: "applelogo", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
            return
        }

        if let logoData = stock.logoData, let logo = UIImage(data: logoData) {
            contentMode = .scaleAspectFit
            image = logo
            return
        }

        contentMode = .center
        image = .init(systemName: "dollarsign.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
    }
}
