//
//  NounsOnAPhoneApp.swift
//  NounsOnAPhone
//
//  Created by Blake Pozolo on 6/25/25.
//

import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

@main
struct NounsOnAPhoneApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .accentColor(.blue)
                .preferredColorScheme(.light)
        }
    }
}
