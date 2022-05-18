# EnvironmentLauncher
A simple GUI for starting/stopping SchoolMint's various local development environments



### Before you begin, some notes
This is a WIP and you might encounter some bugs. If so, please leave a thread here on the GitHub repo or message me directly on slack at @Francis Scheuermann

* This app will only work if your 3 environments are already set up, prior to use (NextGen, Smartchoice, Schoolmint Legacy).


### Setup / Installation

Since Apple is annoying about signing apps, I reccomend you clone the repo yourself and open the project in Xcode to build, compile, and archive it yourself for personal use. Below are the instructions for doing so:

#### 1. Cloning the repo
This one is pretty self explanatory. I suggest using GitKraken or some other Git tool to clone the repo. It doesn't make a difference where, just make a note of where.


#### 2. Opening the project
Here, you want to have Xcode installed to be able to open the project. This app is built with Swift 5.6 and SwiftUI and was built for MacOS 12.3 and above.
You can get Xcode from the Mac App Store, it's a big app, so it might take some time.

Once you have Xcode installed, open it, and you should be greeted with a screen to either create, clone, or open a project. Select 'Open a project or file' and open the EnvironmentLauncher folder you cloned earlier.


#### 3. Building and testing
Now that the project is open you have access to all the files. I suggest testing the project here first before exporting(archiving) it to a '.app'.

* Clean the build folder with `Shift + Command + K` OR by selecting 'Clean Build Folder' in the taskbar in Product > Clean Build Folder
  * This is NOT necessary but can help if the project is failing to build

* Run the app with `Command + R` OR by selecting 'Run' in the taskbar in Product > Run OR by just pressing the Run button (looks like a play button)
  * First build might take a few seconds

* The app should (hopefully) be running now. Point the text fields to the location of your repos and press enter once you've filled it in, just to make sure the app saves the new location

* Now, press 'Start <environment>' for the environment you want to run. You can monitor the output while testing in the bottom right output section.
  
* If it works, great! You can continue to the Archiving section to export the project to a '.app'
  * If it didn't work.. sorry I'm new to Mac App development. Skip to the Common Problems / Solutions section.
  

#### 4. Archiving the app
If you made it here, awesome. That means its working.

* To archive the app for usage outside of Xcode, simply select 'Archive' in the Product menu.
* This will take a moment, but once done, it will open a window showing you your archives of this project. You should only have one.
* Select the archive and then press 'Distribute App' (The big blue button on the right)
* Select 'Copy App' and press Next
* Choose a location to save the .app to and press Export.
  
#### 5. Setting Permissions
Great, now you have a .app archive of this application, you can move the .app anywhere you like (Applications folder if you want to keep it in your dock)
Now we need to make sure the app has permissions that it might need.
  
* Open you Mac's System Preferences and navigate to Security & Privacy
* Navigate to the Privacy tab and find the 'Full Disk Acess' entry
* Click the lock in the bottom left and enter your Mac's password, then press the '+' button below the list of apps to the right
* Point it to your EnvironmentLauncher.app and make sure once it's added, the blue checkmark is there
* Click the lock again to re-lock your settings and then you should be good to go!
  
Enjoy using this app!
  
##### 5. Common Problems & Solutions
In this section, you'll find some common problems I found when trying to get the app to work. Check here for possible solutions.
If none of these fix your problem, reach out to me via Slack at @Francis Scheuermann
  
* Make sure to use FULL path to the repo folders. For example, my environment repos are in my user directory inside of a folder called GitHub so my paths are `/Users/francisscheuermann/GitHub/<repo>`, the ~/ shortcut does not work.

* This app currently assumes the yarn and docker directories are in `/usr/local/bin` because this is the default location for these, if for whatever reason it's different, you can edit the $PATH variable in the Xcode project by navigating to Product > Schemes > edit schemes and create a new environment variable as shown in the photo below:
<img width="949" alt="Screen Shot 2022-05-17 at 9 23 35 PM" src="https://user-images.githubusercontent.com/84396585/168944319-9bd92544-0c78-4ce1-bbea-a07b183efe76.png">

