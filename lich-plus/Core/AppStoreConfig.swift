import Foundation

enum AppStoreConfig {
    static let appID: String = "6756505880"

    static var appStoreURL: URL {
        URL(string: "https://apps.apple.com/app/id\(appID)")!
    }
}
