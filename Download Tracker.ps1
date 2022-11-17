#
# Download Tracker - Update Custom Fields with username/datetime of last download
# to make it easier to track dead certificates people are blindly renewing...
#
$Script:AdaptableTmpVer = "202101281025"
#
$Script:AdaptableAppVer = "202211171625"
$Script:AdaptableAppDrv = "Download Tracker"

<#

Adaptable Application Fields are defined one per line below in the following format:
 [Field Name] | [Field Label] | [Binary/Boolean Flags]
    flag #1: Enabled? (Will not be displayed if 0)
    Flag #2: Mandatory?

You cannot add to, change, or remove the field names. Enable or disable as needed.

-----BEGIN FIELD DEFINITIONS-----
Text1|Username Field GUID|11
Text2|Date/Time Field GUID|11
Text3|Text Field #3|00
Text4|Text Field #4|00
Text5|Text Field #5|00
Text6|Text Field #6|00
Text7|Text Field #7|00
Text8|Text Field #8|00
Text9|Text Field #9|00
Text10|Text Field #10|00
Text11|Text Field #11|00
Text12|Text Field #12|00
-----END FIELD DEFINITIONS-----
#>

<######################################################################################################################
.NAME
    Perform-Action
.DESCRIPTION
    Performs an action in response to the logging of an event by Trust Protection Platform.
.PARAMETER General
    A hashtable containing the general set of variables needed by all or most functions
        ServiceAddress : a string identifying the service endpoint (URL, host, port, etc) of the calling Adaptable Log Channel object
        UserName : a string containing the username portion of the credential assigned to the Adaptable Log Channel object
        UserPass : a string containing the password portion of the credential assigned to the Adaptable Log Channel object
.PARAMETER Event
    A hashtable containing the standard set of values captured when events are logged by Trust Protection Platform 
        ID : integer that uniquely identifies the event
        Name : string that briefly describes the meaning of the event
        Description : string that translates raw event data into meaningful human readable text
        Severity : 1 (Emergency), 2 (Alert), 3 (Critical), 4 (Error), 5 (Warning), 6 (Notice), 7 (Info), 8 (Debug)
        ServerDate : the date/time that the event was recorded by the log server
        ClientDate : the date/time that the event occurred
        SourceIP : the IP address of the TPP server where the event occurred
        Component : distiguished name of the TPP object responsible for logging the event
        Grouping : a numeric identifier that can be used to group related events
        Text1 : string variable whose meaning varies by event definition (255 character maximum)
        Text2 : string variable whose meaning varies by event definition (255 character maximum)
        Value1 : integer variable whose meaning varies by event definition (32-bit)
        Value2 : integer variable whose meaning varies by event definition (32-bit)
        Data : byte array variable generally used to capture larger amounts of data (1536 byte maximum)
.PARAMETER Fields
    A hashtable containing all of the extra field values specified on the Adaptable Log Channel object.
        Text1 : a string value for the first text extra field defined by the header at the top of this script
        Text2 : a string value for the second text extra field defined by the header at the top of this script
        ...
        Text12 : a string value for the twelfth text extra field defined by the header at the top of this script
.NOTES
    Returns...
        Result : 'Success' to indicate the non-error completion state
        Updates : (optional) hashtable of attribute name-value pairs pertaining to the Event.Component that
            specify what the driver will update when the Result is 'Success'
######################################################################################################################>
function Perform-Action
{
    Param(
        [Parameter(Mandatory=$true,HelpMessage="General Parameters")]
        [System.Collections.Hashtable]$General,
        [Parameter(Mandatory=$true,HelpMessage="Event Detail Parameters")]
        [System.Collections.Hashtable]$Event,
        [Parameter(Mandatory=$true,HelpMessage="Extra Field Parameters")]
        [System.Collections.Hashtable]$Fields
    )

    Initialize-VenDebugLog -General $General -LogClass LogMsg

    Write-VenDebugLog "Last Downloaded On GUID: $($Fields.Text2)"
    Write-VenDebugLog "Last Downloaded By GUID: $($Fields.Text1)"
    Write-VenDebugLog "Downloaded On: $($Event.ServerDate)"
    Write-VenDebugLog "Downloaded By: $($Event.Text1)"

    return @{ Result="Success"; Updates=@{"$($Fields.Text1)"="$($Event.Text1)"; "$($Fields.Text2)"="$($Event.ServerDate)"} }
}

#
# Code below this marker is not called directly by Venafi
# Place your internal support calls below this marker
#



#
# Private functions for this application driver
#

# Take a message, prepend a timestamp, output it to a debug log ... if DEBUG_FILE is set
# Otherwise do nothing and return nothing
function Write-VenDebugLog
{
    Param( [Parameter(Position=0, Mandatory)][string]$LogMessage )

    filter Add-TS {"$(Get-Date -Format o): $_"}

    # do nothing and return immediately if debug isn't on
    if ($DEBUG_FILE -eq $null) {
        return
    }
    
    # if the logfile isn't initialized then just crash now
    if ($Script:venDebugFile -eq $null) {
        throw("Call to Write-VenDebugLog() but logfile has not been initialized...")
    }

    # write the message to the debug file
    Write-Output "$($LogMessage)" | Add-TS | Add-Content -Path $Script:venDebugFile
}

function Initialize-VenDebugLog
{
    Param(
        [Parameter(Position=0, Mandatory)][System.Collections.Hashtable]$General,
        [String]$LogClass=$null
    )

    # do nothing and return immediately if debug isn't on
    if ($DEBUG_FILE -eq $null) {
        return
    }

    if ($Script:venDebugFile -ne $null) {
        Write-VenDebugLog "WARNING: Initialize-VenDebugLog() called more than once!"
        return
    }

    $Script:venDebugFile = "$(Split-Path -Path $DEBUG_FILE)\$($Script:AdaptableAppDrv)"
    if (($General.HostAddress -ne '') -and ($General.HostAddress -ne $null)) {
        $Script:venDebugFile += "-$($General.HostAddress)"
    }
    if ($LogClass -ne '') {
        $Script:venDebugFile += "-$($LogClass)"
    }
    $Script:venDebugFile += ".log"
    
    Write-Output "" | Add-Content -Path $Script:venDebugFile
    Write-VenDebugLog "$($Script:AdaptableAppDrv) v$($Script:AdaptableAppVer): Venafi called $((Get-PSCallStack)[1].Command)"
    Write-VenDebugLog "PowerShell Environment: $($PSVersionTable.PSEdition) Edition, Version $($PSVersionTable.PSVersion.Major)"
}

# END OF SCRIPT
