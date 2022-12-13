//
//  Read_MeApp.swift
//  Read Me
//
//  Created by Ujwal Chilla on 2/8/22.
//

import SwiftUI
import Firebase

@main
struct Read_MeApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(didCompleteLoginProcess: {
                
            })
            .environmentObject(SignUpViewModel())
        }
    }
}
