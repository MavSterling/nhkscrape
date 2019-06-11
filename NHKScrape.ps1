#NHK VOD Scraper v1.0
#By Holynub
#Please refer to the github notes or readme file for Installation/Usage/Modifications

#PART 1 - Setting up pre-requisite scripts/programs
#This script requires the following scripts/applications
#1. youtube-dl.exe - to download the videos
#2. ffmpeg - to fix/transcode the downloaded videos
#3. Selenium Webdriver.dll - To launch an automated web-browser from the script
#4. Chromedriver.exe - This is the browser we will be using to automate (If you'd like to use firefox you can, but you'll need to modify the script)

#Add the directories that contain youtube-dl, chromedriver.exe, and ffmpeg temporarily to the system Environmental Variables list
#This program assumes youtube-dl.exe, chromedriver.exe and the ffmpeg folder are both located in the current directory
$CurrentDirectory = [Environment]::CurrentDirectory
$Env:Path += "$CurrentDirectory;$CurrentDirectory\ffmpeg\bin"

#Add the Selenium Webdriver.dll to the working path
Add-Type -Path ".\WebDriver.dll"

#Part 2 - Taking in User Parameters
#Here we'll be asking the user both "What do you want to scrape?" as well as "Where do you want to put this?"
Write-Host "Please paste the NHK World Video On Demand Program URL you'd like to scrape"
Write-Host "These URL's typically look like: https://www3.nhk.or.jp/nhkworld/en/ondemand/program/video/drainspotters/?type=tvEpisode& "
$YourURL = Read-Host "URL"

#If you're comfortable with modifying the code, you can comment out the user prompt and just paste the link in the line below
#$YourURL = "https://www3.nhk.or.jp/nhkworld/en/ondemand/program/video/drainspotters/?type=tvEpisode&"

#Ask the user where the files will be saved too. This lets users save out to a separate directory/storage location that is separate from the working directory. Very helpful if you're saving to a NAS or external drive
Write-Host "Where would you like to save the files?"
Write-Host "Files saved will be placed in a series directory at the location provided"
$SavePath = Read-Host "Save Directory"

#If you're comfortabel with hard coding your save directory, you can comment out the lines above and hard coding your save path here
#$SavePath = [Environment]::CurrentDirectory


#Part 3 - Opening the NHK Website in Chrome using Selenium's driver
#In order to get the source code for the page we're trying to scrape, we need to have selenium/chrome render the page in its entirety

#Start a new instance of chrome using the Selenium drivers
$ChromeDriver = New-Object OpenQA.Selenium.Chrome.ChromeDriver

#Navigate to the URL provided by the User
$ChromeDriver.Navigate().GoToURL($YourURL)

#Part 4 - Scroll to the bottom of the page
#It sounds stupid, but we need to slowly scroll down to the bottom of the page in order to get the javascript to render all of the video URL's we'll be scraping
#Going too fast here will cause javascript to fail to load the video URL's. And the speed at which the javascript renders is varying from computer to computer and location to location

#We have to slow down in order to give chrome a chance to render any initial javascript on the page
#If your computer renders the page quickly when it comes up, you may be able to lower this value
Start-Sleep -Seconds 3

#In order to ensure we have the full page rendered we need to scroll to the bottom of the page
#We use the Chrome Driver to return the current "bottom" of the website and save that as the $lastHeight variable
$lastHeight = $ChromeDriver.ExecuteScript("return document.body.scrollHeight")

#Because we need to scroll slowly to the bottom, we'll start things off by scrolling about 1/10th of the way down the page.
#This initial increment is completely arbitrary. And you could go slower or faster if you feel comfortable. But I felt that scrolling in increments of 10% of the initial page size was simple enough
#This will cause some of the javascript to trigger and load the first set of video results
$newHeight = $lastHeight/10

#We're going to use this initial height increment as our value of how much we're going to scroll down at a time. 
#We don't want to use a static value because the page render height could be different depending on the page and possibly monitor resolution
#So by using an increment that's relative to the height of the page, we can ensure that it will always advance at a steady rate. 
$incrementHeight = $newHeight

#Using the Chrome Driver we'll scroll down to the first increment
$ChromeDriver.ExecuteScript("window.scrollTo(0, $incrementHeight);")

#Again, we have to slow down to let chrome render any javascript that might have been triggered by our scrolling. You're welcome to play with this variable.
#There are many variables as to how fast the page will render on your computer. so it is possible to change this value to increase operation speed
Start-Sleep -Seconds 3

