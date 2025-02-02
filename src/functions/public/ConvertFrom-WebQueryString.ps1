function ConvertFrom-WebQueryString {
    <#
        .SYNOPSIS
        Converts the provided query string into a Hashtable

        .DESCRIPTION
        <Add description here>

        .EXAMPLE
        $kvCollection = 'taco=12&quesadilla=6&burrito=8' | ConvertFrom-WebQueryString
        foreach($key in $kvCollection.Keys) {
            Write-Host "$key = $($kvCollection[$key])"
        }
        ----
        taco = 12
        quesadilla = 6
        burrito = 8

        <Add description here>

        .EXAMPLE
        $kvCollection = 'pagelen=50&state=OPEN&state=MERGED&q=created_on%3e%3d2024-01-25T16%3a37%3a56Z' | ConvertFrom-WebQueryString
        foreach($key in $kvCollection.Keys) {
            Write-Host "$key = $($kvCollection[$key])"
        }
        ----
        pagelen = 50
        state = OPEN,MERGED
        q = created_on>=2024-01-25T16:37:56Z

        <Add description here>

        .LINK
        https://psmodule.io/Web/Functions/ConvertFrom-WebQueryString/
    #>
    [CmdletBinding()]
    [OutputType([Hashtable])]
    [OutputType([System.Array])]
    param (
        # String to be converted.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Alias('qs')]
        [string[]] $InputObject,

        # Enable legacy mode to return the result as a hashtable, which allows property notation access.
        [Parameter()]
        [switch] $AsHashTable
    )

    begin {
        # This creates an empty HttpQSCollection which provides the magic .ToString method for URLs
        $resp = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
    }

    process {
        foreach ($qs in $InputObject) {
            $resp.Add([System.Web.HttpUtility]::ParseQueryString($qs))
        }
    }

    end {
        if ($AsHashTable.IsPresent) {
            $ht = @{}
            foreach ($q in $resp.Keys) {
                $ht[$q] = $resp[$q]
            }
            $ht
        } else {
            , $resp
        }
    }
}
