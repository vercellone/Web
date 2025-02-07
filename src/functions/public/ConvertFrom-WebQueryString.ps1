function ConvertFrom-WebQueryString {
    <#
    .SYNOPSIS
        Converts the provided query string into a Hashtable

    .PARAMETER InputObject
        String to be converted.

    .PARAMETER AsHashTable
        Enable legacy mode to return the result as a hashtable, which allows property notation access.

    .EXAMPLE
        $kvCollection = 'taco=12&quesadilla=6&burrito=8' | ConvertFrom-WebQueryString
        foreach($key in $kvCollection.Keys) {
            Write-Host "$key = $($kvCollection[$key])"
        }

        taco = 12
        quesadilla = 6
        burrito = 8

    .EXAMPLE
        $kvCollection = 'pagelen=50&state=OPEN&state=MERGED&q=created_on%3e%3d2024-01-25T16%3a37%3a56Z' | ConvertFrom-WebQueryString
        foreach($key in $kvCollection.Keys) {
            Write-Host "$key = $($kvCollection[$key])"
        }

        pagelen = 50
        state = OPEN,MERGED
        q = created_on>=2024-01-25T16:37:56Z
    #>
    [CmdletBinding()]
    [OutputType([Hashtable])]
    [OutputType([System.Array])]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [Alias('qs')]
        [string[]]$InputObject,

        [switch]$AsHashTable
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
