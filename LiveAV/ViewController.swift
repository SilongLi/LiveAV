//
//  ViewController.swift
//  LiveAV
//
//  Created by lisilong on 2018/8/28.
//  Copyright © 2018 lisilong. All rights reserved.
//

import UIKit
import TXLiteAVSDK_Player

class ViewController: UIViewController {
    
    lazy var livePlayer: TXLivePlayer = {
        let player = TXLivePlayer()
        player.delegate = self
        player.setLogViewMargin(UIEdgeInsets.zero)
        //极速模式
        let config = TXLivePlayConfig()
        config.bAutoAdjustCacheTime = true
        config.minAutoAdjustCacheTime = 1
        config.maxAutoAdjustCacheTime = 1
        player.config = config
        return player
    }()
    
    lazy var mainVodPlayer: TXVodPlayer = {
        let player = TXVodPlayer()
        player.vodDelegate = self
        return player
    }()
    
    lazy var vodPlayerA: TXVodPlayer = {
        let player = TXVodPlayer()
        player.vodDelegate = self
        return player
    }()
    
    lazy var vodPlayerB: TXVodPlayer = {
        let player = TXVodPlayer()
        player.vodDelegate = self
        return player
    }()
    
    let mainView: UIView = {
        let view = UIView()
        return view
    }()
    
    let mainProgress: UIProgressView = {
        let view = UIProgressView.init(progressViewStyle: UIProgressViewStyle.default)
        return view
    }()
    
    let vodView: UIView = {
        let view = UIView()
        return view
    }()
    
    let vodProgress: UIProgressView = {
        let view = UIProgressView.init(progressViewStyle: UIProgressViewStyle.default)
        return view
    }()
    
    var hasPrepareVodePlayerA: Bool = false
    var hasPrepareVodePlayerB: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        TXLiveBase.setConsoleEnabled(true)
//        TXLiveBase.setLogLevel(.LOGLEVEL_DEBUG)
        setupPlayer()
        
//        startLivePlay()
        startMianVodPlayer()
    }
    
    // MARK: - setup
    
    func setupPlayer() {
        mainView.frame = CGRect.init(x: 0.0, y: 50.00, width: UIScreen.main.bounds.size.width, height: 200)
        view.addSubview(mainView)
        mainProgress.frame = CGRect.init(x: 0.0, y: mainView.frame.size.height, width: mainView.frame.size.width, height: 10)
        mainView.addSubview(mainProgress)
        
        vodView.frame =  CGRect.init(x: 0.0, y: 300.00, width: UIScreen.main.bounds.size.width, height: 200)
        vodView.isHidden = true
        vodView.backgroundColor = .red
        view.addSubview(vodView)
        vodProgress.frame = CGRect.init(x: 0.0, y: vodView.frame.size.height, width: mainView.frame.size.width, height: 10)
        vodView.addSubview(vodProgress)
    }
    
    // MARK: - actions
    
    func startLivePlay() {
        // 直播
        livePlayer.setupVideoWidget(mainView.bounds, contain: mainView, insert: 0)
        let flvUrl = "http://5815.liveplay.myqcloud.com/live/5815_89aad37e06ff11e892905cb9018cf0d4.flv"
        livePlayer.startPlay(flvUrl, type: TX_Enum_PlayType.PLAY_TYPE_LIVE_FLV)
    }
    
    func startMianVodPlayer() {
        // 主视频
        mainVodPlayer.setupVideoWidget(mainView, insert: 0)
        mainVodPlayer.isAutoPlay = true
        let flvUrl = "http://1257264886.vod2.myqcloud.com/5d693b70vodgzp1257264886/342ea44e5285890781455239323/AxV6UlAdByAA.mp4"
        mainVodPlayer.startPlay(flvUrl)

        // 预加载 视频A
        prepareVodPlayerA()
    }
    
    func prepareVodPlayerA() {
        // 预加载 视频A
        vodPlayerA.isAutoPlay = false
        let flvUrlA = "http://1257264886.vod2.myqcloud.com/5d693b70vodgzp1257264886/36cb1afa5285890781455377467/v0Yv0Pkl0fIA.mp4"
        vodPlayerA.startPlay(flvUrlA)
        hasPrepareVodePlayerA = true
    }
    
    func prepareVodPlayerB() {
        // 预加载 视频B
        vodPlayerB.isAutoPlay = false
        let flvUrlB = "http://1257264886.vod2.myqcloud.com/5d693b70vodgzp1257264886/390c973a5285890781455464884/FhZuMurMmyMA.mp4"
        vodPlayerB.startPlay(flvUrlB)
        hasPrepareVodePlayerB = true
    }
}

