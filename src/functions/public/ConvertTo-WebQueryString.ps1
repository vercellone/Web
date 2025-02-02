filter ConvertTo-WebQueryString {
    <#
        .SYNOPSIS
        Converts an object to a properly formatted web query string.

        .DESCRIPTION
        This function takes an input object (typically a hashtable) and converts it into a web query string.
        It encodes the keys and values to ensure compatibility with URLs.
        If the `-AsURLEncoded` switch is provided, the encoding will be URL-friendly, using `+` for spaces instead of `%20`.

        .EXAMPLE
        ConvertTo-WebQueryString -InputObject @{a = 1; b = 2 }

        ?a=1&b=2

        Converts a hashtable into a query string with key-value pairs.

        .EXAMPLE
        ConvertTo-WebQueryString -InputObject @{a='this is value of a'; b='valueOfB'}

        ?a=this%20is%20value%20of%20a&b=valueOfB

        Converts a hashtable where values contain spaces. The default encoding uses `%20` for spaces.

        .EXAMPLE
        ConvertTo-WebQueryString -InputObject @{a='this is value of a'; b='valueOfB'} -AsURLEncoded

        ?a=this+is+value+of+a&b=valueOfB

        Converts a hashtable while using `+` for spaces, which is preferred in some URL encoding schemes.

        .LINK
        https://psmodule.io/Web/Functions/ConvertTo-WebQueryString/
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param(
        # The input object to be converted into a query string.
        # Must be a hashtable or convertible to one.
        [Parameter(
            Mandatory,
            ValueFromPipeline
        )]
        [hashtable] $InputObject,

        # Switch to enable alternative URL encoding (`+` for spaces).
        [Parameter()]
        [switch] $AsURLEncoded
    )

    $parameters = if ($AsURLEncoded) {
        ($InputObject.GetEnumerator() | ForEach-Object {
            "$([System.Web.HttpUtility]::UrlEncode($_.Key))=$([System.Web.HttpUtility]::UrlEncode($_.Value))"
        }) -join '&'
    } else {
        ($InputObject.GetEnumerator() | ForEach-Object {
            "$([System.Uri]::EscapeDataString($_.Key))=$([System.Uri]::EscapeDataString($_.Value))"
        }) -join '&'
    }

    if ($parameters) {
        '?' + $parameters
    }
}
