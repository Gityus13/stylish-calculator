import AppKit
import SwiftUI

@main
struct StylishCalcApp: App {
    var body: some Scene {
        WindowGroup {
            CalculatorView()
                .frame(minWidth: 380, minHeight: 600)
        }
    }
}