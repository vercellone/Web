function ConvertFrom-WebQueryString {
    <#
        .SYNOPSIS
        Converts a URL query string into a Hashtable or a NameValueCollection.

        .DESCRIPTION
        This function takes a URL query string and converts it into a structured format.
        By default, it returns a `NameValueCollection` object that allows multiple values per key.
        If the `-AsHashTable` switch is used, the function returns a Hashtable, where keys can be accessed using dot notation.

        .EXAMPLE
        'taco=12&quesadilla=6&burrito=8' | ConvertFrom-WebQueryString
        ----
        taco = 12
        quesadilla = 6
        burrito = 8

        Converts the given query string into a NameValueCollection.

        .EXAMPLE
        'pagelen=50&state=OPEN&state=MERGED&q=created_on%3e%3d2024-01-25T16%3a37%3a56Z' | ConvertFrom-WebQueryString -AsHashTable
        ----
        Name                           Value
        ----                           -----
        q                              created_on>=2024-01-25T16:37:56Z
        pagelen                        50
        state                          OPEN,MERGED

        Converts the query string into a Hashtable.

        .LINK
        https://psmodule.io/Web/Functions/ConvertFrom-WebQueryString/
    #>
    [CmdletBinding()]
    [OutputType([Hashtable])]
    [OutputType([System.Array])]
    param (
        # The query string to be converted.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [Alias('qs')]
        [string[]] $InputObject,

        # Returns the result as a Hashtable instead of a NameValueCollection.
        [Parameter()]
        [switch] $AsHashTable
    )

    begin {
        # This creates an empty NameValueCollection for parsing.
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
