# Converts a hashtable into a query string with key-value pairs.
ConvertTo-WebQueryString -InputObject @{a = 1; b = 2 }
# Outputs: ?a=1&b=2

# Converts a hashtable where values contain spaces. The default encoding uses `%20` for spaces.
ConvertTo-WebQueryString -InputObject @{a = 'this is value of a'; b = 'valueOfB' }
# Outputs: ?a=this%20is%20value%20of%20a&b=valueOfB

# Converts a hashtable while using `+` for spaces, which is preferred in some URL encoding schemes.
ConvertTo-WebQueryString -InputObject @{a = 'this is value of a'; b = 'valueOfB' } -AsURLEncoded
# Outputs: ?a=this+is+value+of+a&b=valueOfB


# Joins the base URI <https://example.com> with the child paths 'foo' and 'bar' to create the URI <https://example.com/foo/bar>.
Join-WebUri -Path 'https://example.com' -ChildPath 'foo' -AdditionalChildPath 'bar'
# Outputs: https://example.com/foo/bar


# Combines the base URI <https://example.com> with the child paths '/foo/', '/bar/', '//baz/something/', and '/test/'.
Join-WebUri 'https://example.com' '/foo/' '/bar/' '//baz/something/' '/test/'
# Outputs: https://example.com/foo/bar/baz/something/test>

