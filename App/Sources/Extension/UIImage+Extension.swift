import UIKit

extension UIImageView {
    func setLogoImage(for stock: Stock) {
        backgroundColor = .clear
        
        if let logoData = stock.logoData, let logo = UIImage(data: logoData) {
            image = logo
        } else {
            image = .init(systemName: "dollarsign.circle", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
            tintColor = .white
        }
    }
}
