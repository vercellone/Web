Describe 'Web' {
    Context 'ConvertTo-WebQueryString Tests' {
        It 'Should convert a hashtable to a query string' {
            $result = ConvertTo-WebQueryString -InputObject @{ a = 1; b = 2 }
            $result | Should -BeIn '?a=1&b=2', '?b=2&a=1'
        }

        It 'Should URL encode spaces as %20 by default' {
            $result = ConvertTo-WebQueryString -InputObject @{ a = 'this is value of a'; b = 'valueOfB' }
            $result | Should -BeIn '?a=this%20is%20value%20of%20a&b=valueOfB', '?b=valueOfB&a=this%20is%20value%20of%20a'
        }

        It "Should use '+' for spaces when -AsURLEncoded is specified" {
            $result = ConvertTo-WebQueryString -InputObject @{ a = 'this is value of a'; b = 'valueOfB' } -AsURLEncoded
            $result | Should -BeIn '?a=this+is+value+of+a&b=valueOfB', '?b=valueOfB&a=this+is+value+of+a'
        }

        It 'Should handle an empty hashtable correctly' {
            $result = ConvertTo-WebQueryString -InputObject @{}
            $result | Should -BeNullOrEmpty
        }

        It 'Should throw an error for invalid input types' {
            { ConvertTo-WebQueryString -InputObject 'invalid' } | Should -Throw
        }
    }

    Context 'Join-WebUri Tests' {
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

}
