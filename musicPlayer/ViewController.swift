//
//  ViewController.swift
//  musicPlayer
//
//  Created by 林家宇 on 2020/7/25.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController {
    
    @IBOutlet var showImage: UIImageView!
    @IBOutlet var playAndPause: UIButton!
    @IBOutlet var showTrackName: UILabel!
    @IBOutlet var backwardBtn: UIButton!
    @IBOutlet var forwardBtn: UIButton!
    @IBOutlet var showArtistName: UILabel!
    @IBOutlet var showLabel: UILabel!
    @IBOutlet var nowPlayLabel: UILabel!
    @IBOutlet var totalPlayLabel: UILabel!
    @IBOutlet var slider: UISlider!
    @IBOutlet var shuffleBtn: UIButton!
    @IBOutlet var repeatBtn: UIButton!
    @IBOutlet var repeatOneBtn: UIButton!
    @IBOutlet var playListBtn: UIButton!
    
    struct MusicList {
        let artistName: String
        let trackName: String
        let previewName: String
        let trackType: String
    }
    
    let musicList = [
        MusicList(artistName: "EGOIST", trackName: "Departures",previewName:"egoist-departres" ,trackType:"mp3"),
        MusicList(artistName: "藍井エイル", trackName: "流星",previewName:"藍井エイル-流星" ,trackType:"mp3"),
        MusicList(artistName: "花たん", trackName: "心做し",previewName:"花たん-心做し" ,trackType:"mp3"),
        MusicList(artistName: "春茶", trackName: "フラレガイガール",previewName:"春茶-フラレガイガール" ,trackType:"mp3"),
        MusicList(artistName: "YOASOBI", trackName: "夜に駆ける",previewName:"YOASOBI-夜に駆ける" ,trackType:"mp3"),
        MusicList(artistName: "Hebe", trackName: "小幸運",previewName:"Hebe-小幸運" ,trackType:"mp3"),
        MusicList(artistName: "EGOIST", trackName: "Planetes",previewName:"egoist-planetes" ,trackType:"m4a"),
    ]
    
    
    
    let player = AVPlayer()
    var playNum : Int = 0
    var randomNum : Int = 0
    var playerItem : AVPlayerItem?
    var playAry : [Int] = []
    var repeatPlay = true
    var repeatOnePlay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        randomNum = Int.random(in: 1 ..< musicList.count)
