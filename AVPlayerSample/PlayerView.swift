//
//  PlayerView.swift
//  AVPlayerSample
//
//  Created by Anup Harbade on 10/15/22.
//

import UIKit
import AVFoundation

class PlayerView: UIView {

    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    override var layer: AVPlayerLayer {
        super.layer as! AVPlayerLayer
    }

}
