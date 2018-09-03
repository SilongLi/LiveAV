//
//  ViewController.swift
//  LiveAV
//
//  Created by lisilong on 2018/8/28.
//  Copyright © 2018 lisilong. All rights reserved.
//

import UIKit
import TXLiteAVSDK_Player

// 直播
private let LivePlayerUrl = "http://5815.liveplay.myqcloud.com/live/5815_89aad37e06ff11e892905cb9018cf0d4.flv"

// 点播视屏
/// 主视频
private let MainVodPlayerUrl = "http://1257264886.vod2.myqcloud.com/5d693b70vodgzp1257264886/342ea44e5285890781455239323/AxV6UlAdByAA.mp4"
/// 插播视频A
private let VodPlayerUrlA = "http://1257264886.vod2.myqcloud.com/5d693b70vodgzp1257264886/391fbb9b5285890781455476576/F3gYtcgtKoEA.mp4"
/// 插播视频B
private let VodPlayerUrlB = "http://1257264886.vod2.myqcloud.com/5d693b70vodgzp1257264886/36cb1afa5285890781455377467/v0Yv0Pkl0fIA.mp4"

private let StartPlayVodATime: Float = 0.5 * 60.0  // 插播视频A时间（单位秒）
private let StartPlayVodBTime: Float = 2.0 * 60.0  // 插播视频B时间（单位秒）


private let noteColor = UIColor.init(red: 220.0/255.0, green: 220.0/255.0, blue: 220.0/255.0, alpha: 1.0)

class ViewController: UIViewController {
    
