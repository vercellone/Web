Describe 'Web' {

    ###############################################################################
    # Context: ConvertTo-WebQueryString
    ###############################################################################
    Context 'ConvertTo-WebQueryString' {
        It 'Should convert a hashtable to a query string (order-independent)' {
            $result = ConvertTo-WebQueryString -InputObject @{ a = 1; b = 2 }

            # Parse the result into a NameValueCollection
            $parsed = [System.Web.HttpUtility]::ParseQueryString($result)

            # Compare the keys and values
            $parsed.AllKeys | Sort-Object | Should -Be @('a', 'b')
            $parsed['a'] | Should -Be '1'
            $parsed['b'] | Should -Be '2'
        }

        It 'Should encode spaces as +' {
            $result = ConvertTo-WebQueryString -InputObject @{ a = 'this is value of a'; b = 'valueOfB' }
            $parsed = [System.Web.HttpUtility]::ParseQueryString($result)

            $parsed.AllKeys | Sort-Object | Should -Be @('a', 'b')
            $parsed['a'] | Should -Be 'this is value of a'
            $parsed['b'] | Should -Be 'valueOfB'

            $result | Should -Match 'this\+is\+value\+of\+a'
        }

        It 'Should handle an empty hashtable correctly' {
            $result = ConvertTo-WebQueryString -InputObject @{}
            $result | Should -BeNullOrEmpty
        }

        It 'Should throw an error for invalid input types' {
            { ConvertTo-WebQueryString -InputObject 'invalid' } | Should -Throw
        }
    }

    Context 'Join-WebUri' {
        It 'Should join base URI with child paths' {
            $result = Join-WebUri -Path 'https://example.com' -ChildPath 'foo' -AdditionalChildPath 'bar'
            $result | Should -Be 'https://example.com/foo/bar'
        }
        It 'Should normalize and remove duplicate slashes' {
            $result = Join-WebUri -Path 'https://example.com' -ChildPath '/foo/' -AdditionalChildPath '/bar/'
            $result | Should -Be 'https://example.com/foo/bar'
        }
        It 'Should handle multiple additional paths' {
            $result = Join-WebUri 'https://example.com' '/foo/' '/bar/' '//baz/something/' '/test/'
            $result | Should -Be 'https://example.com/foo/bar/baz/something/test'
        }
        It 'Should trim leading and trailing slashes from child paths' {
            $result = Join-WebUri -Path 'https://example.com/' -ChildPath '/foo/' -AdditionalChildPath '/bar/'
            $result | Should -Be 'https://example.com/foo/bar'
        }
        It 'Should throw an error when Path is not a valid URI' {
            { Join-WebUri -Path 'invalidURI' -ChildPath 'foo' } | Should -Throw
        }
    }

    ###############################################################################
    # Context: ConvertFrom-WebQueryString
    ###############################################################################
    Context 'ConvertFrom-WebQueryString' {
        # Multiple test cases to demonstrate
        $testCases = @(
            @{
                ExpectedKeys   = 'taco', 'quesadilla', 'burrito'
                ExpectedValues = '12', '6', '8'
                InputObject    = 'taco=12&quesadilla=6&burrito=8'
            },
            @{
                ExpectedKeys   = 'pagelen', 'state', 'q'
                ExpectedValues = '50', 'OPEN,MERGED', 'created_on>=2024-01-25T16:37:56Z'
                InputObject    = 'pagelen=50&state=OPEN&state=MERGED&q=created_on%3e%3d2024-01-25T16%3a37%3a56Z'
            }
        )

        It 'Should convert a query string to a NameValueCollection [<InputObject>]' -ForEach $testCases {
            $kvCollection = $InputObject | ConvertFrom-WebQueryString
            $kvCollection.Keys | Should -Be $ExpectedKeys
            $kvCollection.Keys | ForEach-Object { $kvCollection[$_] } | Should -Be $ExpectedValues
        }

        It 'Should convert a query string -AsHashTable [<InputObject>]' -ForEach $testCases {
            $kvCollection = $InputObject | ConvertFrom-WebQueryString -AsHashTable
            $kvCollection.Keys | Should -BeIn $ExpectedKeys
            $kvCollection.Values | Should -BeIn $ExpectedValues
        }
    }

    ###############################################################################
    # Context: ConvertTo-WebQueryString (Advanced)
    ###############################################################################
    Context 'ConvertTo-WebQueryString (Advanced)' {
        # Test with hashtable
        $htTestCases = @(
            @{
                ExpectedString = 'quesadilla=6&burrito=8&taco=12'
                InputObject    = @{
                    taco       = 12
                    burrito    = 8
                    quesadilla = 6
                }
            }
        )

        # Test with a NameValueCollection
        $nvTestCases = @(
            @{
                ExpectedString = 'pagelen=50&state=OPEN&state=MERGED'
                InputObject    = $(
                    $nvCollection = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
                    $nvCollection.Add('pagelen', 50)
                    $nvCollection.Add('state', 'OPEN')
                    $nvCollection.Add('state', 'MERGED')
                    , $nvCollection # The comma ensures $nvCollection is treated as one object
                )
            },
            @{
                ExpectedString = 'pagelen=50&state=OPEN&state=MERGED&q=created_on%3e%3d2024-01-25T16%3a37%3a56Z'
                InputObject    = $(
                    $nvCollection = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
                    $nvCollection.Add('pagelen', 50)
                    $nvCollection.Add('state', 'OPEN')
                    $nvCollection.Add('state', 'MERGED')
                    $nvCollection.Add('q', 'created_on>=2024-01-25T16:37:56Z')
                    , $nvCollection
                )
            }
        )

        It 'Should convert an IDictionary to a query string [<ExpectedString>]' -ForEach $htTestCases {
            # Generate the query string
            $result = ConvertTo-WebQueryString -InputObject $InputObject

            # Parse the actual result and the expected string
            $parsedActual = [System.Web.HttpUtility]::ParseQueryString($result)
            $parsedExpected = [System.Web.HttpUtility]::ParseQueryString($ExpectedString)

            foreach ($key in $parsedActual.AllKeys) {
                $parsedActual[$key] | Should -Be $parsedExpected[$key]
            }
        }

        It 'Should convert a NameValueCollection to a query string [<ExpectedString>]' -ForEach $nvTestCases {
            $result = ConvertTo-WebQueryString -InputObject $InputObject
            $parsedActual = [System.Web.HttpUtility]::ParseQueryString($result)
            $parsedExpected = [System.Web.HttpUtility]::ParseQueryString($ExpectedString)

            foreach ($key in $parsedActual.AllKeys) {
                $parsedActual[$key] | Should -Be $parsedExpected[$key]
            }
        }
    }

    ###############################################################################
    # Context: Join-WebUriAndQueryParameters
    ###############################################################################
    Context 'Join-WebUriAndQueryParameters' {
        $joinTestCases = @(
            @{
                ExpectedUri     = 'https://aka.no/c?searchCriteria.fromDate=6%2f14%2f2023+12%3a00%3a00&%24top=100'
                QueryParameters = @{
                    'searchCriteria.fromDate' = '6/14/2023 12:00:00'
                    '$top'                    = 100
                }
                Uri             = 'https://aka.no/c'
            },
            @{
                ExpectedUri     = 'https://aka.no/c?searchCriteria.fromDate=6%2f14%2f2023+12%3a00%3a00&%24top=200'
                QueryParameters = @{
                    '$top' = 200
                }
                Uri             = 'https://aka.no/c?searchCriteria.fromDate=6/14/2023 12:00:00'
            },
            @{
                ExpectedUri     = 'https://aka.no/c?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200'
                QueryParameters = $null # NullOrEmpty => just return the original Uri as-is
                Uri             = 'https://aka.no/c?searchCriteria.fromDate=6/14/2023 12:00:00&$top=200'
            },
            @{
                ExpectedUri     = 'https://aka.no/?%24top=50'
                QueryParameters = @{
                    '$top' = 50
                }
                Uri             = 'https://aka.no'
            }
        )

        It 'Should join a Uri and QueryParameters [<ExpectedUri>]' -ForEach $joinTestCases {
            $actualFullUri = Join-WebUriAndQueryParameters -Uri $Uri -QueryParameters $QueryParameters

            # First, do a direct string compare on the full URI
            $actualFullUri.ToString() | Should -Be $ExpectedUri

            # Then, parse the query to compare keys/values
            $expectedUriObj = [System.Uri] $ExpectedUri
            $expectedQuery = $expectedUriObj.Query.TrimStart('?')
            $parsedExpected = [System.Web.HttpUtility]::ParseQueryString($expectedQuery)

            $actualUriObj = [System.Uri] $actualFullUri
            $actualQuery = $actualUriObj.Query.TrimStart('?')
            $parsedActual = [System.Web.HttpUtility]::ParseQueryString($actualQuery)

            $parsedActual.AllKeys | Sort-Object | Should -Be ($parsedExpected.AllKeys | Sort-Object)
            foreach ($key in $parsedActual.AllKeys) {
                $parsedActual[$key] | Should -Be $parsedExpected[$key]
            }
        }
    }
}
