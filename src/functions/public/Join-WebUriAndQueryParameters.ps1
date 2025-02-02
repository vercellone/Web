function Join-WebUriAndQueryParameters {
    <#
        .SYNOPSIS
        Join a query string parameters collection into a Uri with or without its own query string.

        .EXAMPLE
        (Join-WebUriAndQueryParameters -Uri 'https://dev.azure.com/MyOrg/MyProject/_apis/git/repositories/MyRepo/commits' -QueryParameters @{
            'searchCriteria.fromDate' = '6/14/2023 12:00:00'
            '$top' = 200
        }).ToString()
        ----
        https://dev.azure.com/MyOrg/MyProject/_apis/git/repositories/MyRepo/commits?$top=200&searchCriteria.fromDate=6%2f14%2f2023+12%3a00%3a00

        <Add description here>

        .EXAMPLE
        $params = @{
            Uri = 'https://dev.azure.com/MyOrg/MyProject/_apis/git/repositories/MyRepo/commits?searchCriteria.fromDate=6/14/2023 12:00:00'
            QueryParameters = @{
                '$top' = 200
            }
        }
        (Join-WebUriAndQueryParameters @params ).ToString()
        ----
        https://dev.azure.com/MyOrg/MyProject/_apis/git/repositories/MyRepo/commits?searchCriteria.fromDate=6%2f14%2f2023+12%3a00%3a00&$top=200

        <Add description here>

        .EXAMPLE
        (Join-WebUriAndQueryParameters -Uri 'https://dev.azure.com/MyOrg/MyProject/_apis/git/repositories/MyRepo/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200').ToString()
        ----
        https://dev.azure.com/MyOrg/MyProject/_apis/git/repositories/MyRepo/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200

        <Add description here>

        .EXAMPLE
        (Join-WebUriAndQueryParameters -Uri 'https://dev.azure.com/MyOrg/MyProject/_apis/git/repositories/MyRepo/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200').ToString()
        ----
        https://dev.azure.com/MyOrg/MyProject/_apis/git/repositories/MyRepo/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200

        <Add description here>

        .OUTPUTS
        [Uri]

        .LINK
        https://psmodule.io/Web/Functions/Join-WebUriAndQueryParameters/
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Truth over convention')]
    [OutputType([Uri])]
    [cmdletBinding()]
    param(
        # A valid Uri object.
        [Parameter()]
        [Uri] $Uri,

        # An IDictionary or NameValueCollection of query parameters. If ANY QueryParameters are specified,
        # then ALL query parameters will be UrlEncoded. If NONE, then the original Uri.Query is not modified (not UrlEncoded).
        [Parameter()]
        [object] $QueryParameters
    )

    if ($null -ne $QueryParameters -and ($QueryParameters.Count -gt 0 -or $QueryParameters.Keys.Count -gt 0)) {
        # Build a new Uri with a new query composed of both those in the original Uri and in the QueryParameters collection
        $uriBuilder = [UriBuilder]::new($Uri)
        $uriBuilder.Query = [Web.HttpUtility]::ParseQueryString($Uri.Query), $QueryParameters | ConvertTo-WebQueryString
        $uriBuilder.Uri
    } else {
        $Uri # No additional parameters, return Uri unmodified
    }
}
