import Foundation

public final class ApiVideoPlayerResources {
    public static let resourceBundle: Bundle = {
        let candidates = [
            // Bundle should be present here when the package is linked into an App.
            Bundle.main.resourceURL,

            // Bundle should be present here when the package is linked into a framework.
            Bundle(for: ApiVideoPlayerResources.self).resourceURL,
        ]

        let bundleName = "ApiVideoPlayer_ApiVideoPlayer"

        for candidate in candidates {
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }

        // Return whatever bundle this code is in as a last resort.
        return Bundle(for: ApiVideoPlayerResources.self)
    }()
}
