function ConvertTo-WebQueryString {
    <#
        .SYNOPSIS
        Joins the parameters of an IDictionary object into a query string.

        .DESCRIPTION
        <Add description here>

        .EXAMPLE
        @{ taco = 12;burrito = 8;quesadilla = 6 } | ConvertTo-WebQueryString
        ----
        taco=12&quesadilla=6&burrito=8

        <Add description here>

        .EXAMPLE
        @{ state = 'OPEN' },@{ state = 'MERGED' } | ConvertTo-WebQueryString
        ----
        state=OPEN&state=MERGED

        <Add description here>

        .EXAMPLE
        $collection =  [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        $collection.Add('pagelen', 50)
        $collection.Add('state', 'OPEN')
        $collection.Add('state', 'MERGED')
        ConvertTo-WebQueryString -InputObject $collection
        ----
        pagelen=50&state=OPEN&state=MERGED

        <Add description here>

        .EXAMPLE
        $collection = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        $collection.Add('pagelen', 50)
        $collection.Add('state', 'OPEN')
        $collection.Add('state', 'MERGED')
        $collection.Add('q', 'created_on>=2024-01-25T16:37:56Z')
        # The leading comma below is significant.  Without it, only the array of key strings
        # are piped to ConvertTo-WebQueryString which will output $null as a result.
        ,$collection | ConvertTo-WebQueryString
        ----
        pagelen=50&state=OPEN&state=MERGED&q=created_on%3e%3d2024-01-25T16%3a37%3a56Z

        <Add description here>

        .LINK
        https://referencesource.microsoft.com/#system.web/HttpQSCollection.cs
    #>
    [CmdletBinding()]
    param(
        # The object to be converted.
        # Accepts IDictionary, HttpQSCollection, or NameValueCollection objects.
        [Parameter(Position = 0, ValueFromPipeline)]
        [object] $InputObject
    )

    begin {
        # This creates an empty HttpQSCollection which provides the magic .ToString method
        $collection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    }

    process {
        if ($InputObject -is [Collections.Specialized.NameValueCollection]) {
            $collection.Add($InputObject)
        } elseif ( $InputObject -is [Collections.IDictionary]) {
            foreach ($key in $InputObject.Keys) {
                $collection.Add($key, $InputObject.$Key)
            }
        }
    }

    end {
        $collection.ToString()
    }
}
