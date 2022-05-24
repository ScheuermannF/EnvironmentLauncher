# EnvironmentLauncher
A simple GUI for starting/stopping SchoolMint's various local development environments
<img width="1012" alt="Screen Shot 2022-05-24 at 3 42 43 PM" src="https://user-images.githubusercontent.com/84396585/170137724-0586f28b-de4c-407e-bd95-d6f74d5a4a6e.png">



### Before you begin, some notes
This is a WIP and you might encounter some bugs. If so, please leave a thread here on the GitHub repo or message me directly on slack at @Francis Scheuermann

* This app will only work if your 3 environments are already set up, prior to use (NextGen, Smartchoice, Schoolmint Legacy).

### Known Bugs
* Sometimes (even after supposedly fixing it) the CPU utlization will be high, but I'm looking into this. After starting OR stopping an environment, it will spike for a minute or so as it's doing tasks in the background, but SHOULD settle back to around 0% once it's done. Sometimes it doesn't settle, for a currently unknown reason.


### Setup / Installation

Since Apple is annoying about signing apps, I reccomend you clone the repo yourself and open the project in Xcode to build, compile, and export it yourself for personal use. Below are the instructions for doing so:

#### 1. Cloning the repo
This one is pretty self explanatory. I suggest using GitKraken or some other Git tool to clone the repo. It doesn't make a difference where, just make a note of where.


#### 2. Opening the project
Here, you want to have Xcode installed to be able to open the project. This app is built with Swift 5.6 and SwiftUI and was built for MacOS 12.3 and above.
You can get Xcode from the Mac App Store, it's a big app, so it might take some time.

Once you have Xcode installed, open it, and you should be greeted with a screen to either create, clone, or open a project. Select 'Open a project or file' and open the EnvironmentLauncher folder you cloned earlier.


#### 3. Building and testing
Now that the project is open you have access to all the files. I suggest testing the project here first before exporting it to a '.app'.
The app NEEDS to be built here but testing is optional, but reccomended. It is built automatically upon running!

* Clean the build folder with `Shift + Command + K` OR by selecting 'Clean Build Folder' in the taskbar in Product > Clean Build Folder
  * This is NOT necessary but can help if the project is failing to build

* Run the app with `Command + R` OR by selecting 'Run' in the taskbar in Product > Run OR by just pressing the Run button (looks like a play button)
  * First build might take a few seconds

* The app should (hopefully) be running now. Point the text fields to the location of your repos and press enter once you've filled it in, just to make sure the app saves the new location

* Now, press 'Start <environment>' for the environment you want to run. You can monitor the output while testing in the bottom right output section.
  
* If it works, great! You can continue to the next section to export the project to a '.app'
  * If it didn't work.. sorry I'm new to Mac App development. Skip to the Common Problems / Solutions section.
  

#### 4. Exporting the app
If you made it here, awesome. That means its working.

* To export the app for usage outside of Xcode, simply drag the app from the 'products' folder to desired location.
<img width="529" alt="Screen Shot 2022-05-24 at 3 17 59 PM" src="https://user-images.githubusercontent.com/84396585/170124764-ef79de9a-38f7-4544-875e-dae25addfde2.png">

Enjoy using the app!
  
##### 5. Common Problems & Solutions
In this section, you'll find some common problems I found when trying to get the app to work. Check here for possible solutions.
If none of these fix your problem, reach out to me via Slack at @Francis Scheuermann
  
* Make sure to use FULL path to the repo folders. For example, my environment repos are in my user directory inside of a folder called GitHub so my paths are `/Users/francisscheuermann/GitHub/<repo>`, the ~/ shortcut does not work.

* This app currently assumes the yarn and docker directories are in `/usr/local/bin` because this is the default location for these, if for whatever reason it's different, you can edit the environment variable in the code to point to the correct location as shown here:
<img width="895" alt="Screen Shot 2022-05-24 at 3 21 45 PM" src="https://user-images.githubusercontent.com/84396585/170125298-3e2ac51d-96ac-42f4-99ca-a8416533b58e.png">
 
* This line needs to be changed in 3 different places, each of the 3 functions has it! (Currently, lines 46, 94, and 139)

