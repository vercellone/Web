function ConvertTo-WebQueryString {
    <#
    .SYNOPSIS
        Converts a hashtable or NameValueCollection into a web query string.

    .DESCRIPTION
        This function takes an IDictionary object (such as a hashtable) or a NameValueCollection
        and converts it into a properly formatted query string.

        The function supports multiple values for the same key, ensuring compatibility with
        APIs and web services that expect repeated keys.

    .PARAMETER InputObject
        IDictionary, HttpQSCollection, or NameValueCollection Object to be converted.

    .EXAMPLE
        @{ taco = 12;burrito = 8;quesadilla = 6 } | ConvertTo-WebQueryString
        ----
        taco=12&quesadilla=6&burrito=8

        Converts a hashtable into a query string where key-value pairs are joined using `&`.

    .EXAMPLE
        @{ state = 'OPEN' },@{ state = 'MERGED' } | ConvertTo-WebQueryString
        ----
        state=OPEN&state=MERGED

        Converts multiple objects with the same key into a properly formatted query string.

    .EXAMPLE
        $collection = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
        $collection.Add('pagelen', 50)
        $collection.Add('state', 'OPEN')
        $collection.Add('state', 'MERGED')
        ConvertTo-WebQueryString -InputObject $collection
        ----
        pagelen=50&state=OPEN&state=MERGED

        Converts a `NameValueCollection` into a query string, preserving multiple values for a key.

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

        Converts a NameValueCollection containing special characters. The percent encoding triplet
        is normalized to uppercase according to [RFC 3986 6.2.2.1](https://datatracker.ietf.org/doc/html/rfc3986#section-6.2.2.1).

        .LINK
        https://psmodule.io/Web/Functions/ConvertTo-WebQueryString/

        .LINK
        https://referencesource.microsoft.com/#system.web/HttpQSCollection.cs
    #>
    [CmdletBinding()]
    param(
        # The object to be converted.
        # Accepts IDictionary, HttpQSCollection, or NameValueCollection objects.
        [Parameter(
            Mandatory,
            Position = 0, # This allows the syntax: ConvertTo-WebQueryString @{ n = 'v' }
            ValueFromPipeline
        )]
        [object] $InputObject
    )

    begin {
        # This creates an empty HttpQSCollection which provides the magic .ToString method
        $collection = [System.Web.HttpUtility]::ParseQueryString([String]::Empty)
    }

    process {
        if ($InputObject -is [System.Collections.Specialized.NameValueCollection]) {
            $collection.Add($InputObject)
        } elseif ($InputObject -is [System.Collections.IDictionary]) {
            foreach ($key in $InputObject.Keys) {
                $collection.Add($key, $InputObject.$Key)
            }
        } else {
            throw "InputObject type not supported: $($InputObject.GetType())"
        }
    }

    end {
        $collection.ToString()
    }
}
