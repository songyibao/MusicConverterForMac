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
        .frame(width: 500, height: 300)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("转换结果"), message: Text(alertMessage), primaryButton: .default(Text("打开文件目录"), action: {
                openOutputDirectory()
            }), secondaryButton: .default(Text("完成")))
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
    
    func openOutputDirectory() {
        let outputURL = URL(fileURLWithPath: outputDirectory)
        NSWorkspace.shared.open(outputURL)
    }
    
    func convertMusic() {
        let inputDir = inputDirectory
        let outputDir = outputDirectory
        let fileManager = FileManager.default
        
        // 获取inputDir下的所有文件
        do {
            let files = try fileManager.contentsOfDirectory(atPath: inputDir)
            var succeededFiles = [String]()
            var failedFiles = [String]()
            var succ_count = 0
            var fail_count = 0
            // 遍历文件
            for file in files {
                let fileURL = URL(fileURLWithPath: inputDir).appendingPathComponent(file)
                
                // 排除文件夹
                var isDirectory: ObjCBool = false
                if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) && isDirectory.boolValue {
                    continue
                }// 创建一个 Process 对象
                let process = Process()
                // 设置要执行的文件的 URL，这里是 um 命令的路径
                process.executableURL = Bundle.main.url(forResource: "um", withExtension: nil)
                // 设置要传递的参数，这里是每个文件的路径
                process.arguments = ["-o", outputDir, "-i", "\(inputDir)/\(file)"]
                
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
                        if outputString.localizedStandardContains("successfully") {
                            succ_count+=1
                            succeededFiles.append(file)
                        } else {
                            fail_count+=1
                            failedFiles.append(file)
                        }
                    }
                } catch {
                    // 如果运行失败，打印错误信息
                    print(error.localizedDescription)
                }
            }
            // 设置 alertMessage
            self.alertMessage = "成功转换 \(succ_count) 个文件，失败 \(fail_count) 个文件\n"
            if !succeededFiles.isEmpty {
                self.alertMessage += "---------------------------------\n转换成功的文件:\n \(succeededFiles.joined(separator: "\n"))\n"
            }
            if !failedFiles.isEmpty {
                self.alertMessage += "---------------------------------\n转换失败的文件:\n \(failedFiles.joined(separator: "\n"))\n"
            }
            // 更新界面
            self.showAlert = true
        } catch {
            // 获取文件列表失败
            print(error.localizedDescription)
        }
    }
    
}

#Preview {
    ContentView()
}
