function Join-UriAndQueryParameters {
    <#
    .SYNOPSIS
        Join a query string parameters collection into a Uri with or without its own Query string.

    .PARAMETER Uri
        A valid Uri object.

    .PARAMETER QueryParameters
        An IDictionary or NameValueCollection of query parameters. If ANY QueryParameters are specified, then ALL query parameters will be UrlEncoded. If NONE, then the original Uri.Query is not modified (not UrlEncoded).

    .EXAMPLE
        > (Join-UriAndQueryParameters -Uri 'https://dev.azure.com/PSSodium/MyProject/_apis/git/repositories/Sodium/commits' -QueryParameters @{
            'searchCriteria.fromDate' = '6/14/2023 12:00:00'
            '$top' = 200
        }).ToString()

        https://dev.azure.com/PSSodium/MyProject/_apis/git/repositories/Sodium/commits?$top=200&searchCriteria.fromDate=6%2f14%2f2023+12%3a00%3a00

    .EXAMPLE
        > (Join-UriAndQueryParameters -Uri 'https://dev.azure.com/PSSodium/MyProject/_apis/git/repositories/Sodium/commits?searchCriteria.fromDate=6/14/2023 12:00:00' -QueryParameters @{ '$top' = 200 }).ToString()

        https://dev.azure.com/PSSodium/MyProject/_apis/git/repositories/Sodium/commits?searchCriteria.fromDate=6%2f14%2f2023+12%3a00%3a00&$top=200

    .EXAMPLE
        > (Join-UriAndQueryParameters -Uri 'https://dev.azure.com/PSSodium/MyProject/_apis/git/repositories/Sodium/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200').ToString()

        https://dev.azure.com/PSSodium/MyProject/_apis/git/repositories/Sodium/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200

    .EXAMPLE
        > (Join-UriAndQueryParameters -Uri 'https://dev.azure.com/PSSodium/MyProject/_apis/git/repositories/Sodium/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200' -QueryParameters $null).ToString()

        https://dev.azure.com/PSSodium/MyProject/_apis/git/repositories/Sodium/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200

    .OUTPUTS
        [Uri]
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Truth over convention')]
    [OutputType([Uri])]
    [cmdletBinding()]
    param(
        [Uri]$Uri,
        $QueryParameters
    )
    if ($null -ne $QueryParameters -and ($QueryParameters.Count -gt 0 -or $QueryParameters.Keys.Count -gt 0)) {
        # Build a new Uri with a new query composed of both those in the original Uri and in the QueryParameters collection
        $uriBuilder = [UriBuilder]::new($Uri)
        $uriBuilder.Query = [Web.HttpUtility]::ParseQueryString($Uri.Query), $QueryParameters | ConvertTo-QueryString
        $uriBuilder.Uri
    }
    else {
        $Uri # No additional parameters, return Uri unmodified
    }
}
