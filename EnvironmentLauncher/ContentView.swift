//
//  ContentView.swift
//  EnvironmentLauncher
//
//  Created by Francis Scheuermann on 5/10/22.
//

import SwiftUI
import os

struct ContentView: View  {
    
    @State var output : String = ""
    @State var isRunning = false
    @State var laravelRunning = false
    @State var nextGenRunning = false
    @State var legacyRunning = false
    
    @State var holder = false;
    
    @State var outputPipe : Pipe!
    
    let logger = Logger(subsystem: "TSE.EnvironmentLauncher", category: "Error")
    
    @AppStorage("laravel") private var laravel : String = "/Users/<username>/.../smartchoice-docker/"
    @AppStorage("legacy_fe") private var legacy_fe : String = "/Users/<username>/.../schoolmint-fe/"
    @AppStorage("legacy_be") private var legacy_be : String = "/Users/<username>/.../schoolmint-be/"
    @AppStorage("school_chooser") private var school_chooser : String = "/Users/<username>/.../school-chooser/"
    @AppStorage("chooser_editor") private var chooser_editor : String = "/Users/<username>/.../chooser-editor/"
    @AppStorage("nextgen_fe") private var nextgen_fe : String = "/Users/<username>/.../enrollment-fe/"
    @AppStorage("nextgen_be") private var nextgen_be : String = "/Users/<username>/.../enrollment-be/"
    
    let dispatchQueue = DispatchQueue(label: "envLauncher.queue")
    
    
    
    func dockerToggle(_ command: [String], _ running: Bool) -> Bool {
        // Initialize process and output pipe
        let task = Process()
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        
        // Append docker/yarn path to environment and re-set environment
        var env = ProcessInfo.processInfo.environment
        var path = env["PATH"]! as String
        path = "/usr/local/bin:" + path
        env["PATH"] = path
        task.environment = env

        // Set task arguments and start location
        task.arguments = command
        task.executableURL = URL(fileURLWithPath: "/usr/local/bin/docker" )
        
        // Run task
        do {
            try task.run()
        } catch {
            print("\(error)")
            return false
        }
        
        // Set isRunning to disable other buttons
        isRunning = !running
        
        // Capture output and redirect to view
        let outputHandle = outputPipe.fileHandleForReading

        outputHandle.readabilityHandler = { pipe in
                    if let ouput = String(data: pipe.availableData, encoding: .utf8) {
                        if !ouput.isEmpty {
                            if(output.starts(with: "Done in ")){
                                return
                            }
                            self.output += "\n" + ouput
                            print("----> ouput: \(ouput)")
                        }
                    } else {
                        print("Error decoding data: \(pipe.availableData)")
                    }
        }
        
        return true
    }
    
    func startYarn(_ command: [String], _ running: Bool) -> Bool {
        // Initialize process and output pipe
        let task = Process()
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        
        // Append docker/yarn path to environment and re-set environment
        var env = ProcessInfo.processInfo.environment
        var path = env["PATH"]! as String
        path = "/usr/local/bin:" + path
        env["PATH"] = path
        task.environment = env
        
        // Set task arguments and start location
        task.arguments = command
        task.executableURL = URL(fileURLWithPath: "/usr/local/bin/yarn")
        
        // Run task
        do {
            try task.run()
        } catch {
            print("\(error)")
            return false
        }
        
        // Capture output and redirect to view
        let outputHandle = outputPipe.fileHandleForReading

        outputHandle.readabilityHandler = { pipe in
                    if let ouput = String(data: pipe.availableData, encoding: .utf8) {
                        if !ouput.isEmpty {
                            if(output.starts(with: "Done in ")){
                                return
                            }
                            self.output += "\n" + ouput
                            print("----> ouput: \(ouput)")
                        }
                    } else {
                        print("Error decoding data: \(pipe.availableData)")
                    }
        }
        
        return true
    }
    
