function Join-WebUriAndQueryParameters {
    <#
    .SYNOPSIS
        Join a query string parameters collection into a URI with or without its own Query string.

    .PARAMETER Uri
        A valid URI object.

    .PARAMETER QueryParameters
        An IDictionary or NameValueCollection of query parameters. If ANY QueryParameters are specified,
        then ALL query parameters will be UrlEncoded. If NONE, then the original URI.Query is not modified (not UrlEncoded).

    .EXAMPLE
        $joinParams = @{
            Uri             = 'https://aka.no/commits'
            QueryParameters = @{
                'searchCriteria.fromDate' = '6/14/2023 12:00:00'
                '$top'                    = 200
            }
        }
        (Join-WebUriAndQueryParameters @joinParams).ToString()

        Returns `https://aka.no/commits?searchCriteria.fromDate=6%2f14%2f2023+12%3a00%3a00&%24top=200`

    .EXAMPLE
        $joinParams = @{
            Uri             = 'https://aka.no/commits?searchCriteria.fromDate=6/14/2023 12:00:00'
            QueryParameters = @{
                '$top' = 200
            }
        }
        (Join-WebUriAndQueryParameters @joinParams).ToString()

        Returns `https://aka.no/commits?searchCriteria.fromDate=6%2f14%2f2023+12%3a00%3a00&%24top=200`

    .EXAMPLE
        $joinParams = @{
            Uri = 'https://aka.no/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200'
        }
        (Join-WebUriAndQueryParameters @joinParams).ToString()

        Returns `https://aka.no/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200`

    .EXAMPLE
        $joinParams = @{
            Uri             = 'https://aka.no/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200'
            QueryParameters = $null
        }
        (Join-WebUriAndQueryParameters @joinParams).ToString()

        Returns `https://aka.no/commits?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200`

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
        # Build a new URI with a new query composed of both those in the original URI and in the QueryParameters collection
        $uriBuilder = [UriBuilder]::new($Uri)
        $uriBuilder.Query = [Web.HttpUtility]::ParseQueryString($Uri.Query), $QueryParameters | ConvertTo-WebQueryString
        $uriBuilder.Uri
    } else {
        $Uri # No additional parameters, return Uri unmodified
    }
}
