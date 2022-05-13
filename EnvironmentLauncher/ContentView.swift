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
    
    @AppStorage("laravel") private var laravel : String = "/Users/francisscheuermann/GitHub/smartchoice-docker/"
    @AppStorage("legacy_fe") private var legacy_fe : String = "/Users/francisscheuermann/GitHub/schoolmint-fe/"
    @AppStorage("legacy_be") private var legacy_be : String = "/Users/francisscheuermann/GitHub/schoolmint-be/"
    @AppStorage("school_chooser") private var school_chooser : String = "/Users/francisscheuermann/GitHub/school-chooser/"
    @AppStorage("chooser_editor") private var chooser_editor : String = "/Users/francisscheuermann/GitHub/chooser-editor/"
    @AppStorage("nextgen_fe") private var nextgen_fe : String = "/Users/francisscheuermann/GitHub/enrollment-fe/"
    @AppStorage("nextgen_be") private var nextgen_be : String = "/Users/francisscheuermann/GitHub/enrollment-be/"
    
    func dockerToggle(_ command: [String], _ running: Bool) -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.arguments = command
        task.executableURL = URL(fileURLWithPath: "/usr/local/bin/docker" )
        
        
        do {
            try task.run()
        } catch {
            print("\(error)")
        }
        
        task.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        self.output = output
        
        
        
        isRunning = !running

        return output
    }
    
    func shell(_ command: [String], _ running: Bool) -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.arguments = command
        task.executableURL = URL(fileURLWithPath: "/bin/zsh")
        
        
        do {
            try task.run()
        } catch {
            print("\(error)")
        }
        

        let data = pipe.fileHandleForReading.availableData
        let output = String(data: data, encoding: .utf8)!
        
        self.output = output

        return output
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
                        nextGenRunning = true
                        self.output = dockerToggle(["compose" ,"-f", (nextgen_be + "docker-compose.yml"), "up", "-d"], isRunning)
                    
                        self.output = shell(["-c", "cd " + nextgen_fe + " && BROWSER=none yarn start"], isRunning)
                        
                    } else {
                        self.output = dockerToggle(["compose" ,"-f", (nextgen_be + "docker-compose.yml"), "down"], isRunning)
                        self.output = shell(["-c", "killall node"], isRunning)
                        nextGenRunning = false
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
                        laravelRunning = true
                        self.output = dockerToggle(["compose" ,"-f", (laravel + "docker-compose.yml"), "up", "-d"], isRunning)
                    } else {
                        self.output = dockerToggle(["compose" ,"-f", (laravel + "docker-compose.yml"), "down"], isRunning)
                        laravelRunning = false
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
                        legacyRunning = true
                        self.output = dockerToggle(["compose" ,"-f", (legacy_be + "docker-compose.yml"), "up", "-d"], isRunning)
                    
                        //self.output = shell(["-c", "cd " + nextgen_fe + " && BROWSER=none yarn start"], isRunning)
                        
                    } else {
                        self.output = dockerToggle(["compose" ,"-f", (legacy_be + "docker-compose.yml"), "down"], isRunning)
                        
                        //self.output = shell(["-c", "killall node"], isRunning)
                        legacyRunning = false
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
            
            TextField(
                $output.wrappedValue,
                text:$output
            )
            .textFieldStyle(.roundedBorder)
                .padding(20)
                .disabled(true)
                .lineLimit(5)
             
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
        }
    }
}
