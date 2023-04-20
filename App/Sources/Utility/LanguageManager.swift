import Foundation

struct LanguageManager {
    static var preferredLanguagesIsEn: Bool {
        let languages = NSLocale.preferredLanguages
        if let type = languages.first {
            return type.contains("en")
        }
        return true
    }
}
