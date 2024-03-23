import Foundation
import os.log

final class ImageFeedLog {
    private let log = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "ImageFeed")

    func logError(_ message: StaticString) {
        os_log(message, log: log, type: .error)
    }
}
