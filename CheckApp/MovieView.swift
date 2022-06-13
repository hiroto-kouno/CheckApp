//
//  MovieView.swift
//  CheckApp
//
//  Created by 河野 裕門 on 2022/06/13.
//

import UIKit
import AVFoundation

class MovieView: UIView {
    // MARK: - Private
    var player: AVPlayer? {
        get { return playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
