//
//  ChatUser.swift
//  Read Me
//
//  Created by Ujwal Chilla on 3/13/22.
//

import Foundation

struct ChatUser {
    
    let uid, email, profileImageUrl: String
    
    init(data: [String: Any]) {
        
        self.uid = data["uid"] as? String ?? ""
        self.email = data["email"] as? String ?? ""
        self.profileImageUrl = data["profileImageUrl"] as? String ?? ""
        
    }
    
}