//        updatePlayerUI()
        checkMusicIsEnd()
        player.volume = 0.5
        createPlayAry()
        setupRemoteTransportControls()
    }
    
    @IBAction func playAndPauesBtn(_ sender: UIButton) {
        if player.rate == 0 {
            if slider.value != 0{
                let seconds = Int64(slider.value)
                let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
                // 將當前設置時間設為播放時間
                player.seek(to: targetTime)
                player.play()
            }else{
                musicPlay(num:playNum)
                playAndPause.setBackgroundImage( UIImage(systemName: "pause.fill"), for: UIControl.State.normal)
            }
        }else {
            player.pause()
            playAndPause.setBackgroundImage( UIImage(systemName: "play.fill"), for: UIControl.State.normal)
        }
    }
    
    @IBAction func backwardBtnDo(_ sender: UIButton) {
        playPreviousMusic()
    }
    
    @IBAction func forwardBtnDo(_ sender: UIButton) {
        playNextMusic()
    }
    
    @IBAction func sliderValChange(_ sender: UISlider) {
        let seconds = Int64(sender.value)
        let targetTime:CMTime = CMTimeMake(value: seconds, timescale: 1)
        // 將當前設置時間設為播放時間
        player.seek(to: targetTime)
        setupNowPlaying()
    }
    
    @IBAction func voiceValChange(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    @IBAction func shufflePlay(_ sender: UIButton) {
        if sender.tintColor != UIColor.systemGray{
            shuffleBtn.tintColor = UIColor.systemGray
            sortPlayAry()
        }else{
            shuffleBtn.tintColor = UIColor.systemRed
            shufflePlayAry()
        }
//        print(playAry)
    }
    
    @IBAction func repeatPlay(_ sender: UIButton) {
        if sender.tintColor != UIColor.systemGray{
            repeatBtn.tintColor = UIColor.systemGray
            repeatPlay = false
        }else{
            repeatBtn.tintColor = UIColor.systemRed
            repeatPlay = true
        }
    }
    
    @IBAction func repeatOnePlay(_ sender: UIButton) {
        if sender.tintColor != UIColor.systemGray{
            repeatOneBtn.tintColor = UIColor.systemGray
            repeatOnePlay = false
        }else{
            repeatOneBtn.tintColor = UIColor.systemRed
            repeatOnePlay = true
        }
    }
    func musicPlay(num:Int){
        //播放/暫停
        do{
            playNum = num
            let musicName = musicList[playAry[num]].artistName + "-" + musicList[playAry[num]].trackName
            let musicType = musicList[playAry[num]].trackType
            let fileUrl = Bundle.main.url(forResource: musicName, withExtension: musicType)!
            playerItem = AVPlayerItem(url: fileUrl)
            self.player.replaceCurrentItem(with: playerItem)
            self.player.play()
            playAndPause.setBackgroundImage( UIImage(systemName: "pause.fill"), for: UIControl.State.normal)
            changeImage(num:playAry[num])
            changeInfo(num:playAry[num])
            CurrentTime()
            updatePlayerUI()
            setupNowPlaying()
        }catch{
            print("Failed to init audio player: \(error)")
        }
        print(playAry[num])
    }
    func changeImage(num:Int){
        //換封面
        showImage.image = UIImage(named: musicList[num].previewName)
    }
    func changeInfo(num:Int){
        //換資訊
        showTrackName.text = musicList[num].trackName
        showArtistName.text = musicList[num].artistName
        
    }
    func updatePlayerUI() {
        //更新總時間& Slider 的Value
        guard let duration = playerItem?.asset.duration else {
            return
        }
        //轉為歌曲的總時間
        let seconds = CMTimeGetSeconds(duration)
//        print(seconds)
        //在Label顯示歌曲總時間
        totalPlayLabel.text = formatConversion(time: seconds)
        slider.minimumValue = 0
        slider.maximumValue = Float(seconds)
        slider.isContinuous = true
    }
    func formatConversion(time:Double) ->String{
        //時間秒數轉換
        let answer = Int(time).quotientAndRemainder(dividingBy: 60)
        let returnStr = String(answer.quotient) + ":" + String(format: "%02d", answer.remainder)
        return returnStr
    }
    func CurrentTime() {
        //監聽現在播放時間&換Slider的Value
        player.addPeriodicTimeObserver(forInterval: CMTimeMake(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (CMTime) in
            if self.player.currentItem?.status == .readyToPlay {
                let currentTime = CMTimeGetSeconds(self.player.currentTime())
                self.slider.value = Float(currentTime)
                self.nowPlayLabel.text = self.formatConversion(time: currentTime)
            }
        })
    }
    func playNextMusic(){
        if player.rate != 0 {
            player.pause()
        }
        var forwardNum:Int
        if playNum + 1 >= musicList.count{
            if repeatPlay {
                forwardNum = 0
//                musicPlay(num: forwardNum)
            }else{
                defaultTypeLoading()
                return
            }
        }else{
            forwardNum = playNum + 1
        }
        musicPlay(num: forwardNum)
    }
    func playPreviousMusic(){
        if player.rate != 0 {
            player.pause()
        }
        var backwardNum = playNum - 1
        if backwardNum < 0{
            backwardNum = musicList.count-1
        }
        musicPlay(num: backwardNum)
    }
    func checkMusicIsEnd(){
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil, queue: .main) { (_) in
            if self.repeatOnePlay{
//                let seconds = Int64(0)
                let targetTime:CMTime = CMTimeMake(value: 0, timescale: 1)
                // 將當前設置時間設為播放時間
                self.player.seek(to: targetTime)
                self.player.play()
            }else{
                
                self.playNextMusic()
            }
//            print("isEnd")
        }
    }
    func createPlayAry(){
        for i in 0 ..< musicList.count{
            playAry.append(i)
        }
//        print(playAry)
        
    }
    func sortPlayAry(){
        playAry.sort()
    }
    func shufflePlayAry(){
        playAry.shuffle()
//        print(playAry)
    }
    func defaultTypeLoading(){
        showImage.image = nil
        playAndPause.setBackgroundImage( UIImage(systemName: "play.fill"), for: UIControl.State.normal)
        showTrackName.text = ""
        showArtistName.text = ""
        showLabel.text = ""
        nowPlayLabel.text = "0:00"
        totalPlayLabel.text = "0:00"
        slider.value = 0
        slider.maximumValue = 0
        slider.minimumValue = 0
    }
    
    //  設定背景&鎖定播放
        func setupRemoteTransportControls() {
            // Get the shared MPRemoteCommandCenter
            let commandCenter = MPRemoteCommandCenter.shared()

            // Add handler for Play Command
            commandCenter.playCommand.addTarget { [unowned self] event in
                if self.player.rate == 0.0 {
                    self.player.play()
                    return .success
                }
                return .commandFailed
            }

            // Add handler for Pause Command
            commandCenter.pauseCommand.addTarget { [unowned self] event in
                if self.player.rate == 1.0 {
                    self.player.pause()
                    return .success
                }
                return .commandFailed
            }
            commandCenter.nextTrackCommand.addTarget{ [unowned self] event in
                self.playNextMusic()
//                if self.player.rate == 1.0 {
//                    self.player.pause()
//                    return .success
//                }
//                return .commandFailed
                return .success
            }
            commandCenter.previousTrackCommand.addTarget{ [unowned self] event in
                self.playPreviousMusic()
                return .success
            }
        }
    //  設定背景播放的歌曲資訊
        func setupNowPlaying() {
            // Define Now Playing Info
            let songName:String = (self.musicList[playAry[playNum]].trackName)
            let artistName:String = (self.musicList[playAry[playNum]].artistName)
            let albumImage:String = (self.musicList[playAry[playNum]].previewName)
            var nowPlayingInfo = [String : Any]()
            nowPlayingInfo[MPMediaItemPropertyTitle] = songName
            nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = artistName

            if let image = UIImage(named: albumImage) {
                nowPlayingInfo[MPMediaItemPropertyArtwork] =
                    MPMediaItemArtwork(boundsSize: image.size) { size in
                        return image
                }
            }
            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime().seconds
            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.currentItem?.asset.duration.seconds
            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate

            // Set the metadata
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
        }
}

