//
//  ViewController.swift
//  Quest
//
//  Created by 西島志織 on 2018/06/03.
//  Copyright © 2018年 西島志織. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate {

    var audioPlayer:AVAudioPlayer!
    
    @IBAction func buttonTapped(sender : AnyObject) {
        performSegue(withIdentifier: "toViewController2",sender: nil)
        
    }
    
    @IBOutlet weak var imageView: UIImageView!
    // Segue 準備
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "toViewController2") {
            audioPlayer.stop()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // バンドルした画像ファイルを読み込み
        let image = UIImage(named: "titlelogo")
        imageView.image = image

        // 再生する audio ファイルのパスを取得
        let audioPath = Bundle.main.path(forResource: "Overture", ofType:"mp3")!
        let audioUrl = URL(fileURLWithPath: audioPath)
        // auido を再生するプレイヤーを作成する
        var audioError:NSError?
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioUrl)
        } catch let error as NSError {
            audioError = error
            audioPlayer = nil
        }
        // エラーが起きたとき
        if let error = audioError {
            print("Error \(error.localizedDescription)")
        }
        // ループさせる
        audioPlayer.numberOfLoops = -1
        audioPlayer.delegate = self
        audioPlayer.prepareToPlay()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        audioPlayer.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

