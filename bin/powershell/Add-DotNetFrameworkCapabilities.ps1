[CmdletBinding()]
param()

# See http://msdn.microsoft.com/en-us/library/hh925568(v=vs.110).aspx for details on how to detect framework versions
# Also see http://support.microsoft.com/kb/318785

function Add-Versions {
    [CmdletBinding()]
    param(
        [string]$NameFormat,

        [Parameter(Mandatory = $true)]
        [string]$View,

        [Parameter(Mandatory = $true)]
        [ref]$LatestValue)

    # Get the install root from the registry.
    $installRoot = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName 'Software\Microsoft\.NETFramework' -ValueName 'InstallRoot'
    if (!$installRoot) {
        return
    }

    # Get the version sub key names.
    $ndpKeyName = 'Software\Microsoft\NET Framework Setup\NDP'
    $versionSubKeyNames =
        Get-RegistrySubKeyNames -Hive 'LocalMachine' -View $View -KeyName $ndpKeyName |
        Where-Object { $_ -like 'v*' }
    foreach ($versionSubKeyName in $versionSubKeyNames) {
        # Get the version.
        $versionKeyName = "$ndpKeyName\$versionSubKeyName"
        $version = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $versionKeyName -ValueName 'Version'
        if ($version) {
            # Check if installed.
            $install = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $versionKeyName -ValueName 'Install'
            if ($install -ne 1) {
                continue
            }

            # Verify the expected install path.
            $version
            $installPath = [System.IO.Path]::Combine($installRoot, $versionSubKeyName)
            if (!(Test-Container -LiteralPath $installPath)) {
                continue
            }

            # Parse the version from the sub key name.
            $versionObject = [System.Version]::Parse($versionSubKeyName.Substring(1))
            $capabilityName = ($NameFormat -f "$($versionObject.Major).$($versionObject.Minor)")

            # Add the capability.
            Write-Capability -Name $capabilityName -Value $installPath
            $LatestValue.Value = $installPath
            continue
        }

        # Check if deprecated.
        $default = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $versionKeyName -ValueName ''
        if ($default -eq 'deprecated') {
            continue
        }

        # Get the profile key names.
        $profileKeyNames =
            Get-RegistrySubKeyNames -Hive 'LocalMachine' -View $View -KeyName $versionKeyName |
            ForEach-Object { "$versionKeyName\$_" }
        foreach ($profileKeyName in $profileKeyNames) {
            # Skip if version not found.
            $version = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'Version'
            if (!$version) {
                continue
            }

            # Skip if not installed.
            $install = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'Install'
            if ($install -ne 1) {
                continue
            }

            # Skip if install path value not found.
            $installPath = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'InstallPath'
            $installPath = "$installPath".TrimEnd([System.IO.Path]::DirectorySeparatorChar)
            if (!$installPath) {
                continue
            }

            # Determine the version string.
            $release = Get-RegistryValue -Hive 'LocalMachine' -View $View -KeyName $profileKeyName -ValueName 'Release'
            $versionString = switch ($release) {
                # We put the releaseVersion into version range, since customer might install beta/preview version .NET Framework.
                # These magic values come from: https://docs.microsoft.com/en-us/dotnet/framework/migration-guide/how-to-determine-which-versions-are-installed
                378389 { "4.5.0" }
                { $_ -gt 378389 -and $_ -le 378758 } { "4.5.1" }
                { $_ -gt 378758 -and $_ -le 379893 } { "4.5.2" }
                { $_ -gt 379893 -and $_ -le 380995 } { "4.5.3" }
                { $_ -gt 380995 -and $_ -le 393297 } { "4.6.0" }
                { $_ -gt 393297 -and $_ -le 394271 } { "4.6.1" }
                { $_ -gt 394271 -and $_ -le 394806 } { "4.6.2" }
                { $_ -gt 394806 -and $_ -le 460805 } { "4.7.0" }
                { $_ -gt 460805 -and $_ -le 461310 } { "4.7.1" }
                { $_ -gt 461310 -and $_ -le 461814 } { "4.7.2" }
                { $_ -gt 461814 } { "4.8.0"}
            }

            if (!$versionString) {
                continue
            }

            Write-Capability -Name ($NameFormat -f $versionString) -Value $installPath
            $LatestValue.Value = $installPath
        }
    }
}

