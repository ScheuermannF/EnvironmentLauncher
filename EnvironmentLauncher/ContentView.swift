//
//  ContentView.swift
//  EnvironmentLauncher
//
//  Created by Francis Scheuermann on 5/10/22.
//

import SwiftUI

struct ContentView: View  {
    
    @State var output : String = ""
    @State var isRunning = false
    @State var laravelRunning = false
    @State var nextGenRunning = false
    @State var legacyRunning = false
    
    @State var holder = false;
    
    @State var outputPipe : Pipe!
    
    @AppStorage("laravel") private var laravel : String = "/Users/francisscheuermann/GitHub/smartchoice-docker/"
    @AppStorage("legacy_fe") private var legacy_fe : String = "/Users/francisscheuermann/GitHub/schoolmint-fe/"
    @AppStorage("legacy_be") private var legacy_be : String = "/Users/francisscheuermann/GitHub/schoolmint-be/"
    @AppStorage("school_chooser") private var school_chooser : String = "/Users/francisscheuermann/GitHub/school-chooser/"
    @AppStorage("chooser_editor") private var chooser_editor : String = "/Users/francisscheuermann/GitHub/chooser-editor/"
    @AppStorage("nextgen_fe") private var nextgen_fe : String = "/Users/francisscheuermann/GitHub/enrollment-fe/"
    @AppStorage("nextgen_be") private var nextgen_be : String = "/Users/francisscheuermann/GitHub/enrollment-be/"
    
    let dispatchQueue = DispatchQueue(label: "envLauncher.queue")
    
    
    
    func dockerToggle(_ command: [String], _ running: Bool) -> Bool {
        let task = Process()
        let pipe = Pipe()
        
        task.standardError = pipe
        task.standardOutput = pipe
        task.arguments = command
        task.executableURL = URL(fileURLWithPath: "/usr/local/bin/docker" )
        
        captureStandardOutputAndRouteToTextView(pipe)
        
        
        do {
            try task.run()
        } catch {
            print("\(error)")
            return false
        }
        
        isRunning = !running
        
        return true
    }
    
    func shell(_ command: [String], _ running: Bool) -> Bool {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = command
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        captureStandardOutputAndRouteToTextView(pipe)
        
        do {
            try task.run()
        } catch {
            print("\(error)")
            return false
        }
        
        return true
    }
    
