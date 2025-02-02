function Join-WebUriAndQueryParameters {
    <#
        .SYNOPSIS
        Joins a query string parameters collection into a URI while preserving or appending query parameters.

        .DESCRIPTION
        This function takes a base URI and a collection of query parameters and combines them into a single URI.
        If the provided URI already contains a query string, the additional query parameters are appended.
        Query parameters are URL-encoded to ensure proper formatting.

        .EXAMPLE
        (Join-WebUriAndQueryParameters -Uri 'https://example.com/api/getsomething' -QueryParameters @{
            'searchCriteria.fromDate' = '6/14/2023 12:00:00'
            '$top' = 200
        }).ToString()
        ----
        https://example.com/api/getsomething?$top=200&searchCriteria.fromDate=6%2f14%2f2023+12%3a00%3a00

        Combines the base URI with the provided query parameters and returns the correctly formatted URI.

        .EXAMPLE
        $params = @{
            Uri = 'https://example.com/api/getsomething?searchCriteria.fromDate=6/14/2023 12:00:00'
            QueryParameters = @{
                '$top' = 200
            }
        }
        (Join-WebUriAndQueryParameters @params).ToString()
        ----
        https://example.com/api/getsomething?searchCriteria.fromDate=6%2f14%2f2023+12%3a00%3a00&$top=200

        Appends the provided query parameters to an existing URI that already contains query parameters.

        .EXAMPLE
        (Join-WebUriAndQueryParameters -Uri 'https://example.com/api/getsomething?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200').ToString()
        ----
        https://example.com/api/getsomething?searchCriteria.fromDate=6/14/2023+12%3a00%3a00&$top=200

        Returns the original URI unmodified when no additional query parameters are provided.

        .OUTPUTS
        [Uri]

        .LINK
        https://psmodule.io/Web/Functions/Join-WebUriAndQueryParameters/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Truth over convention')]
    [OutputType([Uri])]
    [CmdletBinding()]
    param(
        # A valid URI object to which query parameters will be appended.
        [Parameter(Mandatory = $true)]
        [Uri] $Uri,

        # A hashtable or NameValueCollection of query parameters to append to the URI.
        # If specified, all query parameters (including existing ones in the URI) will be URL-encoded.
        [Parameter()]
        [object] $QueryParameters
    )

    if ($null -ne $QueryParameters -and ($QueryParameters.Count -gt 0 -or $QueryParameters.Keys.Count -gt 0)) {
        # Build a new URI with a new query composed of both those in the original URI and in the QueryParameters collection
        $uriBuilder = [UriBuilder]::new($Uri)
        $uriBuilder.Query = [Web.HttpUtility]::ParseQueryString($Uri.Query), $QueryParameters | ConvertTo-WebQueryString
        $uriBuilder.Uri
    } else {
        $Uri # No additional parameters, return Uri unmodified
    }
}
