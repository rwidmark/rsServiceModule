Function Get-ReturnMessageTemplate {
    <#
        .SYNOPSIS
        Return messages and value in the correct format

        .DESCRIPTION
        This function will return value and messages in the correct format that are needed for some of my modules.

        .PARAMETER ReturnType

        .PARAMETER Message

        .PARAMETER ReturnValue

        .EXAMPLE

        .LINK
        https://github.com/rstolpe/rsServiceModule/blob/main/README.md

        .NOTES
        Author:         Robin Stolpe
        Mail:           robin@stolpe.io
        Blog:           https://stolpe.io
        Twitter:        https://twitter.com/rstolpes
        Linkedin:       https://www.linkedin.com/in/rstolpe/
        GitHub:         https://github.com/rstolpe
        PSGallery:      https://www.powershellgallery.com/profiles/rstolpe
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, HelpMessage = "What kind of message do you want template for")]
        [ValidateSet("Error", "Success", "Warning", "Information")]
        [string]$ReturnType,
        [Parameter(Mandatory = $false, HelpMessage = "Message that you want to return")]
        $Message = "N/A",
        [Parameter(Mandatory = $false, HelpMessage = "Return value that you want to present for the user, not return message.")]
        $ReturnValue = "N/A"
    )

    Switch ($ReturnType) {
        Error {
            return [PSCustomObject]@{
                ReturnCode  = 1
                Severity    = "Error"
                Icon        = "xmark"
                IconColor   = "red"
                Color       = 'red'
                Duration    = "4000"
                Message     = $Message
                ReturnValue = $ReturnValue
            }
            Break
        }
        Success {
            return [PSCustomObject]@{
                ReturnCode  = 0
                Severity    = "Success"
                Icon        = "Check"
                IconColor   = "green"
                Color       = 'green'
                Duration    = "4000"
                Message     = $Message
                ReturnValue = $ReturnValue
            }
            Break
        }
        Warning {
            return [PSCustomObject]@{
                ReturnCode  = 2
                Severity    = "Warning"
                Icon        = "TriangleExclamation"
                IconColor   = "yellow"
                Color       = 'yellow'
                Duration    = "4000"
                Message     = $Message
                ReturnValue = $ReturnValue
            }
            Break
        }
        Information {
            return [PSCustomObject]@{
                ReturnCode  = 3
                Severity    = "Info"
                Icon        = "CircleInfo"
                IconColor   = "blue"
                Color       = 'blue'
                Duration    = "4000"
                Message     = $Message
                ReturnValue = $ReturnValue
            }
            Break
        }
    }
}
Function Convert-WhiteSpaceToDot {
    <#
        .SYNOPSIS
        If string or response only return whitespace this function will convert it to a dot
        
        .DESCRIPTION
        As PSU can't handle white space and mess the GUI up this function will return a . (dot) instead of white space
        if that's the only thing in the string.

        .PARAMETER String
        Your string you want to check
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false, HelpMessage = "Enter the string you want to check for white space")]
        $String,
        [Parameter(Mandatory = $false, HelpMessage = "If this is used it will return a . if the input is empty, null or whitespace")]
        [Switch]$Dot
    )

    try {
        if ([string]::IsNullOrEmpty($String) -or [string]::IsNullOrWhiteSpace($String)) {
            if ($Dot -eq $true) {
                "."
            }
            else {
                "N/A"
            }
        }
        else {
            $String
        }
    }
    catch {
        "N/A"
    }
}
Function Write-rsPSULog {
    <#
    Log used for PowerShell Universal
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Name of the Log you want to log to.")]
        [String]$LogName,
        [Parameter(Mandatory = $true, HelpMessage = "What type of log you want to use.")]
        [ValidateSet("App", "InvokedScript", "API", "ScheduledScript")]
        [String]$Type,
        [Parameter(Mandatory = $true, HelpMessage = "Enter eventlog entry type you want to use, default is Information.")]
        [ValidateSet("information", "Warning", "Error", "SuccessAudit", "FailureAudit")]
        [alias('Level')]
        [System.Diagnostics.EventLogEntryType]$EntryType = [System.Diagnostics.EventLogEntryType]::Information,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the eventID you want to use.")]
        [ValidateNotNullOrEmpty()]
        [alias('EventID')]
        [int]$ID,
        [Parameter(Mandatory = $true, HelpMessage = "This is the message that will be displayed in the eventlog.")]
        [ValidateNotNullOrEmpty()]
        [String]$Message,
        [Parameter(Mandatory = $true, HelpMessage = "Information gathered from the script etc. that you want to store in the eventlog data parameters")]
        [PSCustomObject]$LogInformation,
        [Parameter(Mandatory = $false, HelpMessage = "Pass error exception information to the log")]
        $LastException,
        [Parameter(Mandatory = $false, HelpMessage = "Use this is you want to return the error message as variabel instead of using throw")]
        [Switch]$ErrorReturn = $false
    )

    # If it's not a user that have invoked the function Local IP will not be displayed, also handeling empty string.
    $PSUHostIP = If ([string]::IsNullOrEmpty($LocalIpAddress)) {
        Convert-WhiteSpaceToDot -String $LocalIpAddress
    }
    else {
        "$($LocalIpAddress.Replace('::ffff:', ''))"
    }

    # Create empty object to collect all logdata in
    $LogData = [PSCustomObject]@{
    }

    $LogPSUData = [PSCustomObject]@{
        Severity        = $(Convert-WhiteSpaceToDot -String $EntryType)
        TimeStamp       = $(Convert-WhiteSpaceToDot -String $(Get-Date -Format "yyyy/dd/MM HH:mm:ss:ms K"))
        PSU_Host_Name   = [System.Net.Dns]::GetHostName()
        PSU_Host_IP     = $(Convert-WhiteSpaceToDot -String $PSUHostIP)
        PSU_Type        = $(Convert-WhiteSpaceToDot -String $Type)
        PSU_Environment = $(Convert-WhiteSpaceToDot -String $PSUEnvironment)
        PSU_EndPointID  = $(Convert-WhiteSpaceToDot -String $Endpoint.Name)
    }

    # Add ScriptData to LogData
    foreach ($_data in $LogPSUData.PSObject.Properties) {
        if ($_data.value -notlike "N/A") {
            $LogData | Add-Member -MemberType NoteProperty -Name $_data.name -Value $_data.value
        }
    }

    # Adds more parameters to LogDataInformation Depending on what type of log it is
    $LogSpecificData = Switch -WildCard ($Type) {
        "App" {
            # If it's not a user that have invoked the function Remote IP will not be displayed, also handeling empty string.
            $OperatorIP = If ([string]::IsNullOrEmpty($RemoteIpAddress)) {
                Convert-WhiteSpaceToDot -String $RemoteIpAddress
            }
            else {
                "$($RemoteIpAddress.Replace('::ffff:', ''))"
            }

            [PSCustomObject]@{
                PSU_App_Name       = $(Convert-WhiteSpaceToDot -String $DashboardName)
                PS_Module          = $(Convert-WhiteSpaceToDot -String $LogInformation.PS_Module)
                PS_Function        = $(Convert-WhiteSpaceToDot -String $LogInformation.PS_Function)
                Invoking_User      = if (-Not([string]::IsNullOrEmpty($Global:OperatorUser))) { $(Convert-WhiteSpaceToDot -String $Global:OperatorUser) } else { $(Convert-WhiteSpaceToDot -String $User) }
                Invoking_User_Role = $(Convert-WhiteSpaceToDot -String $($Role | Out-String))
                Invoking_User_IP   = $OperatorIP
            }
        }
        "*Script" {
            [PSCustomObject]@{
                Job_ID               = $(Convert-WhiteSpaceToDot -String $LogInformation.UAJob.Id)
                Job_StartTime        = $(Convert-WhiteSpaceToDot -String $LogInformation.UAJob.StartTime)
                Job_EndTime          = $(Convert-WhiteSpaceToDot -String $LogInformation.UAJob.EndTime)
                Job_Roles            = $(Convert-WhiteSpaceToDot -String $LogInformation.UAJob.Roles)
                Script_ID            = $(Convert-WhiteSpaceToDot -String $LogInformation.UAScript.Id)
                Script_Name          = $(Convert-WhiteSpaceToDot -String $LogInformation.UAScript.Name)
                Script_PSU_Path      = $(Convert-WhiteSpaceToDot -String $LogInformation.UAScript.FullPath)
                Script_Resolved_Path = $(Convert-WhiteSpaceToDot -String $LogInformation.UAScript.ResolvedPath)
                Script_Environment   = $(Convert-WhiteSpaceToDot -String $LogInformation.UAScript.Environment)
                Script_Description   = $(Convert-WhiteSpaceToDot -String $LogInformation.UAScript.Description)
            }
        }
        "API" {
            [PSCustomObject]@{
                Job_ID             = $(Convert-WhiteSpaceToDot -String $LogInformation.UAJob.Id)
                Job_StartTime      = $(Convert-WhiteSpaceToDot -String $LogInformation.UAJob.StartTime)
                Job_EndTime        = $(Convert-WhiteSpaceToDot -String $LogInformation.UAJob.EndTime)
                Script_ID          = $(Convert-WhiteSpaceToDot -String $LogInformation.UAScript.Id)
                Script_Name        = $(Convert-WhiteSpaceToDot -String $LogInformation.UAScript.Name)
                Script_Path        = $(Convert-WhiteSpaceToDot -String $LogInformation.UAScript.FullPath)
                Script_Environment = $(Convert-WhiteSpaceToDot -String $LogInformation.UAScript.Environment)
            }
        }
    }

    # Add LogSpecificData to LogData
    foreach ($_data in $LogSpecificData.PSObject.Properties) {
        if ($_data.Value -notlike "N/A") {
            $LogData | Add-Member -MemberType NoteProperty -Name $_data.name -Value $_data.value
        }
    }

    $LogDynamicData = [PSCustomObject]@{
        Against_System      = $(Convert-WhiteSpaceToDot -String $LogInformation.Against_System)
        Against_SystemInfo  = $(Convert-WhiteSpaceToDot -String $LogInformation.Against_SystemInfo)
        Action              = $(Convert-WhiteSpaceToDot -String $LogInformation.Action)
        Affected_ObjectType = $(Convert-WhiteSpaceToDot -String $LogInformation.Affected_ObjectType)
        Affected_Name       = $(Convert-WhiteSpaceToDot -String $LogInformation.Affected_Name)
        Target_ObjectType   = $(Convert-WhiteSpaceToDot -String $LogInformation.Target_ObjectType)
        Target_Name         = $(Convert-WhiteSpaceToDot -String $LogInformation.Target_Name)
        Message             = $(Convert-WhiteSpaceToDot -String $Message)
    }

    # Add LogDynamicData to LogData
    foreach ($_data in $LogDynamicData.PSObject.Properties) {
        if ($_data.Value -notlike "N/A") {
            $LogData | Add-Member -MemberType NoteProperty -Name $_data.name -Value $_data.value
        }
    }

    # Build error information if error are logged
    if ($EntryType -eq "Error") {
        if ($LastException.ErrorRecord) {
            #PSCore Error
            $LastError = $LastException.ErrorRecord
        }
        else {
            #PS 5.1 Error
            $LastError = $LastException
        }
        if ($LastException.InvocationInfo.MyCommand.Version) {
            $version = $LastError.InvocationInfo.MyCommand.Version.ToString()
        }
        $LogLastErrorData = [PSCustomObject]@{
            ExceptionMessage    = $LastError.Exception.Message
            ExceptionSource     = $LastError.Exception.Source
            ExceptionStackTrace = $LastError.Exception.StackTrace
            PositionMessage     = $LastError.InvocationInfo.PositionMessage
            InvocationName      = $LastError.InvocationInfo.InvocationName
            MyCommandVersion    = $version
            ScriptName          = $LastError.InvocationInfo.ScriptName
        }

        # Add LogLastErrorData to LogData
        foreach ($_data in $LogLastErrorData.PSObject.Properties) {
            $LogData | Add-Member -MemberType NoteProperty -Name $_data.name -Value $_data.value
        }
        $Message = "$($Message)`n`n== Error Message ==`n`n$($LogLastErrorData.ExceptionMessage)"
    }
    
    # Converting logdata
    [String[]]$LogData = foreach ($_log in $LogData.PSObject.Properties) {
        "$($_log.name) = $($_log.value)"
    }

    # Safty check if it's not running on Windows system it will create logs in text files
    if ($IsWindows -eq $true) {
        if ([string]::IsNullOrEmpty($LogName)) {
            $LogName = "$($SystemConfig.LogName)"
        }

        # If LogName don't exist as log in EventLog then it will create it
        if ($([System.Diagnostics.EventLog]::Exists("$LogName"); ) -eq $false) {
            New-EventLog -LogName $LogName
        }

        # If source don't exists on the host it will name it as Missing instead
        if ($([System.Diagnostics.EventLog]::SourceExists("$Type"); ) -eq $false) {
            $Type = "Missing"
        }

        $Event = [System.Diagnostics.EventLog]::new()
        $Event.Log = $LogName
        $EventInstance = [System.Diagnostics.EventInstance]::new($ID, $Category, $EntryType)
        $Event.Source = $Type

        # Joining the log message to one array to write to EventLog
        [Array]$JoinedMessage = @(
            $Message
            $LogData | ForEach-Object { $_ }
        )

        try {
            $Event.WriteEvent($EventInstance, $JoinedMessage)
        }
        catch {
            Write-Warning "Write-Event - Couldn't create new event - $($_.Exception.Message)"
        }
    }

    if ($EntryType -eq "Error") {
        if ($ErrorReturn -eq $true) {
            return $LogLastErrorData.ExceptionMessage
        }
        else {
            throw $LogLastErrorData.ExceptionMessage
        }
    }
}
Function Write-rsPWSHLog {
    <#
    Log used for PowerShell module
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Name of the Log you want to log to.")]
        [String]$LogName = "rsService",
        [Parameter(Mandatory = $true, HelpMessage = "Enter EventLog entry type you want to use, default is Information.")]
        [ValidateSet("information", "Warning", "Error", "SuccessAudit", "FailureAudit")]
        [alias('Level')]
        [System.Diagnostics.EventLogEntryType]$EntryType = [System.Diagnostics.EventLogEntryType]::Information,
        [Parameter(Mandatory = $true, HelpMessage = "Enter the eventID you want to use.")]
        [ValidateNotNullOrEmpty()]
        [alias('EventID')]
        [int]$ID,
        [Parameter(Mandatory = $true, HelpMessage = "This is the message that will be displayed in the EventLog.")]
        [ValidateNotNullOrEmpty()]
        [String]$Message,
        [Parameter(Mandatory = $true, HelpMessage = "Information gathered from the script etc. that you want to store in the EventLog data parameters")]
        [PSCustomObject]$LogInformation,
        [Parameter(Mandatory = $false, HelpMessage = "Pass error exception information to the log")]
        $LastException,
        [Parameter(Mandatory = $false, HelpMessage = "Use this is you want to return the error message as variabel instead of using throw")]
        [Switch]$ErrorReturn = $false
    )

    # Create empty object to collect all logdata in
    $LogData = [PSCustomObject]@{
    }

    $LogPSUData = [PSCustomObject]@{
        Severity  = $(Convert-WhiteSpaceToDot -String $EntryType)
        TimeStamp = $(Convert-WhiteSpaceToDot -String $(Get-Date -Format "yyyy/dd/MM HH:mm:ss:ms K"))
    }

    # Add ScriptData to LogData
    foreach ($_data in $LogPSUData.PSObject.Properties) {
        if ($_data.value -notlike "N/A") {
            $LogData | Add-Member -MemberType NoteProperty -Name $_data.name -Value $_data.value
        }
    }

    $LogDynamicData = [PSCustomObject]@{
        Against_System      = $(Convert-WhiteSpaceToDot -String $LogInformation.Against_System)
        Against_SystemInfo  = $(Convert-WhiteSpaceToDot -String $LogInformation.Against_SystemInfo)
        Action              = $(Convert-WhiteSpaceToDot -String $LogInformation.Action)
        Affected_ObjectType = $(Convert-WhiteSpaceToDot -String $LogInformation.Affected_ObjectType)
        Affected_Name       = $(Convert-WhiteSpaceToDot -String $LogInformation.Affected_Name)
        Target_ObjectType   = $(Convert-WhiteSpaceToDot -String $LogInformation.Target_ObjectType)
        Target_Name         = $(Convert-WhiteSpaceToDot -String $LogInformation.Target_Name)
        Message             = $(Convert-WhiteSpaceToDot -String $Message)
    }

    # Add LogDynamicData to LogData
    foreach ($_data in $LogDynamicData.PSObject.Properties) {
        if ($_data.Value -notlike "N/A") {
            $LogData | Add-Member -MemberType NoteProperty -Name $_data.name -Value $_data.value
        }
    }

    # Build error information if error are logged
    if ($EntryType -eq "Error") {
        if ($LastException.ErrorRecord) {
            #PSCore Error
            $LastError = $LastException.ErrorRecord
        }
        else {
            #PS 5.1 Error
            $LastError = $LastException
        }
        if ($LastException.InvocationInfo.MyCommand.Version) {
            $version = $LastError.InvocationInfo.MyCommand.Version.ToString()
        }
        $LogLastErrorData = [PSCustomObject]@{
            ExceptionMessage    = $LastError.Exception.Message
            ExceptionSource     = $LastError.Exception.Source
            ExceptionStackTrace = $LastError.Exception.StackTrace
            PositionMessage     = $LastError.InvocationInfo.PositionMessage
            InvocationName      = $LastError.InvocationInfo.InvocationName
            MyCommandVersion    = $version
            ScriptName          = $LastError.InvocationInfo.ScriptName
        }

        # Add LogLastErrorData to LogData
        foreach ($_data in $LogLastErrorData.PSObject.Properties) {
            $LogData | Add-Member -MemberType NoteProperty -Name $_data.name -Value $_data.value
        }
        $Message = "$($Message)`n`n== Error Message ==`n`n$($LogLastErrorData.ExceptionMessage)"
    }
    
    # Converting logdata
    [String[]]$LogData = foreach ($_log in $LogData.PSObject.Properties) {
        "$($_log.name) = $($_log.value)"
    }

    # Safety check if it's not running on Windows system it will create logs in text files
    if ($IsWindows -eq $true) {
        # If LogName don't exist as log in EventLog then it will create it
        if ($([System.Diagnostics.EventLog]::Exists("$LogName"); ) -eq $false) {
            New-EventLog -LogName $LogName
        }

        # If source don't exists on the host it will name it as Missing instead
        if ($([System.Diagnostics.EventLog]::SourceExists("$Type"); ) -eq $false) {
            $Type = "Missing"
        }

        $Event = [System.Diagnostics.EventLog]::new()
        $Event.Log = $LogName
        $EventInstance = [System.Diagnostics.EventInstance]::new($ID, $Category, $EntryType)
        $Event.Source = $Type

        # Joining the log message to one array to write to EventLog
        [Array]$JoinedMessage = @(
            $Message
            $LogData | ForEach-Object { $_ }
        )

        try {
            $Event.WriteEvent($EventInstance, $JoinedMessage)
        }
        catch {
            Write-Warning "Write-Event - Couldn't create new event - $($_.Exception.Message)"
        }
    }

    if ($EntryType -eq "Error") {
        if ($ErrorReturn -eq $true) {
            return $LogLastErrorData.ExceptionMessage
        }
        else {
            throw $LogLastErrorData.ExceptionMessage
        }
    }
}