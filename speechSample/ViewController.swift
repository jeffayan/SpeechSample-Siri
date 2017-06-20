//
//  ViewController.swift
//  speechSample
//
//  Created by Developer on 14/06/17.
//  Copyright © 2017 Developer. All rights reserved.
//

import UIKit
import Speech


class ViewController: UIViewController {
    
    @IBOutlet var textView:UITextView!
    @IBOutlet var recordButton : UIButton!

  fileprivate var isAuthorized = false
  fileprivate var requestTask: SFSpeechRecognitionTask?
  fileprivate var audioEngine = AVAudioEngine()
  fileprivate var request: SFSpeechAudioBufferRecognitionRequest?
  fileprivate var speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizer?.delegate = self
        SFSpeechRecognizer.requestAuthorization({ result in
            self.isAuthorized = result == SFSpeechRecognizerAuthorizationStatus.authorized
        })
    }

    @IBAction func clicked(_ sender: Any) {
        
        if self.audioEngine.isRunning{
            self.audioEngine.stop()
            self.request?.endAudio()
            self.recordButton.setTitle("Listen", for: .normal)
        } else {
            self.textView.text = ""
            self.startRecording()
            self.recordButton.setTitle("Stop", for: .normal)
        }
        
        
    }
    
    
    func startRecording(){
        
        if requestTask != nil {
            requestTask?.cancel()
            requestTask = nil
        }
        
        request =  SFSpeechAudioBufferRecognitionRequest()
        
        let avAudioSession = AVAudioSession.sharedInstance()
        
        
        do{
            
            try avAudioSession.setCategory(AVAudioSessionCategoryRecord)
            try avAudioSession.setMode(AVAudioSessionModeMeasurement)
            try avAudioSession.setActive(true, with: .notifyOthersOnDeactivation)
            
        } catch let err {
            
            print("Catch Err  ",err.localizedDescription)
            
        }
        
        
        guard let input = audioEngine.inputNode else {
            print("Failed at input node")
            return
        }
        
        guard request != nil  else {
            print("Request nil")
            return
        }
        
        requestTask = speechRecognizer?.recognitionTask(with: request!, resultHandler: {
            result, err in
            
            var _final = false
            
            if result != nil {
                self.textView.text = result?.bestTranscription.formattedString
               // print (result?.bestTranscription.formattedString ?? nil)
                _final = (result?.isFinal)!
                
                
            }else {
                 print("Error  ::  \(err?.localizedDescription)")
            }
           
            if err != nil || _final{
                
                self.audioEngine.stop()
                input.removeTap(onBus: 0)
                
                self.requestTask = nil
                self.request = nil
                
                
            }
            
        })
        
        let recordingFormat = input.outputFormat(forBus: 0)
        
        input.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat, block: {
            buffer, _ in
            
            self.request?.append(buffer)
            
        })
        
        self.audioEngine.prepare()
        
        do{
            try self.audioEngine.start()
        } catch let err {
            
            print("Error : \(err.localizedDescription)")
            
        }

        
        self.textView.text = "Listening ... "
        
        
        
    }
    
    
    
    
    
    
}

extension ViewController : SFSpeechRecognizerDelegate{
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
       self.recordButton.isEnabled = available
        
    }
    
}