    func shell(_ command: [String], _ running: Bool) -> Bool {
        // Initialize process and output pipe
        let task = Process()
        var env = ProcessInfo.processInfo.environment
        let outputPipe = Pipe()
        task.standardOutput = outputPipe

        // Append docker/yarn path to environment and re-set environment
        var path = env["PATH"]! as String
        path = "/usr/local/bin:" + path
        env["PATH"] = path
        task.environment = env

        // Set task arguments and start location
        task.arguments = command
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        // Run task
        do {
            try task.run()
        } catch {
            print("\(error)")
            return false
        }
        
        // Capture output and redirect to view
        let outputHandle = outputPipe.fileHandleForReading

        outputHandle.readabilityHandler = { pipe in
                    if let ouput = String(data: pipe.availableData, encoding: .utf8) {
                        if !ouput.isEmpty {
                            if(output.starts(with: "Done in ")){
                                return
                            }
                            self.output += "\n" + ouput
                            print("----> ouput: \(ouput)")
                        }
                    } else {
                        print("Error decoding data: \(pipe.availableData)")
                    }
        }
        
        return true
    }
    
    
    var body: some View {
        VStack {
            HStack {
                Image("schoolmint-logo")
                //.offset(x: 60)
                Text("Environment Launcher")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .offset(x: -60)
                
                
            }.frame(maxWidth: .infinity, alignment: .topLeading)
                .padding()
            
            Text("Please select an environment:")
                .padding()
            
            HStack {
                Button(nextGenRunning ? "Stop NextGen" : "Start NextGen") {
                    if(!isRunning){
                        dispatchQueue.async {
                            // Clear output
                            self.output = "Starting containers..."
                            
                            self.output = $output.wrappedValue + "\n'docker compose -f \(nextgen_be)docker-compose.yml up'"
                            
                            holder = dockerToggle(["compose" ,"-f", (nextgen_be + "docker-compose.yml"), "up"], isRunning)
                            
                            sleep(2)
                            
                        }
                        
                        dispatchQueue.async {
                            self.output = $output.wrappedValue + "\n\nStarting yarn..."
                            
                            self.output = $output.wrappedValue + "\n'yarn start'"
                            
                            holder = startYarn(["--cwd", nextgen_fe, "start"], isRunning)
                            
                            sleep(2)
                            
                            nextGenRunning = true

                        }
                        
                    } else {
                        dispatchQueue.async {
                            
                            self.output = "Stopping containers..."
                            
                            self.output = $output.wrappedValue + "\n'docker compose -f \(nextgen_be)docker-compose.yml down'"
                            
                            holder = dockerToggle(["compose" ,"-f", (nextgen_be + "docker-compose.yml"), "down"], isRunning)
                            
                            sleep(4)
                            
                        }
                        
                        dispatchQueue.async {
                            self.output = $output.wrappedValue + "\n\nKilling all node instances..."
                            
                            self.output = $output.wrappedValue + "\n'killall node'"
                            
                            holder = shell(["-c", "killall node"], isRunning)
                            
                            sleep(2)
                            
                            nextGenRunning = false
                        }
                    }
                }.disabled(laravelRunning || legacyRunning).frame(width: 150)
                
                VStack {
                    TextField(
                        "NextGen back-end directory",
                        text: $nextgen_be
                    )
                    TextField(
                        "NextGen front-end directory",
                        text: $nextgen_fe
                    )
                }
            }.padding().frame(alignment: .center)
            HStack {
                Button(laravelRunning ? "Stop SC Laravel" : "Start SC Laravel") {
                    if(!isRunning){
                        dispatchQueue.async {
                            // Clear output
                            self.output = "Starting containers..."
                            
                            self.output = $output.wrappedValue + "\n'docker compose -f \(laravel)docker-compose.yml up'"
                            
                            holder = dockerToggle(["compose" ,"-f", (laravel + "docker-compose.yml"), "up"], isRunning)
                            
                            sleep(2)
                            
                            laravelRunning = true
                            
                        }
                    } else {
                        dispatchQueue.async {
                            
                            self.output = "Stopping containers..."
                            
                            self.output = $output.wrappedValue + "\n'docker compose -f \(laravel)docker-compose.yml down'"
                            
                            holder = dockerToggle(["compose" ,"-f", (laravel + "docker-compose.yml"), "down"], isRunning)
                            
                            sleep(2)
                            
                            laravelRunning = false
                        }
                    }
                    
                }.disabled(nextGenRunning || legacyRunning).frame(width: 150)
                
                VStack {
                    TextField(
                        "Laravel directory",
                        text: $laravel
                    )
                }
            }.padding().frame(alignment: .center)
            HStack {
                Button(legacyRunning ? "Stop SM Legacy" : "Start SM Legacy") {
                    if(!isRunning){
                        dispatchQueue.async {
                            // Clear output
                            self.output = "Starting containers..."
                            
                            self.output = $output.wrappedValue + "\n'docker compose -f \(legacy_be)docker-compose.yml up'"
                            
                            holder = dockerToggle(["compose" ,"-f", (legacy_be + "docker-compose.yml"), "up"], isRunning)
                            
                            sleep(2)
                            
                            legacyRunning = true
                            
                        }
                    } else {
                        dispatchQueue.async {
                            
                            self.output = "Stopping containers..."
                            
                            self.output = $output.wrappedValue + "\n'docker compose -f \(legacy_be)docker-compose.yml down'"
                            
                            holder = dockerToggle(["compose" ,"-f", (legacy_be + "docker-compose.yml"), "down"], isRunning)
                            
                            sleep(2)

                            legacyRunning = false
                        }
                    }
                }.disabled(laravelRunning || nextGenRunning).frame(width: 150)
                VStack {
                    TextField(
                        "SM Legacy back-end directory",
                        text: $legacy_be
                    )
                    TextField(
                        "SM Legacy front-end directory",
                        text: $legacy_fe
                    )
                }
            }.padding().frame(alignment: .center)
            
            
            TextEditor(text: .constant(output))
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                )
                .padding()
                .id("verbose")
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).padding()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
