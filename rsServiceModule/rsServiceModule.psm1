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