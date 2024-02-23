//
//  ContentView.swift
//  MusicConverter
//
//  Created by 宋义宝 on 2024/2/23.
//

import SwiftUI
import Cocoa
import Foundation

struct ContentView: View {
    @State private var inputDirectory: String = ""
    @State private var outputDirectory: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("输入文件夹:")
                TextField("", text: $inputDirectory)
                Button("浏览", action: selectInputDir)
            }
            .padding()
            
            HStack {
                Text("输出文件夹:")
                TextField("", text: $outputDirectory)
                Button("浏览", action: selectOutputDir)
            }
            .padding()
            
            Button("开始转换", action: convertMusic)
                .padding()
        }
        .frame(width: 400, height: 200)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Command Result"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    func selectInputDir() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.urls.first {
                inputDirectory = url.path
            }
        }
    }
    
    func selectOutputDir() {
        let openPanel = NSOpenPanel()
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK {
            if let url = openPanel.urls.first {
                outputDirectory = url.path
            }
        }
    }
    
    func convertMusic() {
        let inputDir = inputDirectory
        let outputDir = outputDirectory
//        let fileManager = FileManager.default
//        let executableURL = Bundle.main.url(forResource: "um", withExtension: nil)
//        if fileManager.fileExists(atPath: executableURL.path) {
//            if fileManager.isExecutableFile(atPath: executableURL.path){
//                
//            }else{
//                
//            }
//        }else{
//            
//        }
        // 创建一个 Process 对象
        let process = Process()
        // 设置要执行的文件的 URL，这里是 ls 命令的路径
        process.executableURL = Bundle.main.url(forResource: "um", withExtension: nil)
        // 设置要传递的参数，这里是列出当前目录下的所有文件
        process.arguments = ["-i",inputDir,"-o",outputDir]
        // 创建一个 Pipe 对象，用于捕获子进程的输出
        let pipe = Pipe()
        // 将 Pipe 对象设置为子进程的标准输出
        process.standardOutput = pipe
        do {
            // 尝试运行子进程
            try process.run()
            // 等待子进程完成
            process.waitUntilExit()
            // 从 Pipe 对象中读取数据
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            // 将数据转换为字符串
            if let outputString = String(data: data, encoding: .utf8) {
                // 将字符串赋值给 output 变量，更新界面
                self.alertMessage = outputString // Set the alert message
                self.showAlert = true // Show the alert
            }
        } catch {
            // 如果运行失败，打印错误信息
            print("error")
            print(error.localizedDescription)
        }
    }
}

#Preview {
    ContentView()
}