#MAIN SCROLLING LOOP
#This while loop will continue to scroll down the page at the $incrementHeight rate until it hits the bottom
#We know we've hit the bottom when the $lastHeight is equal to (or less than?) the $newHeight
While ($lastHeight -igt $newHeight){

    #Because the page will be expanding as the javascript is rendered, we need to constantly update the $lastHeight variable, to make sure we know the value of the bottom of the page
    #Without doing this, the script could end pre-maturely
    $lastHeight = $ChromeDriver.ExecuteScript("return document.body.scrollHeight")

    #Use Selenium to scroll down to the $newHeight (This gets updated every loop)
    $ChromeDriver.ExecuteScript("window.scrollTo(0, $newHeight);")

    #As with the previous sleeps, this is to let Javascript render
    Start-Sleep -Seconds 1

    #We now increment the $newHeight so it can be scrolled down to in the next pass
    $newHeight = $newHeight+$incrementHeight
}

#Part 5 - Parsing the HTML 
#Now that we have the page, we need to extract the links to the videos

#Create an HTML variable to hold the Page Souce and apply functions to it
$ParseHTML = New-Object -ComObject "HTMLFile"
$ParseHTML.IHTMLDocument2_Write($ChromeDriver.PageSource)

#Because the links extracted are relative to the page source, we need to process them
#To accomplish this we need 2 arrays.
#The first holds the raw extracted links that are relative
$Links = @()
#The second array will hold the processed links that can be passed into youtube-dl.exe
$ExtractedLinks = @()

#First we search through the page source to find elements with the "c-item__title" which are the items generated by the javascript
#These elements contain the links to the videos in their .innerHTML attribute
#We take each of the .innerHTML values and add them to the $Links array
$ParseHTML.body.getElementsByClassName("c-item__title") | ForEach-Object {$Links += $_.innerHTML}

#Now we need to format the relative URLs in $Links by using string manipulation
#We store the formatted URL in the $ExtractedLinks array
#Here is an example of what the unprocessed links look like: <a href="/nhkworld/en/ondemand/video/2064014/">Keyword: Water Transport</a>
$Links | ForEach-Object {
    
    #We need to strip away the beginning part of the link and replace it with an absolute value
    $temp = $_ -replace '<A href="', 'https://www3.nhk.or.jp'
    
    #Next we need to truncate everything at the end of the string to obtain just the link
    #We do this by locating the first instance of the " character and creating a substring up to that character
    $temp = $temp.Substring(0, $temp.IndexOf('"'))
    
    #We add this formatted link to the $ExtractedLinks Array
    $ExtractedLinks += $temp
}

#This Debug Statement lets you see the links you've extracted from the web-page. Useful to see if you've gotten anything at all.
#Uncomment the next line to view
#echo $ExtractedLinks

#Part 6 Selenium Cleanup
#Now that we have the links extracted in an array, we no longer need the chrome instance running
#We execute the next set of code to end the Chrome Driver process. 
Function Stop-ChromeDriver{Get-Process -Name chromedriver -ErrorAction SilentlyContinue | Stop-Process -ErrorAction SilentlyContinue}
$ChromeDriver.Close()
$ChromeDriver.Quit()
Stop-ChromeDriver

#Part 7 Write Links to a file
#We are utilizing a parameter of youtube-dl.exe that takes in a file and reads in line-delimited URL's

#We will be using the .NET Streamwriter to create/overwrite the temp.txt file that is located in the current working directory
$FileStream = [System.IO.StreamWriter] "temp.txt"

#We then write the URL's one element at a time to the temp.txt using StreamWriter
$ExtractedLinks | % {
    
    #we use the .ToString function just to make sure the element being written to the file is a string and not a data structure
    #(It shouldn't be anything but a string, but you never know what sort of nonsense could happen)
    $FileStream.WriteLine($_.ToString())

}

#Close the temp.txt file so we can read from it in the next part
$FileStream.Close()

#Part 8 Actually downloading the videos
#Finally we can download the videos from the links we've extracted from the page.
#This is the most buggy part because youtube-dl sometimes has issues getting to the NHK server, this could be a result of anti-spam/copy protection

#I will try my best to explain how this works
#The youtube-dl.exe will try to save the files in the $SavePath and add the files to a Series directory.
#The series value is pulled from the NHK website
#The --no-overwrites is in place to skip files that have already been downloaded
# -c is to continue downloads in case you need to retry saving the file after an unexpected interruption from a previous pass
# --batch-file reads in the temp.txt to find the links we've extracted
# max and min sleep intervals are countermeasures against anti-spam protection on the web server side. These two values can be adjusted higher to try and prevent the web server from rejecting your requests
& youtube-dl.exe -o "$SavePath/%(series)s/%(title)s.%(ext)s" --no-overwrites -c --batch-file ".\temp.txt" --max-sleep-interval 30 --min-sleep-interval 5

#I put the pause at the end so you can see if there are any errors output from youtube-dl.exe
Pause

#Lastly, I like to clear the host just so you get a clean prompt. But this can be deleted or commented out if you don't want it.
Clear-Host