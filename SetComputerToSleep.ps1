# This is a script that automatically shuts your PC down
# Set to shutdown after 12pm on weekdays
#
#
#
#

#

$Utils = @'
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace PInvoke.Win32 {

    public static class UserInput {

        [DllImport("user32.dll", SetLastError=false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public int dwTime;
        }

        public static DateTime LastInput {
            get {
                DateTime bootTime = DateTime.UtcNow.AddMilliseconds(-Environment.TickCount);
                DateTime lastInput = bootTime.AddMilliseconds(LastInputTicks);
                return lastInput;
            }
        }

        public static TimeSpan IdleTime {
            get {
                return DateTime.UtcNow.Subtract(LastInput);
            }
        }

        public static int LastInputTicks {
            get {
                LASTINPUTINFO lii = new LASTINPUTINFO();
                lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
                GetLastInputInfo(ref lii);
                return lii.dwTime;
            }
        }
    }
}
'@

###SETUP###
#Lets you add a c# class
Add-Type -TypeDefinition $Utils


#make sure you can call class and methods
$idleTime = [PInvoke.Win32.UserInput]::IdleTime
$lastInput = [PInvoke.Win32.UserInput]::LastInput

#Ticks are 100 nano-second units 1 000 000 000 nano seconds in a second
#10 million ticks = 1 second  s = T/10,000,000
$lastInputTicks = [PInvoke.Win32.UserInput]::LastInputTicks

$date = Get-Date
$lastInputInSeconds = $lastInputTicks/10000000

Write-Output $lastInputInSeconds


#Setups a trigger to run on start up sequence 
#Add a random delay to avoid race conditions
$trigger = New-JobTrigger -AtStartup -RandomDelay 00:00:30
###SETUP###

#if hour between 12:00 - 12:59 
if ($date.Hour -eq 24 -and $date.Minute -lt 59)
{
    Write-Output "Its late..."
    #if NOT weekend
   if  ( $date.DayOfWeek.ToString() -ne "Saturday" -or $date.DayOfWeek.toString() -ne "Sunday" )
    {
        Write-Output "And a WeekDay..."
        
        #IF NO USER INPUT FOR 5 MINUTES RUN SHUTDOWN
        if ($idleTime -gt 5) {
            
            Start-Process -FilePath "C:\Windows\System32\shutdown.exe" -ArgumentList "-s -t 100"
            
            Write-Output "It is" $date.DateTime
            Write-Output "Time to go to bed... System shutdown in 10 seconds"
        }
        
    }
} else {
  Write-Output "Its Early or a weekendDay! "
}