extension ViewController: TXLivePlayListener {
    func onPlayEvent(_ EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        print("onPlayEvent---", EvtID, param)
    }
    
    func onNetStatus(_ param: [AnyHashable : Any]!) {
        print("onNetStatus---", param)
    }
}

extension ViewController: TXVodPlayListener {
    func onNetStatus(_ player: TXVodPlayer!, withParam param: [AnyHashable : Any]!) {
        
    }
    
    func onPlayEvent(_ player: TXVodPlayer!, event EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        /// 主视频
        if player == mainVodPlayer {
            if (EvtID == PLAY_EVT_PLAY_PROGRESS.rawValue) {
//                print("---M-----加载进度：\(param[EVT_PLAYABLE_DURATION] ?? "")-------")
                
                let progressStr = String(describing: param[EVT_PLAY_PROGRESS] ?? "0.0")
                let durationStr = String(describing: param[EVT_PLAY_DURATION] ?? "0.0")
                let progress = DecimalNumberTool.float(num: progressStr)
                let duration = DecimalNumberTool.float(num: durationStr)
                let percent = progress / duration
                mainProgress.setProgress(percent, animated: true)
                
                // 在主视频播放到10秒的时候，插播视频A
                if progress >= 10.0, progress <= 12.0, !vodPlayerA.isPlaying(), vodView.isHidden {
                    vodView.isHidden = false
                    vodPlayerA.setupVideoWidget(vodView, insert: 0)
                    vodPlayerA.resume()
                    print("开始播放视频A")
                }
                
                // 在主视频播放到80秒的时候，预加载视频B5B5
                if progress >= 80, progress <= 81.0, !hasPrepareVodePlayerB {
                    prepareVodPlayerB()
                }
                
                // 在主视频110秒的时候，播放视频B
                if progress >= 100.0, progress <= 101.0, !vodPlayerB.isPlaying(), vodView.isHidden {
                    vodView.isHidden = false
                    vodPlayerB.setupVideoWidget(vodView, insert: 0)
                    vodPlayerB.resume()
                    print("开始播放视频B")
                }
                
                if vodView.isHidden == true {
                    print("---M-----：\(progress)--\(duration)--\(percent * 100.0)%-------")
                }
            }
        }
        
        /// 视频A
        if player == vodPlayerA {
            if (EvtID == PLAY_EVT_PLAY_PROGRESS.rawValue) {
                let progressStr = String(describing: param[EVT_PLAY_PROGRESS] ?? "0.0")
                let durationStr = String(describing: param[EVT_PLAY_DURATION] ?? "0.0")
                let progress = DecimalNumberTool.float(num: progressStr)
                let duration = DecimalNumberTool.float(num: durationStr)
                let percent = progress / duration
                if vodPlayerA.isPlaying() {
                    vodProgress.setProgress(percent, animated: true)
                    print("--A------：\(progress)--\(duration)--\(percent * 100.0)%-------")
                }
            }
            
            if EvtID == PLAY_EVT_PLAY_END.rawValue || (!vodPlayerB.isPlaying() && vodProgress.progress > 0.99)  {
                vodView.isHidden = true
                vodProgress.progress = 0.0
                vodPlayerA.stopPlay()
                vodPlayerA.removeVideoWidget()
                print("结束播放视频A")
            }
        }
        
        /// 视频B
        if player == vodPlayerB {
            if (EvtID == PLAY_EVT_PLAY_PROGRESS.rawValue) {
                let progressStr = String(describing: param[EVT_PLAY_PROGRESS] ?? "0.0")
                let durationStr = String(describing: param[EVT_PLAY_DURATION] ?? "0.0")
                let progress = DecimalNumberTool.float(num: progressStr)
                let duration = DecimalNumberTool.float(num: durationStr)
                let percent = progress / duration
                if vodPlayerB.isPlaying() {
                    vodProgress.setProgress(percent, animated: true)
                    print("--B------：\(progress)--\(duration)--\(percent * 100.0)%-------")
                }
                
                if EvtID == PLAY_EVT_PLAY_END.rawValue || (!vodPlayerB.isPlaying() && vodProgress.progress > 0.99) {
                    vodView.isHidden = true
                    vodProgress.progress = 0.0
                    vodPlayerB.stopPlay()
                    vodPlayerB.removeVideoWidget()
                    print("结束播放视频B")
                }
            }
        }
    }
}



