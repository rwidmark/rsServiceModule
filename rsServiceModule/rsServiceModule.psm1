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
        https://github.com/rwidmark/rsServiceModule/blob/main/README.md

        .NOTES
        Author:         Robin Widmark
        Mail:           robin@widmark.dev
        Website/Blog:   https://widmark.dev
        X:              https://x.com/widmark_robin
        Mastodon:       https://mastodon.social/@rwidmark
		YouTube:		https://www.youtube.com/@rwidmark
        Linkedin:       https://www.linkedin.com/in/rwidmark/
        GitHub:         https://github.com/rwidmark
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