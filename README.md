# nhkscrape V1.0
### By Holynub/MavSterling 6/10/2019
### NHK Scraping tool for NHK World's On Demand Programs

## Pre-Requisite Scripts/Packages
1. Youtube-DL - https://ytdl-org.github.io/youtube-dl/download.html 
2. FFMPEG - https://ffmpeg.zeranoe.com/builds/
3. Selenium WebDriver - https://www.nuget.org/packages/Selenium.WebDriver
4. Selenium WebDriver Support - https://www.nuget.org/packages/Selenium.Support
5. ChromeDriver (Pay attention to the version number)- https://sites.google.com/a/chromium.org/chromedriver/
6. Chrome - Update your chrome client to the same version listed on the chromedriver website
7. Powershell Execution Policy must be set to either RemoteSigned or Unrestricted
9. Windows 10 running at least the .NET 4.5 Framework - This project was built using Powershell on my gaming workstation. However, you could take this workflow and modify it for BASH or MacOS it is definitely possible.
10. nhkscrape.ps1 script - Download it from this repository! (Or copy and paste into a new script file)

## Pre-Requisite Downloading/extracting

### Youtube-dl 

1. Download the windows exe link listed at the top of the website

### FFMPEG 

1. Download the most recent version for the windows 64-bit architecture
2. Unzip the file
3. Rename the unziped directory/folder to FFMPEG (Make sure this renamed folder contains the Bin, DOC, and presets directories)
	a) The folder structure should look like the following:
		
		FFMPEG\
			BIN\
			DOC\
			Presets\
			License.txt
			Readme.txt
		
### Selenium Packages - Instructions apply to both the Selenium WebDriver and the Support

1. On the download page, use the "Download package" link on the right side of the page under "Info"
2. This should download a selenium.webdriver.version.nupkg
3. If you use 7-Zip you can right click the file and unzip it
3b. Alternatively, you can rename the file extension to .ZIP and it will unzip like any other zip container
4. The DLL's and XML's required are located in the `Selenium.WebDriver.Version\lib\net45\` folder

### ChromeDriver

1. Go to your "About Google Chrome" page under Chrome settings
2. Take note of the version listed there
3. Go to the ChromeDriver download website and click the Driver version that is similar/same as yours
4. Download the chromedriver_win32.zip on the directory page
5. Unzip the file to access the chromedriver.exe

### Powershell's Execution Policy

1. Run a Powershell window as Administrator
2. run the following command: `Set-ExecutionPolicy RemoteSigned`
3. To confirm your ExecutionPolicy is correct you can check it by running: `Get-ExecutionPolicy`

## Script Setup

1. Create a new Directory to store all of the pre-requisite files/scripts.
2. Place the following executibles in the directory:
	1. youtube-dl.exe
	2. chromedriver.exe
	3. WebDriver.dll
	4. WebDriver.Support.Dll
	5. Webdriver.xml (Not really sure if this is really needed, but its in the same folder)
	6. WebDriver.Support.xml (Agauin, not really sure if its NEEDED, but meh.)
	7. NHKScrape.ps1
	8. The extracted ffmpeg folder.

## Running the Script

1. Open your script directory in a file explorer
2. Press Shift and Right click in the folder window.
3. Click "Open Powershell window here"
4. Your prompt should be in the directory with the NHKScrape.ps1 script
5. Type in :`.\NHKScrape.PS1`
6. Enter the URL of the NHK Program you're looking to download
7. Enter the path you're looking to save your files
8. The script should run and you can either watch the script or let it run while you do something else

## Known Bugs/Issues

1. Sometimes the NHK World program page will load with 0 hits
	- This sometimes happens at random. I haven't figured out a good way to get past it. But if you run the script a 2nd time, it usually fixes itself.
2. Youtube-dl error gives a bad gateway
	- I don't know for certain, but I think this error could be an anti-spam measure by the NHK World Webserver. So it denies the connection. I put in a delay inbetween video files, but you may want to edit the script and try increasing the values. Alternatively, you could add a proxy list to your youtube-dl parameters. I haven't used a proxy list before, but it should work? Maybe?

## About

This project was started because of the inability to find older NHK World videos and documentaries. Most programs shown on NHK World are taken down after about a year from the original airing date. NHK does not provide any alternative locations to view/purchase these videos and many become lost media. There is a small group of archivists that are trying to preserve these videos, however I felt there was a need to more easily archive the video programming listed on the NHK World website. And so, this script was created.

The script in this project was built on Powershell because the original concept was a to be a quick and dirty scrape of the NHK World Video On Demand site. However, there were a few road blocks that made things a bit tricky. Originally, the script was designed to read in a csv file containing all of the URL's of the videos to download off the NHK website. However, I found myself sometimes messing that up and manually copy and pasting links into a CSV file was tedious. I thought to myself, "Maybe there's a better way?" and "It can't be that hard to just comb through the page source to find the links and add them to a queue." A good number of hours and searching later, I have "finished" at the script you're seeing now.

The biggest challenge was being able to pull the URL's from the NHK Video Program website and put them into a list. The website uses javascript to query their video database and render the links on the page dynamically. HOWEVER, the javascript does not pull all of the videos at one time either. It will only query for a new set of videos if the browser has scrolled down to the end of the current set of results. This means, in order to scrape the website for the video URL's, the entire page must be scrolled through and rendered. This has taken me down the rabbit hole of using the Selenium web browser automation package and browser automation. I also ran into difficulty because I was/am adamant in using Powershell for this script, and many of the resources for the selenium packages/documentation were designed for more traditional languages like Java, Python, or C#.

Eventually, I was able to launch a chrome browser via the command line and have it scroll through the website, to which I then was able to scrape the links off the pages. From there, I utilized the youtube-dl utility to actually download the videos off their respective URL's. And the end result is the script you have here.

For all of my fellow archivists, please feel free to take this script and make modifications for use in any of your use cases. I started this project because I felt that these great shows/documentaries were going to become lost media. There might be another website out there that you feel the same. And hopefully this script can give you some ideas as to how you can preserve the content before its lost.

## Credits

Major shout out to: Mavericksevermont and their article on using powershell and Selenium. Without it, I would still be here banging my head against my keyboard trying to figure out how to get it to work. https://tech.mavericksevmont.com/blog/powershell-selenium-automate-web-browser-interactions-part-i/

All of the billiion Stack Overflow articles on random stupid problems I had.
