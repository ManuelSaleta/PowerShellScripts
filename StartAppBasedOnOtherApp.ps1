####
# Simple script to start app2 if app1 is running else kill app2
# Pair this up with Windows event:
# https://community.spiceworks.com/how_to/123434-run-powershell-script-on-windows-event
# 2020 Saturday, was bored
####


#Paths; change to whatever paths of exes you want to use
#TODO: using absolute paths is bad for flexibility, find better way to get process without relying on path

$APP1 = "C:\Program Files (x86)\Heroes of the Storm\Versions\Base81376\HeroesOfTheStorm_x64.exe"
$APP2 = "C:\Program Files\YoloMouse\YoloMouse.exe"
$APP2_NAME = "YoloMouse"

#Functions 

# Takes in an absolute path file and return t/f if process is running
function IsRunning {
   Param($path) 
   return (get-wmiobject win32_process | ? { $_.Path -eq $path  } | measure-object | % { $_.Count }) -gt 0
}

function Start {
    Param($path)
    Start-Process -FilePath $path
}

# For some odd reason Stop-Process failes when called from a function.
#TODO: Figure out why 
function Kill {
    Param($name)

    Stop-Process -Name $name
} 



while ($true) 
{ 
    if ( IsRunning($APP1) ) 
    {
        Write-Output "Starting " + $APP2
        Start($APP2)
    }
    #app2 is running without app1
    elseif (IsRunning($APP2) -and IsRunning($APP1) -eq false )
    {
        #Not using Kill($) cuz it fails
        Stop-Process -Name $APP2_NAME
    }


    sleep -seconds 30 
}

