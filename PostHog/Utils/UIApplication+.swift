//
//  UIApplication+.swift
//  PostHog
//
//  Created by Yiannis Josephides on 11/11/2024.
//

#if os(iOS) || os(tvOS) || os(visionOS)
    import UIKit

    extension UIApplication {
        /// `UIApplication.shared` without the direct API reference forbidden by
        /// `APPLICATION_EXTENSION_API_ONLY`; nil in app extension processes.
        static var sharedIfAvailable: UIApplication? {
            guard !isExtension() else { return nil }
            return perform(NSSelectorFromString("sharedApplication"))?.takeUnretainedValue() as? UIApplication
        }

        static func getCurrentWindow(filterForegrounded: Bool = true) -> UIWindow? {
            guard let sharedApplication = sharedIfAvailable else { return nil }
            let windowScenes = sharedApplication
                .connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .filter {
                    !filterForegrounded || $0.activationState == .foregroundActive
                }

            for scene in windowScenes {
                // attempt to retrieve directly from UIWindowScene
                if #available(iOS 15.0, tvOS 15.0, *) {
                    if let keyWindow = scene.keyWindow {
                        return keyWindow
                    }
                } else {
                    // check scene.windows.isKeyWindow
                    for window in scene.windows where window.isKeyWindow {
                        return window
                    }
                }

                // check scene.delegate.window property
                let sceneDelegate = scene.delegate as? UIWindowSceneDelegate
                if let target = sceneDelegate, let window = target.window {
                    return window
                }
            }

            return nil
        }
    }
#endif
