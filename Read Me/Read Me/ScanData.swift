//
//  ScanData.swift
//  Read Me
//
//  Created by Ujwal Chilla on 2/8/22.
//

import Foundation


struct ScanData:Identifiable {
    var id = UUID()
    let content:String
    let nameOfText:String
    
    init(content:String, nameOfText:String) {
        self.content = content
        self.nameOfText = nameOfText
    }
}
