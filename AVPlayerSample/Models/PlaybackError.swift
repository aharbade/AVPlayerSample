//
//  PlaybackError.swift
//  AVPlayerSample
//
//  Created by Anup Harbade on 10/15/22.
//

import Foundation


struct PlaybackError: Error {

    enum PlaybackErrorType {
        case invalidURL
    }
    
    let type: PlaybackErrorType
    let message: String

    init(type: PlaybackError.PlaybackErrorType,
         message: String) {
        self.type = type
        self.message = message
    }
    
}
