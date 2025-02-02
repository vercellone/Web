Describe 'Module' {
    It 'Function: Get-PSModuleTest' {
        Get-PSModuleTest -Name 'World' | Should -Be 'Hello, World!'
    }
    Context "ConvertFrom-QueryString" {
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

        It "Should convert a query string to a NameValueCollection [<InputObject>]" -ForEach $testCases {
            $kvCollection = $InputObject | ConvertFrom-QueryString
            $kvCollection.Keys | Should -Be $ExpectedKeys
            $kvCollection.Keys | ForEach-Object { $kvCollection[$_] } | Should -Be $ExpectedValues
        }

        It "Should convert a query string -AsHashTable [<InputObject>]" -ForEach $testCases {
            $kvCollection = $InputObject | ConvertFrom-QueryString -AsHashTable
            $kvCollection.Keys | Should -BeIn $ExpectedKeys
            $kvCollection.Values | Should -BeIn $ExpectedValues
        }
    }

    Context "ConvertTo-QueryString" {

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

        $nvTestCases = @(
            @{
                ExpectedString = 'pagelen=50&state=OPEN&state=MERGED'
                InputObject    = $(
                    $nvCollection = [System.Web.HttpUtility]::ParseQueryString([string]::Empty)
                    $nvCollection.Add('pagelen', 50)
                    $nvCollection.Add('state', 'OPEN')
                    $nvCollection.Add('state', 'MERGED')
                    , $nvCollection # comma prevents enumeration, so the whole collection is output as 1 object
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
                    , $nvCollection # comma prevents enumeration, so the whole collection is output as 1 object
                )
            }
        )

        It "Should convert an IDictionary to a query string [<ExpectedString>]" -ForEach $htTestCases {
            ConvertTo-QueryString -InputObject $InputObject | Should -Be $ExpectedString
        }

        It "Should convert a NameValueCollection to a query string [<ExpectedString>]" -ForEach $nvTestCases {
            ConvertTo-QueryString -InputObject $InputObject | Should -Be $ExpectedString
        }

    }

    Context "Join-UriAndQueryParameters" {
        # These are based on a real world scenarios involving Azure DevOps Rest endpoints, but the base urls have been changed for brevity
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
                QueryParameters = $null # NullOrEmpty QueryParameters returns the Uri unmodified
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

        It "Should join a Uri and QueryParameters [<ExpectedUri>]" -ForEach $joinTestCases {
            (Join-UriAndQueryParameters -Uri $Uri -QueryParameters $QueryParameters).ToString() | Should -Be $ExpectedUri
        }
    }

}
