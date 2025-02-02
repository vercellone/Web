function ConvertTo-WebQueryString {
    <#
        .SYNOPSIS
        Converts a hashtable or NameValueCollection into a web query string.

        .DESCRIPTION
        This function takes an IDictionary object (such as a hashtable) or a NameValueCollection
        and converts it into a properly formatted query string. By default, spaces in values
        are encoded as `%20`. If the `-AsURLEncoded` switch is provided, spaces are encoded as `+`.

        The function supports multiple values for the same key, ensuring compatibility with
        APIs and web services that expect repeated keys.

        .EXAMPLE
        @{ taco = 12; burrito = 8; quesadilla = 6 } | ConvertTo-WebQueryString
        ----
        taco=12&quesadilla=6&burrito=8

        Converts a hashtable into a query string where key-value pairs are joined using `&`.

        .EXAMPLE
        ConvertTo-WebQueryString -InputObject @{a='this is value of a'; b='valueOfB'}
        ----
        a=this%20is%20value%20of%20a&b=valueOfB

        Converts a hashtable where values contain spaces. The default encoding uses `%20` for spaces.

        .EXAMPLE
        ConvertTo-WebQueryString -InputObject @{a='this is value of a'; b='valueOfB'} -AsURLEncoded
        ----
        a=this+is+value+of+a&b=valueOfB

        Converts a hashtable while using `+` for spaces, which is preferred in some URL encoding schemes.

        .EXAMPLE
        @{ state = 'OPEN' }, @{ state = 'MERGED' } | ConvertTo-WebQueryString
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
        # The leading comma below is significant. Without it, only the array of key strings
        # are piped to ConvertTo-WebQueryString which will output $null as a result.
        ,$collection | ConvertTo-WebQueryString
        ----
        pagelen=50&state=OPEN&state=MERGED&q=created_on%3E%3D2024-01-25T16%3A37%3A56Z

        Converts a NameValueCollection containing special characters. The percent encoding triplet
        is normalized to uppercase according to [RFC 3986 6.2.2.1](https://datatracker.ietf.org/doc/html/rfc3986#section-6.2.2.1).

        .LINK
        https://psmodule.io/Web/Functions/ConvertTo-WebQueryString/
    #>
    [CmdletBinding()]
    param(
        # The object to be converted.
        # Accepts IDictionary, HttpQSCollection, or NameValueCollection objects.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [object] $InputObject,

        # If specified, uses the URL encoding from [System.Web.HttpUtility]::UrlEncode which uses + for spaces.
        # Otherwise, [System.Uri]::EscapeDataString is used, which produces %20 for spaces.
        [Parameter()]
        [switch] $AsURLEncoded
    )

    begin {
        $encodedPairs = @()
    }

    process {
        if ($InputObject -is [System.Collections.Specialized.NameValueCollection]) {
            foreach ($key in $InputObject.AllKeys) {
                $values = $InputObject.GetValues($key)
                foreach ($value in $values) {
                    if ($AsURLEncoded) {
                        $encodedKey = [System.Web.HttpUtility]::UrlEncode($key)
                        $encodedValue = [System.Web.HttpUtility]::UrlEncode($value)
                    } else {
                        $encodedKey = [System.Uri]::EscapeDataString($key)
                        $encodedValue = [System.Uri]::EscapeDataString($value)
                    }
                    $encodedPairs += "$encodedKey=$encodedValue"
                }
            }
        } elseif ($InputObject -is [System.Collections.IDictionary]) {
            foreach ($key in $InputObject.Keys) {
                $value = $InputObject[$key]
                if ($AsURLEncoded) {
                    $encodedKey = [System.Web.HttpUtility]::UrlEncode($key)
                    $encodedValue = [System.Web.HttpUtility]::UrlEncode($value)
                } else {
                    $encodedKey = [System.Uri]::EscapeDataString($key)
                    $encodedValue = [System.Uri]::EscapeDataString($value)
                }
                $encodedPairs += "$encodedKey=$encodedValue"
            }
        } else {
            throw "InputObject type not supported: $($InputObject.GetType())"
        }
    }

    end {
        $encodedPairs -join '&'
    }
}
