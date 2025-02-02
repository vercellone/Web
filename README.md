# Web

A PowerShell module that provides functionality for interacting with web resources.

## Prerequisites

This uses the following external resources:
- The [PSModule framework](https://github.com/PSModule) for building, testing and publishing the module.

## Installation

To install the module from the PowerShell Gallery, you can use the following command:

```powershell
Install-PSResource -Name Web
Import-Module -Name Web
```

## Usage

Here is a list of example that are typical use cases for the module.

### Example 1: Converts a hashtable into a query string

Converts a hashtable into a query string with key-value pairs

```powershell
ConvertTo-WebQueryString -InputObject @{a = 1; b = 2 }
# Outputs: ?a=1&b=2
```

### Example 2: Joins a base URI with child paths

Joins the base URI <https://example.com> with the child paths 'foo' and 'bar' to create the URI <https://example.com/foo/bar>.

```powershell
Join-WebUri -Path 'https://example.com' -ChildPath 'foo' -AdditionalChildPath 'bar'
# Outputs: https://example.com/foo/bar
```

### Find more examples

To find more examples of how to use the module, please refer to the [examples](examples) folder.

Alternatively, you can use the Get-Command -Module 'This module' to find more commands that are available in the module.
To find examples of each of the commands you can use Get-Help -Examples 'CommandName'.

## Contributing

Coder or not, you can contribute to the project! We welcome all contributions.

### For Users

If you don't code, you still sit on valuable information that can make this project even better. If you experience that the
product does unexpected things, throw errors or is missing functionality, you can help by submitting bugs and feature requests.
Please see the issues tab on this project and submit a new issue that matches your needs.

### For Developers

If you do code, we'd love to have your contributions. Please read the [Contribution guidelines](CONTRIBUTING.md) for more information.
You can either help by picking up an existing issue or submit a new one if you have an idea for a new feature or improvement.
