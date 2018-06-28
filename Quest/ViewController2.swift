//
//  ViewController2.swift
//  Quest
//
//  Created by 西島志織 on 2018/06/03.
//  Copyright © 2018年 西島志織. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit
import AVFoundation

class ViewController2: UIViewController, ARSCNViewDelegate, AVAudioPlayerDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var label: UILabel!
    
    var cell: CAEmitterCell!
    
    // BGM
    var audioPlayer:AVAudioPlayer!
    // 効果音
    var sePlayer:AVAudioPlayer!
    var sePlayer2:AVAudioPlayer!

    let configration = ARWorldTrackingConfiguration()
    
    // 画面を表示するタイミングで呼ばれる
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // ARKit用。検知対象を設定するプロパティ。平面を検知するように指定
        self.configration.planeDetection = .horizontal
        // 現実の環境光に合わせてレンダリングしてくれるらしい
        self.configration.isLightEstimationEnabled = true
        
        self.sceneView.delegate = self
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints, ARSCNDebugOptions.showWorldOrigin]
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.scene = SCNScene()
        
        // BGM
        self.prepareMusic();
        
        // UITapGestureRecognizer を使ってタップイベントを取得できるようにする
        self.sceneView.addGestureRecognizer(UITapGestureRecognizer(
            target: self, action: #selector(self.tapView(sender:))))
    }
    
    // viewDidLoadのあとに呼ばれる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.label.text = "へいめんをけんしゅつちゅう…"
        audioPlayer.play();
        
        self.sceneView.session.run(configration)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // つよいまほう
    @IBAction func resetButton(_ sender: UIButton) {
        slimeCount = 0
        sePlayer2.play()
        self.onStar()
        resetSession()
        DispatchQueue.main.async {
            self.label.text = "へいめんをけんしゅつちゅう…"
        }
    }

    // リセット時に呼ぶ
    func resetSession() {
        self.sceneView.session.pause()
        self.sceneView.scene.rootNode.enumerateChildNodes {(node, _) in
            node.removeFromParentNode()
        }
        // ARKit用。検知対象を設定するプロパティ。平面を検知するように指定
        self.configration.planeDetection = .horizontal
        self.configration.isLightEstimationEnabled = true
        self.sceneView.session.run(configration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // にげる
    @IBAction func buttonTapped(sender : AnyObject) {
        slimeCount = 0
        audioPlayer.stop();
        resetSession()
        performSegue(withIdentifier: "toViewController",sender: nil)
    }
    
    @IBAction func goBack(_ segue:UIStoryboardSegue) {}
    
    // モンスターの呼び出し
    func encountMonster(with position: SCNVector3) {
        let random = arc4random_uniform(10)
        var node = MonsterType.blue.node
        if (random < 3) {
            node = MonsterType.pink.node
        } else if (random < 6) {
            node = MonsterType.yellow.node
        }
        // 冒頭で書いたノードのextensionを使っている
        node?.setPosition(from: SCNVector3(position.x, position.y, position.z+1.5))
            .setRotation(from: SCNVector4(1, 0, 0, -0.5 * Float.pi))
            .setScale(from: SCNVector3(0.005, 0.005, 0.005))
            .addNode(to: &sceneView.scene)
    }
    
    var slimeCount = 0;

    // ARKit のライフサイクルの１つ、平面認識時に発火
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // 3つまで出現
        if (slimeCount < 1) {
            DispatchQueue.main.async {
                self.label.text = "スライムがあらわれた！"
            }
            
            slimeCount = slimeCount + 1;
            let position = SCNVector3Make(node.position.x,
                                          node.position.y,
                                          node.position.z-0.2) // 少し前に出すために-0.2している
            
            encountMonster(with: position)
        }
    }
    
    // タップ判定の取得
    @objc func tapView(sender: UITapGestureRecognizer) {
        let tapPoint = sender.location(in: sceneView)
        let results = sceneView.hitTest(tapPoint, types: .existingPlaneUsingExtent)
        
        if (!results.isEmpty) {
            self.onFire()
            sePlayer.play()
            slimeCount = 0
            resetSession()
            DispatchQueue.main.async {
                self.label.text = "へいめんをけんしゅつちゅう…"
            }
        }
    }

    // こうげき時のエフェクト
    func onFire() {
        let bokeh = SCNParticleSystem(named: "Bokeh.scnp", inDirectory: "")!
        self.sceneView.scene.rootNode.addParticleSystem(bokeh)
    }
    
    // つよいまほうのエフェクト
    func onStar() {
        let fire = SCNParticleSystem(named: "Fire.scnp", inDirectory: "")!
        self.sceneView.scene.rootNode.addParticleSystem(fire)
    }
    
    // 各種音の準備
    func prepareMusic () {
        // 再生する audio ファイルのパスを取得
        let audioPath = Bundle.main.path(forResource: "BattleTheme", ofType:"mp3")!
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
        
        // 効果音
        let sePath = Bundle.main.path(forResource: "Hit", ofType:"mp3")!
        let seUrl = URL(fileURLWithPath: sePath)
        // auido を再生するプレイヤーを作成する
        var seError:NSError?
        do {
            sePlayer = try AVAudioPlayer(contentsOf: seUrl)
        } catch let error as NSError {
            seError = error
            sePlayer = nil
        }
        // エラーが起きたとき
        if let error = seError {
            print("Error \(error.localizedDescription)")
        }
        sePlayer.delegate = self
        sePlayer.prepareToPlay()
        
        // 効果音その２
        let sePath2 = Bundle.main.path(forResource: "Victory", ofType:"mp3")!
        let seUrl2 = URL(fileURLWithPath: sePath2)
        // auido を再生するプレイヤーを作成する
        var seError2:NSError?
        do {
            sePlayer2 = try AVAudioPlayer(contentsOf: seUrl2)
        } catch let error as NSError {
            seError2 = error
            sePlayer2 = nil
        }
        // エラーが起きたとき
        if let error = seError2 {
            print("Error \(error.localizedDescription)")
        }
        sePlayer2.delegate = self
        sePlayer2.prepareToPlay()
    }
}

extension SCNNode {
    // 重力設定
    public func setPhysics<T>(with object: T, and type: SCNPhysicsBodyType = .kinematic) -> SCNNode where T: SCNGeometry {
        let shape = SCNPhysicsShape(geometry: object, options: nil)
        self.physicsBody = SCNPhysicsBody(type: type, shape: shape)
        return self
    }
    
    // 座標設定
    public func setPosition(from position: SCNVector3) -> SCNNode {
        self.position = position
        return self
    }
    
    // 回転設定
    public func setRotation(from rotation: SCNVector4) -> SCNNode {
        self.rotation = rotation
        return self
    }
    
    // サイズ設定
    public func setScale(from scale: SCNVector3) -> SCNNode {
        self.scale = scale
        return self
    }
    
    // ノード生成
    public func addNode(to scene: inout SCNScene) {
        scene.rootNode.addChildNode(self)
    }
    
    // ノード削除
    public func removeNode(to scene: inout SCNScene) {
        scene.rootNode.removeFromParentNode()
    }
    
}

// スライム定義
enum MonsterType: UInt32 {
    case pink
    case blue
    case yellow
    
    // ファイル名
    private var fileName: String {
        switch self {
        case .pink: return "Slime_Assistant3_ColladaMax"
        case .blue: return "Slime_Low_ColladaMax"
        case .yellow: return "Slime_Assistant1_ColladaMax"
        }
    }
    
    // daeファイルの読み込み
    private var bundleURL: URL? {
        return Bundle.main.url(forResource: fileName, withExtension: "dae")
    }
    
    // モンスターの生成
    var node: SCNNode? {
        guard
            let url = bundleURL,
            let scene = try? SCNScene(url: url, options: nil)
            else { return nil }
        // daeの3Dモデルは複数パーツで構成されているので、すべてaddChildNodeする必要がある
        let node = SCNNode()
        for childNode in scene.rootNode.childNodes {
            node.addChildNode(childNode)
        }
        return node
    }
}
