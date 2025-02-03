function ConvertTo-WebQueryString {
    <#
    .SYNOPSIS
        Joins the parameters of an IDictionary object into a query string.

    .PARAMETER InputObject
        IDictionary, HttpQSCollection, or NameValueCollection Object to be converted.

    .EXAMPLE
        @{ taco = 12;burrito = 8;quesadilla = 6 } | ConvertTo-WebQueryString

        taco=12&quesadilla=6&burrito=8

    .EXAMPLE
        @{ state = 'OPEN' },@{ state = 'MERGED' } | ConvertTo-WebQueryString

        state=OPEN&state=MERGED

    .EXAMPLE
        $nvCollection =  [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        $nvCollection.Add('pagelen', 50)
        $nvCollection.Add('state', 'OPEN')
        $nvCollection.Add('state', 'MERGED')
        ConvertTo-WebQueryString -InputObject $nvCollection

        pagelen=50&state=OPEN&state=MERGED

    .EXAMPLE
        $nvCollection =  [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        $nvCollection.Add('pagelen', 50)
        $nvCollection.Add('state', 'OPEN')
        $nvCollection.Add('state', 'MERGED')
        $nvCollection.Add('q', 'created_on>=2024-01-25T16:37:56Z')
        # The leading comma below is significant.  Without it, only the array of key strings
        # are piped to ConvertTo-WebQueryString which will output $null as a result.
        ,$nvCollection | ConvertTo-WebQueryString

        pagelen=50&state=OPEN&state=MERGED&q=created_on%3e%3d2024-01-25T16%3a37%3a56Z

    .LINK
        https://referencesource.microsoft.com/#system.web/HttpQSCollection.cs
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline)]
        [object]$InputObject
    )
    begin {
        # This creates an empty HttpQSCollection which provides the magic .ToString method
        $nvCollection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    }
    process {
        if ($InputObject -is [Collections.Specialized.NameValueCollection]) {
            $nvCollection.Add($InputObject)
        }
        elseif ( $InputObject -is [Collections.IDictionary]) {
            foreach ($key in $InputObject.Keys) {
                $nvCollection.Add($key, $InputObject.$Key)
            }
        }
        else {
            throw "InputObject type not supported: $($InputObject.GetType())"
        }
    }

    end {
        $nvCollection.ToString()
    }
}