$latest = $null
Add-Versions -NameFormat 'DotNetFramework_{0}' -View 'Registry32' -LatestValue ([ref]$latest)
Add-Versions -NameFormat 'DotNetFramework_{0}_x64' -View 'Registry64' -LatestValue ([ref]$latest)
if ($latest) {
    Write-Capability -Name 'DotNetFramework' -Value $latest
}

# SIG # Begin signature block
# MIIoPAYJKoZIhvcNAQcCoIIoLTCCKCkCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCC0aaovVM6v0u2o
# XGzrZZhCY6U1OHc037uwZhTto6AUmKCCDYUwggYDMIID66ADAgECAhMzAAAEA73V
# lV0POxitAAAAAAQDMA0GCSqGSIb3DQEBCwUAMH4xCzAJBgNVBAYTAlVTMRMwEQYD
# VQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01pY3Jvc29mdCBDb2RlIFNpZ25p
# bmcgUENBIDIwMTEwHhcNMjQwOTEyMjAxMTEzWhcNMjUwOTExMjAxMTEzWjB0MQsw
# CQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9u
# ZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMR4wHAYDVQQDExVNaWNy
# b3NvZnQgQ29ycG9yYXRpb24wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQCfdGddwIOnbRYUyg03O3iz19XXZPmuhEmW/5uyEN+8mgxl+HJGeLGBR8YButGV
# LVK38RxcVcPYyFGQXcKcxgih4w4y4zJi3GvawLYHlsNExQwz+v0jgY/aejBS2EJY
# oUhLVE+UzRihV8ooxoftsmKLb2xb7BoFS6UAo3Zz4afnOdqI7FGoi7g4vx/0MIdi
# kwTn5N56TdIv3mwfkZCFmrsKpN0zR8HD8WYsvH3xKkG7u/xdqmhPPqMmnI2jOFw/
# /n2aL8W7i1Pasja8PnRXH/QaVH0M1nanL+LI9TsMb/enWfXOW65Gne5cqMN9Uofv
# ENtdwwEmJ3bZrcI9u4LZAkujAgMBAAGjggGCMIIBfjAfBgNVHSUEGDAWBgorBgEE
# AYI3TAgBBggrBgEFBQcDAzAdBgNVHQ4EFgQU6m4qAkpz4641iK2irF8eWsSBcBkw
# VAYDVR0RBE0wS6RJMEcxLTArBgNVBAsTJE1pY3Jvc29mdCBJcmVsYW5kIE9wZXJh
# dGlvbnMgTGltaXRlZDEWMBQGA1UEBRMNMjMwMDEyKzUwMjkyNjAfBgNVHSMEGDAW
# gBRIbmTlUAXTgqoXNzcitW2oynUClTBUBgNVHR8ETTBLMEmgR6BFhkNodHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpb3BzL2NybC9NaWNDb2RTaWdQQ0EyMDExXzIw
# MTEtMDctMDguY3JsMGEGCCsGAQUFBwEBBFUwUzBRBggrBgEFBQcwAoZFaHR0cDov
# L3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9jZXJ0cy9NaWNDb2RTaWdQQ0EyMDEx
# XzIwMTEtMDctMDguY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQELBQADggIB
# AFFo/6E4LX51IqFuoKvUsi80QytGI5ASQ9zsPpBa0z78hutiJd6w154JkcIx/f7r
# EBK4NhD4DIFNfRiVdI7EacEs7OAS6QHF7Nt+eFRNOTtgHb9PExRy4EI/jnMwzQJV
# NokTxu2WgHr/fBsWs6G9AcIgvHjWNN3qRSrhsgEdqHc0bRDUf8UILAdEZOMBvKLC
# rmf+kJPEvPldgK7hFO/L9kmcVe67BnKejDKO73Sa56AJOhM7CkeATrJFxO9GLXos
# oKvrwBvynxAg18W+pagTAkJefzneuWSmniTurPCUE2JnvW7DalvONDOtG01sIVAB
# +ahO2wcUPa2Zm9AiDVBWTMz9XUoKMcvngi2oqbsDLhbK+pYrRUgRpNt0y1sxZsXO
# raGRF8lM2cWvtEkV5UL+TQM1ppv5unDHkW8JS+QnfPbB8dZVRyRmMQ4aY/tx5x5+
# sX6semJ//FbiclSMxSI+zINu1jYerdUwuCi+P6p7SmQmClhDM+6Q+btE2FtpsU0W
# +r6RdYFf/P+nK6j2otl9Nvr3tWLu+WXmz8MGM+18ynJ+lYbSmFWcAj7SYziAfT0s
# IwlQRFkyC71tsIZUhBHtxPliGUu362lIO0Lpe0DOrg8lspnEWOkHnCT5JEnWCbzu
# iVt8RX1IV07uIveNZuOBWLVCzWJjEGa+HhaEtavjy6i7MIIHejCCBWKgAwIBAgIK
# YQ6Q0gAAAAAAAzANBgkqhkiG9w0BAQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEyMDAGA1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlm
# aWNhdGUgQXV0aG9yaXR5IDIwMTEwHhcNMTEwNzA4MjA1OTA5WhcNMjYwNzA4MjEw
# OTA5WjB+MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UE
# BxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSgwJgYD
# VQQDEx9NaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQSAyMDExMIICIjANBgkqhkiG
# 9w0BAQEFAAOCAg8AMIICCgKCAgEAq/D6chAcLq3YbqqCEE00uvK2WCGfQhsqa+la
# UKq4BjgaBEm6f8MMHt03a8YS2AvwOMKZBrDIOdUBFDFC04kNeWSHfpRgJGyvnkmc
# 6Whe0t+bU7IKLMOv2akrrnoJr9eWWcpgGgXpZnboMlImEi/nqwhQz7NEt13YxC4D
# dato88tt8zpcoRb0RrrgOGSsbmQ1eKagYw8t00CT+OPeBw3VXHmlSSnnDb6gE3e+
# lD3v++MrWhAfTVYoonpy4BI6t0le2O3tQ5GD2Xuye4Yb2T6xjF3oiU+EGvKhL1nk
# kDstrjNYxbc+/jLTswM9sbKvkjh+0p2ALPVOVpEhNSXDOW5kf1O6nA+tGSOEy/S6
# A4aN91/w0FK/jJSHvMAhdCVfGCi2zCcoOCWYOUo2z3yxkq4cI6epZuxhH2rhKEmd
# X4jiJV3TIUs+UsS1Vz8kA/DRelsv1SPjcF0PUUZ3s/gA4bysAoJf28AVs70b1FVL
# 5zmhD+kjSbwYuER8ReTBw3J64HLnJN+/RpnF78IcV9uDjexNSTCnq47f7Fufr/zd
# sGbiwZeBe+3W7UvnSSmnEyimp31ngOaKYnhfsi+E11ecXL93KCjx7W3DKI8sj0A3
# T8HhhUSJxAlMxdSlQy90lfdu+HggWCwTXWCVmj5PM4TasIgX3p5O9JawvEagbJjS
# 4NaIjAsCAwEAAaOCAe0wggHpMBAGCSsGAQQBgjcVAQQDAgEAMB0GA1UdDgQWBBRI
# bmTlUAXTgqoXNzcitW2oynUClTAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTAL
# BgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBRyLToCMZBD
# uRQFTuHqp8cx0SOJNDBaBgNVHR8EUzBRME+gTaBLhklodHRwOi8vY3JsLm1pY3Jv
# c29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3JsMF4GCCsGAQUFBwEBBFIwUDBOBggrBgEFBQcwAoZCaHR0cDovL3d3
# dy5taWNyb3NvZnQuY29tL3BraS9jZXJ0cy9NaWNSb29DZXJBdXQyMDExXzIwMTFf
# MDNfMjIuY3J0MIGfBgNVHSAEgZcwgZQwgZEGCSsGAQQBgjcuAzCBgzA/BggrBgEF
# BQcCARYzaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL3BraW9wcy9kb2NzL3ByaW1h
# cnljcHMuaHRtMEAGCCsGAQUFBwICMDQeMiAdAEwAZQBnAGEAbABfAHAAbwBsAGkA
# YwB5AF8AcwB0AGEAdABlAG0AZQBuAHQALiAdMA0GCSqGSIb3DQEBCwUAA4ICAQBn
# 8oalmOBUeRou09h0ZyKbC5YR4WOSmUKWfdJ5DJDBZV8uLD74w3LRbYP+vj/oCso7
# v0epo/Np22O/IjWll11lhJB9i0ZQVdgMknzSGksc8zxCi1LQsP1r4z4HLimb5j0b
# pdS1HXeUOeLpZMlEPXh6I/MTfaaQdION9MsmAkYqwooQu6SpBQyb7Wj6aC6VoCo/
# KmtYSWMfCWluWpiW5IP0wI/zRive/DvQvTXvbiWu5a8n7dDd8w6vmSiXmE0OPQvy
# CInWH8MyGOLwxS3OW560STkKxgrCxq2u5bLZ2xWIUUVYODJxJxp/sfQn+N4sOiBp
# mLJZiWhub6e3dMNABQamASooPoI/E01mC8CzTfXhj38cbxV9Rad25UAqZaPDXVJi
# hsMdYzaXht/a8/jyFqGaJ+HNpZfQ7l1jQeNbB5yHPgZ3BtEGsXUfFL5hYbXw3MYb
# BL7fQccOKO7eZS/sl/ahXJbYANahRr1Z85elCUtIEJmAH9AAKcWxm6U/RXceNcbS
# oqKfenoi+kiVH6v7RyOA9Z74v2u3S5fi63V4GuzqN5l5GEv/1rMjaHXmr/r8i+sL
# gOppO6/8MO0ETI7f33VtY5E90Z1WTk+/gFcioXgRMiF670EKsT/7qMykXcGhiJtX
# cVZOSEXAQsmbdlsKgEhr/Xmfwb1tbWrJUnMTDXpQzTGCGg0wghoJAgEBMIGVMH4x
# CzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRt
# b25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xKDAmBgNVBAMTH01p
# Y3Jvc29mdCBDb2RlIFNpZ25pbmcgUENBIDIwMTECEzMAAAQDvdWVXQ87GK0AAAAA
# BAMwDQYJYIZIAWUDBAIBBQCgga4wGQYJKoZIhvcNAQkDMQwGCisGAQQBgjcCAQQw
# HAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcCARUwLwYJKoZIhvcNAQkEMSIEIGls
# cItQe4dbGbFjDJcHXKEzijT3xBBsb/V8KoQJjkCYMEIGCisGAQQBgjcCAQwxNDAy
# oBSAEgBNAGkAYwByAG8AcwBvAGYAdKEagBhodHRwOi8vd3d3Lm1pY3Jvc29mdC5j
# b20wDQYJKoZIhvcNAQEBBQAEggEAVS9pxnJkCIKjXZ/0mj9UePvfZDVbqf9XD076
# ZMR8B1w0k8UduuI2sfn5ivq32NPEQyw/xfC7EAWug3Tj2Yp/qfl+wREzfk68CGkG
# sMnMWBlbM3+wASNS+tM6a4HN7dZMA3LjqEdjxb4DHJv+sGe5YxQU5oAaIXPDpnj3
# FpzTPLgxILqgjIrTXE2tl7xryHxwY/MRhQzIvtYcRkAbG7v916iShXdcuKcLYvAb
# etdFxu+/0+hicv0ZT2GW3f5mcsZ4ymf+22MnQLnb3l1js3qHJcpGMtpiit0SMXQt
# ItERjW0Ofi80n+KuuiFXCi2sRq79E+79M8iXmovOsjMFNnymEaGCF5cwgheTBgor
# BgEEAYI3AwMBMYIXgzCCF38GCSqGSIb3DQEHAqCCF3AwghdsAgEDMQ8wDQYJYIZI
# AWUDBAIBBQAwggFSBgsqhkiG9w0BCRABBKCCAUEEggE9MIIBOQIBAQYKKwYBBAGE
# WQoDATAxMA0GCWCGSAFlAwQCAQUABCD6CixmiekYlRQaE4cLBCUyeVFkUK2DAhnN
# gVRL6+CcyAIGaCZI7z2oGBMyMDI1MDYwNDExMDkyNy4zNDlaMASAAgH0oIHRpIHO
# MIHLMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMH
# UmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQL
# ExxNaWNyb3NvZnQgQW1lcmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxk
# IFRTUyBFU046MzcwMy0wNUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1l
# LVN0YW1wIFNlcnZpY2WgghHtMIIHIDCCBQigAwIBAgITMwAAAgpHshTZ7rKzDwAB
# AAACCjANBgkqhkiG9w0BAQsFADB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2Fz
# aGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENv
# cnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAx
# MDAeFw0yNTAxMzAxOTQyNTdaFw0yNjA0MjIxOTQyNTdaMIHLMQswCQYDVQQGEwJV
# UzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UE
# ChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSUwIwYDVQQLExxNaWNyb3NvZnQgQW1l
# cmljYSBPcGVyYXRpb25zMScwJQYDVQQLEx5uU2hpZWxkIFRTUyBFU046MzcwMy0w
# NUUwLUQ5NDcxJTAjBgNVBAMTHE1pY3Jvc29mdCBUaW1lLVN0YW1wIFNlcnZpY2Uw
# ggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQCy7NzwEpb7BpwAk9LJ00Xq
# 30TcTjcwNZ80TxAtAbhSaJ2kwnJA1Au/Do9/fEBjAHv6Mmtt3fmPDeIJnQ7VBeIq
# 8RcfjcjrbPIg3wA5v5MQflPNSBNOvcXRP+fZnAy0ELDzfnJHnCkZNsQUZ7GF7LxU
# LTKOYY2YJw4TrmcHohkY6DjCZyxhqmGQwwdbjoPWRbYu/ozFem/yfJPyjVBql106
# 8bcVh58A8c5CD6TWN/L3u+Ny+7O8+Dver6qBT44Ey7pfPZMZ1Hi7yvCLv5LGzSB6
# o2OD5GIZy7z4kh8UYHdzjn9Wx+QZ2233SJQKtZhpI7uHf3oMTg0zanQfz7mgudef
# mGBrQEg1ox3n+3Tizh0D9zVmNQP9sFjsPQtNGZ9ID9H8A+kFInx4mrSxA2SyGMOQ
# cxlGM30ktIKM3iqCuFEU9CHVMpN94/1fl4T6PonJ+/oWJqFlatYuMKv2Z8uiprnF
# cAxCpOsDIVBO9K1vHeAMiQQUlcE9CD536I1YLnmO2qHagPPmXhdOGrHUnCUtop21
# elukHh75q/5zH+OnNekp5udpjQNZCviYAZdHsLnkU0NfUAr6r1UqDcSq1yf5Riwi
# mB8SjsdmHll4gPjmqVi0/rmnM1oAEQm3PyWcTQQibYLiuKN7Y4io5bJTVwm+vRRb
# pJ5UL/D33C//7qnHbeoWBQIDAQABo4IBSTCCAUUwHQYDVR0OBBYEFAKvF0EEj4Ay
# PfY8W/qrsAvftZwkMB8GA1UdIwQYMBaAFJ+nFV0AXmJdg/Tl0mWnG1M1GelyMF8G
# A1UdHwRYMFYwVKBSoFCGTmh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMv
# Y3JsL01pY3Jvc29mdCUyMFRpbWUtU3RhbXAlMjBQQ0ElMjAyMDEwKDEpLmNybDBs
# BggrBgEFBQcBAQRgMF4wXAYIKwYBBQUHMAKGUGh0dHA6Ly93d3cubWljcm9zb2Z0
# LmNvbS9wa2lvcHMvY2VydHMvTWljcm9zb2Z0JTIwVGltZS1TdGFtcCUyMFBDQSUy
# MDIwMTAoMSkuY3J0MAwGA1UdEwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUH
# AwgwDgYDVR0PAQH/BAQDAgeAMA0GCSqGSIb3DQEBCwUAA4ICAQCwk3PW0CyjOaqX
# CMOusTde7ep2CwP/xV1J3o9KAiKSdq8a2UR5RCHYhnJseemweMUH2kNefpnAh2Bn
# 8H2opDztDJkj8OYRd/KQysE12NwaY3KOwAW8Rg8OdXv5fUZIsOWgprkCQM0VoFHd
# XYExkJN3EzBbUCUw3yb4gAFPK56T+6cPpI8MJLJCQXHNMgti2QZhX9KkfRAffFYM
# FcpsbI+oziC5Brrk3361cJFHhgEJR0J42nqZTGSgUpDGHSZARGqNcAV5h+OQDLeF
# 2p3URx/P6McUg1nJ2gMPYBsD+bwd9B0c/XIZ9Mt3ujlELPpkijjCdSZxhzu2M3SZ
# WJr57uY+FC+LspvIOH1Opofanh3JGDosNcAEu9yUMWKsEBMngD6VWQSQYZ6X9F80
# zCoeZwTq0i9AujnYzzx5W2fEgZejRu6K1GCASmztNlYJlACjqafWRofTqkJhV/J2
# v97X3ruDvfpuOuQoUtVAwXrDsG2NOBuvVso5KdW54hBSsz/4+ORB4qLnq4/GNtaj
# UHorKRKHGOgFo8DKaXG+UNANwhGNxHbILSa59PxExMgCjBRP3828yGKsquSEzzLN
# Wnz5af9ZmeH4809fwIttI41JkuiY9X6hmMmLYv8OY34vvOK+zyxkS+9BULVAP6gt
# +yaHaBlrln8Gi4/dBr2y6Srr/56g0DCCB3EwggVZoAMCAQICEzMAAAAVxedrngKb
# SZkAAAAAABUwDQYJKoZIhvcNAQELBQAwgYgxCzAJBgNVBAYTAlVTMRMwEQYDVQQI
# EwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3Nv
# ZnQgQ29ycG9yYXRpb24xMjAwBgNVBAMTKU1pY3Jvc29mdCBSb290IENlcnRpZmlj
# YXRlIEF1dGhvcml0eSAyMDEwMB4XDTIxMDkzMDE4MjIyNVoXDTMwMDkzMDE4MzIy
# NVowfDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcT
# B1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UE
# AxMdTWljcm9zb2Z0IFRpbWUtU3RhbXAgUENBIDIwMTAwggIiMA0GCSqGSIb3DQEB
# AQUAA4ICDwAwggIKAoICAQDk4aZM57RyIQt5osvXJHm9DtWC0/3unAcH0qlsTnXI
# yjVX9gF/bErg4r25PhdgM/9cT8dm95VTcVrifkpa/rg2Z4VGIwy1jRPPdzLAEBjo
# YH1qUoNEt6aORmsHFPPFdvWGUNzBRMhxXFExN6AKOG6N7dcP2CZTfDlhAnrEqv1y
# aa8dq6z2Nr41JmTamDu6GnszrYBbfowQHJ1S/rboYiXcag/PXfT+jlPP1uyFVk3v
# 3byNpOORj7I5LFGc6XBpDco2LXCOMcg1KL3jtIckw+DJj361VI/c+gVVmG1oO5pG
# ve2krnopN6zL64NF50ZuyjLVwIYwXE8s4mKyzbnijYjklqwBSru+cakXW2dg3viS
# kR4dPf0gz3N9QZpGdc3EXzTdEonW/aUgfX782Z5F37ZyL9t9X4C626p+Nuw2TPYr
# bqgSUei/BQOj0XOmTTd0lBw0gg/wEPK3Rxjtp+iZfD9M269ewvPV2HM9Q07BMzlM
# jgK8QmguEOqEUUbi0b1qGFphAXPKZ6Je1yh2AuIzGHLXpyDwwvoSCtdjbwzJNmSL
# W6CmgyFdXzB0kZSU2LlQ+QuJYfM2BjUYhEfb3BvR/bLUHMVr9lxSUV0S2yW6r1AF
# emzFER1y7435UsSFF5PAPBXbGjfHCBUYP3irRbb1Hode2o+eFnJpxq57t7c+auIu
# rQIDAQABo4IB3TCCAdkwEgYJKwYBBAGCNxUBBAUCAwEAATAjBgkrBgEEAYI3FQIE
# FgQUKqdS/mTEmr6CkTxGNSnPEP8vBO4wHQYDVR0OBBYEFJ+nFV0AXmJdg/Tl0mWn
# G1M1GelyMFwGA1UdIARVMFMwUQYMKwYBBAGCN0yDfQEBMEEwPwYIKwYBBQUHAgEW
# M2h0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2lvcHMvRG9jcy9SZXBvc2l0b3J5
# Lmh0bTATBgNVHSUEDDAKBggrBgEFBQcDCDAZBgkrBgEEAYI3FAIEDB4KAFMAdQBi
# AEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAWgBTV
# 9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3Js
# Lm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRfMjAx
# MC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8v
# d3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEwLTA2
# LTIzLmNydDANBgkqhkiG9w0BAQsFAAOCAgEAnVV9/Cqt4SwfZwExJFvhnnJL/Klv
# 6lwUtj5OR2R4sQaTlz0xM7U518JxNj/aZGx80HU5bbsPMeTCj/ts0aGUGCLu6WZn
# OlNN3Zi6th542DYunKmCVgADsAW+iehp4LoJ7nvfam++Kctu2D9IdQHZGN5tggz1
# bSNU5HhTdSRXud2f8449xvNo32X2pFaq95W2KFUn0CS9QKC/GbYSEhFdPSfgQJY4
# rPf5KYnDvBewVIVCs/wMnosZiefwC2qBwoEZQhlSdYo2wh3DYXMuLGt7bj8sCXgU
# 6ZGyqVvfSaN0DLzskYDSPeZKPmY7T7uG+jIa2Zb0j/aRAfbOxnT99kxybxCrdTDF
# NLB62FD+CljdQDzHVG2dY3RILLFORy3BFARxv2T5JL5zbcqOCb2zAVdJVGTZc9d/
# HltEAY5aGZFrDZ+kKNxnGSgkujhLmm77IVRrakURR6nxt67I6IleT53S0Ex2tVdU
# CbFpAUR+fKFhbHP+CrvsQWY9af3LwUFJfn6Tvsv4O+S3Fb+0zj6lMVGEvL8CwYKi
# excdFYmNcP7ntdAoGokLjzbaukz5m/8K6TT4JDVnK+ANuOaMmdbhIurwJ0I9JZTm
# dHRbatGePu1+oDEzfbzL6Xu/OHBE0ZDxyKs6ijoIYn/ZcGNTTY3ugm2lBRDBcQZq
# ELQdVTNYs6FwZvKhggNQMIICOAIBATCB+aGB0aSBzjCByzELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjElMCMGA1UECxMcTWljcm9zb2Z0IEFtZXJp
# Y2EgT3BlcmF0aW9uczEnMCUGA1UECxMeblNoaWVsZCBUU1MgRVNOOjM3MDMtMDVF
# MC1EOTQ3MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBTZXJ2aWNloiMK
# AQEwBwYFKw4DAhoDFQDRAMVJlA6bKq93Vnu3UkJgm5HlYaCBgzCBgKR+MHwxCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jv
# c29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMA0GCSqGSIb3DQEBCwUAAgUA6+p67TAi
# GA8yMDI1MDYwNDA3NTczM1oYDzIwMjUwNjA1MDc1NzMzWjB3MD0GCisGAQQBhFkK
# BAExLzAtMAoCBQDr6nrtAgEAMAoCAQACAiLYAgH/MAcCAQACAhJ3MAoCBQDr68xt
# AgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwKgCjAIAgEAAgMHoSCh
# CjAIAgEAAgMBhqAwDQYJKoZIhvcNAQELBQADggEBACOxinUNyjI8vDXZzrKuP+/7
# Y3Cr5nhXxGb1aqkaCG+FVdI0rPRIUEIedc2eOERtIzimOSFwCwndXgm6DUHdi9XW
# FxpD0aKqDyoYQgtWNwNuqIubiwvNsTc2UF06zlpfMaA/y0Z+5E2RPp2KZh+gSzxd
# ZvRhgpaX7m3c0WE1O+TtZ3uBVZ9ff0DimZ4NUT59OFUfXVNlAbeMfWGeJSQcoLbQ
# UqWh/7sYvuNLS6sfnuC/I5REe8IF9TDo+L2rKaPKj2zAQ6nZJZEJXu+DFpvnf30r
# VyFhpSX3XJDq0dtHT+s2OC/tsd/BdAeOlET5JO4gQkdSHy+kkSBQy/Fhm40yO2Ex
# ggQNMIIECQIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3Rv
# bjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0
# aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EgMjAxMAITMwAA
# AgpHshTZ7rKzDwABAAACCjANBglghkgBZQMEAgEFAKCCAUowGgYJKoZIhvcNAQkD
# MQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCDKz5Fk6jYCAjUh1gKeijAC
# HSTBXzJVp285uJrQoT1QrDCB+gYLKoZIhvcNAQkQAi8xgeowgecwgeQwgb0EIE2a
# y/y0epK/X3Z03KTcloqE8u9IXRtdO7Mex0hw9+SaMIGYMIGApH4wfDELMAkGA1UE
# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc
# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0
# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAAIKR7IU2e6ysw8AAQAAAgowIgQge/z+
# 97KgFfiEdfR7jy/QTGdT/+iPN4Pf3PjUgW9LprowDQYJKoZIhvcNAQELBQAEggIA
# q7Y+rEXgFxsKSGJ7Rjt6ckA8tkru0LylVkQaxfeMy7tvhowDg0/57Lq/YMo2VTeY
# /Xf8LORJeQSvr7ALQ/587HMO36xC1xxiUZIVtB5i0+OUUHwFHeiS3JSTBpxbKi4v
# C6d3kw+MRBDcvKsiia3sXfI9GiOpuSY0/D/MbMUhlT82yNX728x3TsLW/lbSud9b
# FiIBItZigS6xizoayBO1hHJu2oacLu8cDu3J0UQt+4dH3B5hlWhLJ+q+jRd7Hlgh
# rJnZddSonG6fRau6vpgZ4nXB5O4JiHRAPwHIh3dq32x4HHNvrx+EORbU/vlOMMn7
# lmRQIlqPz4W3RA9QP1HfSCPOrhXHm429MHeuJrdcgm0gbMC4Bn/6ft7wCGK/j4NZ
# Bs2K/JRv1e12MM+2EahzK4cmvd5xdkVqn6vwynhibP/1H7PoiGdHSZ6vYcGKiUaC
# ugksb0lgeognpaD3BjCMCUyPq45SzHNJput7i516V94bIxqIKpMoQMvHsfhq4Jdd
# tRJIoc+6idWW/a03AcCTWn1mxgFe/9LagLNaFer26WcuWYoDq2uF3Ix9d90l1BMo
# wtgvGgLXcY2x144cRMYEGFOrAmmXPswHAJ95wCCQp/67D+VO4O57/NKjaHDxdYul
# oPgvmLhtdc+366mW42RqJJ9znQm4YYC8/ccULziuHjw=
# SIG # End signature block
