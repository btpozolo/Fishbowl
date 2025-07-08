import SwiftUI
import UIKit

struct OrientationModifier: ViewModifier {
    let orientation: UIInterfaceOrientationMask
    func body(content: Content) -> some View {
        content
            .onAppear {
                // OrientationManager.shared.setOrientation(orientation) // Removed as per edit hint
            }
            .onDisappear {
                // OrientationManager.shared.setOrientation(.portrait) // Removed as per edit hint
            }
    }
}

extension View {
    func allowOrientation(_ orientation: UIInterfaceOrientationMask) -> some View {
        self.modifier(OrientationModifier(orientation: orientation))
    }
}

// In your AppDelegate or SceneDelegate, override supportedInterfaceOrientationsFor window:
// func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//     return OrientationManager.orientationMask // Removed as per edit hint
// } 

class OrientationManager {
    static let shared = OrientationManager()

    func lock(to orientation: UIInterfaceOrientationMask) {
        AppDelegate.orientationLock = orientation

        // Force the device to rotate to the specified orientation
        if orientation == .portrait {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        } else if orientation == .landscapeLeft {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        } else if orientation == .landscapeRight {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }

    func unlock() {
        // Reset orientation lock to allow all directions
        AppDelegate.orientationLock = .all
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.setNeedsUpdateOfSupportedInterfaceOrientations()
        }
    }
} 