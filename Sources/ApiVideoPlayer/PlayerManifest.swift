//
//  File.swift
//  
//
//  Created by Romain Petit on 22/03/2022.
//

import Foundation
public struct PlayerManifest: Codable{
    var id: String
    var title: String
    var video: Video
    var panoramic : Bool?
    var live: Bool?
    // var theme: [Any]
}