    func captureStandardOutputAndRouteToTextView(_ outputPipe: Pipe) {
        //1.
        //outputPipe = Pipe()
        setvbuf(stdout, nil, _IONBF, 0)
        //task.standardOutput = outputPipe
        //task.standardError = outputPipe
        
        //2.
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        //3.
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            //4.
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            //5.
            DispatchQueue.main.async(execute: {
                self.output = $output.wrappedValue + "\n" + outputString
            })
            /*
             DispatchQueue.global(qos: .background).async(execute: {
             let previousOutput = $output.wrappedValue
             let nextOutput = previousOutput + "\n" + outputString
             self.output = nextOutput
             //self.output = nextOutput
             })
             */
            
            //6.
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            //if(!nextGenRunning && !laravelRunning && !legacyRunning) {
            //   self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
            //self.outputPipe.fileHandleForReading.readInBackgroundAndNotify()
            //}
            
        }
        
        
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
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\nDocker compose up successful."
                            } else {
                                self.output = $output.wrappedValue + "\nDocker compose failed...something went wrong."
                            }
                            
                        }
                        
                        dispatchQueue.async {
                            self.output = $output.wrappedValue + "\n\nStarting yarn..."
                            
                            self.output = $output.wrappedValue + "\n'yarn start'"
                            
                            holder = shell(["-c", "cd " + nextgen_fe + " && BROWSER=none yarn start"], isRunning)
                            
                            sleep(2)
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\nyarn start successful."
                                self.output = $output.wrappedValue + "\n\nEnvironment started. The site should be accessible shortly."
                            } else {
                                self.output = $output.wrappedValue + "\nyarn start failed...something went wrong."
                                self.output = $output.wrappedValue + "\n\nEnvironment startup incomplete. The site may be not be accessible."
                            }
                            
                            nextGenRunning = true
                        }
                        
                    } else {
                        dispatchQueue.async {
                            
                            self.output = "Stopping containers..."
                            
                            self.output = $output.wrappedValue + "\n'docker compose -f \(nextgen_be)docker-compose.yml down'"
                            
                            holder = dockerToggle(["compose" ,"-f", (nextgen_be + "docker-compose.yml"), "down"], isRunning)
                            
                            sleep(2)
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\nDocker compose down successful."
                            } else {
                                self.output = $output.wrappedValue + "\nDocker compose down failed...something went wrong."
                            }
                            
                        }
                        
                        dispatchQueue.async {
                            self.output = $output.wrappedValue + "\n\nKilling all node instances..."
                            
                            self.output = $output.wrappedValue + "\n'killall node'"
                            
                            holder = shell(["-c", "killall node"], isRunning)
                            
                            sleep(2)
                            
                            nextGenRunning = false
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\n\nEnvironment shutdown successfully."
                            } else {
                                self.output = $output.wrappedValue + "\n\nEnvironment shutdown completed, but might have not been successful.."
                            }
                            
                        }
                    }
                }.disabled(laravelRunning || legacyRunning).frame(width: 150)
                
                VStack {
                    TextField(
                        "t",
                        text: $nextgen_be
                    )
                    TextField(
                        "SC Laravel directory",
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
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\nDocker compose up successful."
                            } else {
                                self.output = $output.wrappedValue + "\nDocker compose failed...something went wrong."
                            }
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\n\nEnvironment started. The site should be accessible shortly."
                            } else {
                                self.output = $output.wrappedValue + "\n\nEnvironment startup incomplete. The site may be not be accessible."
                            }
                            
                            laravelRunning = true
                            
                        }
                    } else {
                        dispatchQueue.async {
                            
                            self.output = "Stopping containers..."
                            
                            self.output = $output.wrappedValue + "\n'docker compose -f \(laravel)docker-compose.yml down'"
                            
                            holder = dockerToggle(["compose" ,"-f", (laravel + "docker-compose.yml"), "down"], isRunning)
                            
                            sleep(2)
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\nDocker compose down successful."
                            } else {
                                self.output = $output.wrappedValue + "\nDocker compose down failed...something went wrong."
                            }
                            
                            laravelRunning = false
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\n\nEnvironment shutdown successfully."
                            } else {
                                self.output = $output.wrappedValue + "\n\nEnvironment shutdown completed, but might have not been successful.."
                            }
                        }
                    }
                    
                }.disabled(nextGenRunning || legacyRunning).frame(width: 150)
                
                VStack {
                    TextField(
                        "t",
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
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\nDocker compose up successful."
                            } else {
                                self.output = $output.wrappedValue + "\nDocker compose failed...something went wrong."
                            }
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\n\nEnvironment started. The site should be accessible shortly."
                            } else {
                                self.output = $output.wrappedValue + "\n\nEnvironment startup incomplete. The site may be not be accessible."
                            }
                            
                            legacyRunning = true
                            
                        }
                    } else {
                        dispatchQueue.async {
                            
                            self.output = "Stopping containers..."
                            
                            self.output = $output.wrappedValue + "\n'docker compose -f \(legacy_be)docker-compose.yml down'"
                            
                            holder = dockerToggle(["compose" ,"-f", (legacy_be + "docker-compose.yml"), "down"], isRunning)
                            
                            sleep(2)
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\nDocker compose down successful."
                            } else {
                                self.output = $output.wrappedValue + "\nDocker compose down failed...something went wrong."
                            }
                            
                            legacyRunning = false
                            
                            if(holder) {
                                self.output = $output.wrappedValue + "\n\nEnvironment shutdown successfully."
                            } else {
                                self.output = $output.wrappedValue + "\n\nEnvironment shutdown completed, but might have not been successful.."
                            }
                        }
                    }
                }.disabled(laravelRunning || nextGenRunning).frame(width: 150)
                VStack {
                    TextField(
                        "t",
                        text: $legacy_be
                    )
                    TextField(
                        "SC Laravel directory",
                        text: $legacy_fe
                    )
                }
            }.padding().frame(alignment: .center)
            
            
            TextEditor(text: .constant(output))
                .padding(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 1)
                    //.foregroundColor(Color(.placeholderText))
                )
                .padding()
                .id("verbose")
            /*
             TextField(
             $output.wrappedValue,
             text:$output
             )
             .textFieldStyle(PlainTextFieldStyle())
             .padding([.horizontal], 4)
             .cornerRadius(16)
             .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 2))
             .padding([.horizontal], 1)
             */
            
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
