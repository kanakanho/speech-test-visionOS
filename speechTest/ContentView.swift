//
//  ContentView.swift
//  speechTest
//
//  Created by blue ken on 2024/07/07.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @State private var showImmersiveSpace = false
    @State private var immersiveSpaceIsShown = false
    
    @Environment(\.openImmersiveSpace) var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) var dismissImmersiveSpace
    
    // 音声用
    @StateObject var viewModel = ContentViewViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: viewModel.isRecognition ? "mic.slash.circle":"mic.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(viewModel.isRecognition ? .red : .primary)
                .onTapGesture {
                    viewModel.onTaped()
                }
            
            Text("[認識中]")
            Text(viewModel.text)
            
            Text("[認識結果]")
            Text(viewModel.result)
        }
        .padding()
        
        Toggle("Show ImmersiveSpace", isOn: $showImmersiveSpace)
            .font(.title)
            .frame(width: 360)
            .padding(24)
            .glassBackgroundEffect()
        
            .onChange(of: showImmersiveSpace) { _, newValue in
                Task {
                    if newValue {
                        switch await openImmersiveSpace(id: "ImmersiveSpace") {
                        case .opened:
                            immersiveSpaceIsShown = true
                        case .error, .userCancelled:
                            fallthrough
                        @unknown default:
                            immersiveSpaceIsShown = false
                            showImmersiveSpace = false
                        }
                    } else if immersiveSpaceIsShown {
                        await dismissImmersiveSpace()
                        immersiveSpaceIsShown = false
                    }
                }
            }
            .onAppear {
                viewModel.onAppear()
            }
    }
}

class ContentViewViewModel : ObservableObject{
    /// 音声認識クラス
    lazy var speechRecorder = SpeechRecognitionEngine(silenceTime:3
                                                      ,onFinishTask:onFinishTask
                                                      ,onRecognition:onRecognition)
    /// 認識中
    @Published var text = ""
    /// 認識結果
    @Published var result = ""
    /// 認識中か否か
    @Published var isRecognition = false
    
    /// 初期表示時
    func onAppear(){
        // 許可チェック
        if !speechRecorder.authorization(){
            // マイク認識要求
            self.speechRecorder.requestAccess(){
                // 許可チェック
                if self.speechRecorder.authorization(){
                    // 正常時処理
                    print("Authorization OK")
                } else {
                    // 異常時処理
                    print("Authorization NG")
                    DispatchQueue.main.async {
                        // 異常時処理
                        self.result = "音声認識又は、マイクのアクセス権限がありません。設定画面よりアクセス権限を設定しアプリを再起動してください。"
                    }
                }
            }
        }
    }
    
    /// マイクボタンタップ時
    func onTaped(){
        DispatchQueue.main.async {
            // テキストクリア
            self.text = ""
            self.result = ""

            if self.isRecognition {
                // 音声認識停止
                self.speechRecorder.stopRecording()
            } else {
                // 音声認識開始
                try? self.speechRecorder.startRecording()
            }

            // 認識フラグ設定
            self.isRecognition.toggle()
        }
    }
    
    /// 音声認識時
    /// - Parameter strings: 認識した文字列
    func onRecognition(strings:[String]){
        print("\n認識開始:" + strings.debugDescription)
        
        // 文字列設定
        DispatchQueue.main.async {
            let text = strings.joined(separator: " ")
            if self.text != text {
                self.text = text
            }
        }
    }
    
    /// 認識結果
    func onFinishTask(){
        DispatchQueue.main.async {
            self.result = self.text
            self.text = ""
            
            // 音声認識停止
            self.speechRecorder.stopRecording()
            self.isRecognition = false
        }
    }
}


#Preview(windowStyle: .automatic) {
    ContentView()
}