    lazy var livePlayer: TXLivePlayer = {   // 直播播放器
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
    
    lazy var mainVodPlayer: TXVodPlayer = {   // 点播播放器
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
    
    lazy var mainNoteLabel: UILabel = { // 主视频提示信息
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.green
        label.textAlignment = .center
        label.text = "加载中..."
        return label
    }()
    
    let mainView: UIView = {   //  承载直播视频界面
        let view = UIView()
        view.backgroundColor = noteColor
        return view
    }()
    
    let mainProgress: UIProgressView = {
        let view = UIProgressView.init(progressViewStyle: UIProgressViewStyle.default)
        view.isHidden = true
        return view
    }()
    
    lazy var noteLabel: UILabel = { // 插播视频提示信息
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.green
        label.textAlignment = .center
        label.text = "加载中..."
        return label
    }()
    
    let vodView: UIView = {   //  承载点播视频界面
        let view = UIView()
        view.backgroundColor = noteColor
        return view
    }()
    
    let vodProgress: UIProgressView = {
        let view = UIProgressView.init(progressViewStyle: UIProgressViewStyle.default)
        view.isHidden = true
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
        let noteH: CGFloat = 20.0
        mainNoteLabel.frame = CGRect.init(x: 0.0, y: (mainView.frame.size.height - noteH) * 0.5, width: mainView.frame.size.width, height: noteH)
        mainView.addSubview(mainNoteLabel)
        
        vodView.frame =  CGRect.init(x: 0.0, y: 300.00, width: UIScreen.main.bounds.size.width, height: 200)
        vodView.isHidden = true
        vodView.backgroundColor = .red
        view.addSubview(vodView)
        vodProgress.frame = CGRect.init(x: 0.0, y: vodView.frame.size.height, width: mainView.frame.size.width, height: 10)
        vodView.addSubview(vodProgress)
        noteLabel.frame = CGRect.init(x: 0.0, y: (vodView.frame.size.height - noteH) * 0.5, width: vodView.frame.size.width, height: noteH)
        vodView.addSubview(noteLabel)
    }
    
    // MARK: - actions
    
    /// 播放直播
    func startLivePlay() {
        livePlayer.setupVideoWidget(mainView.bounds, contain: mainView, insert: 0)
        livePlayer.startPlay(LivePlayerUrl, type: TX_Enum_PlayType.PLAY_TYPE_LIVE_FLV)
    }
    
    /// 播放点播 主视频
    func startMianVodPlayer() {
        mainVodPlayer.setupVideoWidget(mainView, insert: 0)
        mainVodPlayer.isAutoPlay = true
        mainVodPlayer.startPlay(MainVodPlayerUrl)
    }
    
    /// 预加载 视频A
    func prepareVodPlayerA() {
        print("开始预加载视频A")
        vodPlayerA.isAutoPlay = false
        vodPlayerA.startPlay(VodPlayerUrlA)
        hasPrepareVodePlayerA = true
    }
    
    /// 预加载 视频B
    func prepareVodPlayerB() {
        print("开始预加载视频B")
        vodPlayerB.isAutoPlay = false
        vodPlayerB.startPlay(VodPlayerUrlB)
        hasPrepareVodePlayerB = true
    }
}

// MARK: - <TXLivePlayListener> 直播代理
extension ViewController: TXLivePlayListener {
    func onPlayEvent(_ EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        print("onPlayEvent---", EvtID, param)
    }
    
    func onNetStatus(_ param: [AnyHashable : Any]!) {
        print("onNetStatus---", param)
    }
}

// MARK: - <TXVodPlayListener> 点播代理
extension ViewController: TXVodPlayListener {
    func onNetStatus(_ player: TXVodPlayer!, withParam param: [AnyHashable : Any]!) {
        
    }
    
    func onPlayEvent(_ player: TXVodPlayer!, event EvtID: Int32, withParam param: [AnyHashable : Any]!) {
        // 更新加载提示
        updateNoteLabel(player, event: EvtID)
        
        /// 主视频
        if player == mainVodPlayer {
            mainProgress.isHidden = !mainVodPlayer.isPlaying()
            
            if (EvtID == PLAY_EVT_PLAY_PROGRESS.rawValue) { // 播放进度
                let progress = DecimalNumberTool.float(num: String(describing: param[EVT_PLAY_PROGRESS] ?? "0.0"))
                let duration = DecimalNumberTool.float(num: String(describing: param[EVT_PLAY_DURATION] ?? "0.0"))
                mainProgress.setProgress(progress / duration, animated: true)
                
                // 1. 在即将播放插播视频A的时候，先预加载视频A
                if progress >= (StartPlayVodATime - 20.0), !hasPrepareVodePlayerA {
                    prepareVodPlayerA()
                }
                
                // 在设定的时间点，播放视频A
                if progress >= StartPlayVodATime,
                    progress <= (StartPlayVodATime + 5.0),
                    !vodPlayerA.isPlaying(),
                    vodView.isHidden,
                    vodPlayerA.playableDuration() > 0.0 {
                    
                    vodView.isHidden = false
                    vodPlayerA.setupVideoWidget(vodView, insert: 0)
                    vodPlayerA.resume()
                    print("开始播放视频A")
                }
                
                // 2. 在即将播放插播视频 B 的时候，先预加载视频 B
                if progress >= (StartPlayVodBTime - 20.0), !hasPrepareVodePlayerB {
                    prepareVodPlayerB()
                }
                
                // 在设定的时间点，播放视频 B
                if progress >= StartPlayVodBTime,
                    progress <= (StartPlayVodBTime + 5.0),
                    !vodPlayerB.isPlaying(),
                    vodView.isHidden,
                    vodPlayerB.playableDuration() > 0.0 {
                    
                    vodView.isHidden = false
                    vodPlayerB.setupVideoWidget(vodView, insert: 0)
                    vodPlayerB.resume()
                    print("开始播放视频B")
                }
                
                if vodView.isHidden == true {
                    print("---M-----：\(progress)--\(duration)--\(progress / duration * 100.0)%-------")
                }
            }
        }
        
        /// 视频A
        if player == vodPlayerA {
            vodProgress.isHidden = !vodPlayerA.isPlaying()
            
            if (EvtID == PLAY_EVT_PLAY_PROGRESS.rawValue) {
                let progress = DecimalNumberTool.float(num: String(describing: param[EVT_PLAY_PROGRESS] ?? "0.0"))
                let duration = DecimalNumberTool.float(num: String(describing: param[EVT_PLAY_DURATION] ?? "0.0"))
                if vodPlayerA.isPlaying() {
                    vodProgress.setProgress(progress / duration, animated: true)
                    print("--A------：\(progress)--\(duration)--\(progress / duration * 100.0)%-------")
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
            vodProgress.isHidden = !vodPlayerB.isPlaying()
            
            if (EvtID == PLAY_EVT_PLAY_PROGRESS.rawValue) {
                let progress = DecimalNumberTool.float(num: String(describing: param[EVT_PLAY_PROGRESS] ?? "0.0"))
                let duration = DecimalNumberTool.float(num: String(describing: param[EVT_PLAY_DURATION] ?? "0.0"))
                if vodPlayerB.isPlaying() {
                    vodProgress.setProgress(progress / duration, animated: true)
                    print("--B------：\(progress)--\(duration)--\(progress / duration * 100.0)%-------")
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
    
    func updateNoteLabel(_ player: TXVodPlayer, event EvtID: Int32) {
        var note = mainNoteLabel
        if player == mainVodPlayer {
        } else {
            note = noteLabel
        }
        if EvtID == PLAY_ERR_NET_DISCONNECT.rawValue {  // 请求资源失败
            note.text = "加载失败，请稍后重试！"
            note.isHidden = false
            note.textColor = .red
            
        } else if EvtID == PLAY_EVT_PLAY_BEGIN.rawValue {   // 即将开始
            note.text = ""
            note.isHidden = true
            note.textColor = .green
            
        } else if EvtID == PLAY_EVT_PLAY_LOADING.rawValue { // 加载中
            note.text = "加载中..."
            note.isHidden = false
            note.textColor = .green
        }
    }
}

