param($installPath, $toolsPath, $package, $project)
	
	. (Join-Path $toolsPath "cleanProject.ps1")

#Add the proper EnhancerAssembly project setting
$enhancerFile = [System.IO.Path]::Combine($toolsPath, 'enhancer\enhancer.exe')
$enhancerUri = new-object Uri($enhancerFile)
$solutionUri = new-object Uri($project.DTE.Solution.FullName)
$enhancerRelativeUri = $solutionUri.MakeRelativeUri($enhancerUri)
$enhancerRelativePath = $enhancerRelativeUri.ToString().Replace([System.IO.Path]::AltDirectorySeparatorChar, [System.IO.Path]::DirectorySeparatorChar)
if($enhancerRelativeUri.IsAbsoluteUri)
{
	# The Enhancer path is Absolute
	if($enhancerRelativePath.StartsWith("file:"))
	{
		# Avoid getting "file:file:" for files on Shared Drive
		$enhancerRelativePath = $enhancerRelativePath.Substring(5);
	}

	# We don't need to concat the Absolute path with the SolutionDir
	$msbuild.Xml.AddProperty('EnhancerAssembly', $enhancerRelativePath) | out-null
}
else
{
	# The NuGet repository is Relative to the Solution so we need to concat it with the SolutionDir.
	$msbuild.Xml.AddProperty('EnhancerAssembly','$(SolutionDir)\' + $enhancerRelativePath) | out-null
}

# Include the new OpenAccess targets right after the CSharp/VisualBasic targets in order to be before the
# NuGet targets ensuring that the packages restore will be executed before the Enhancement
$openAccessTargetsImport = $msbuild.Xml.CreateImportElement('OpenAccessNuget.targets');
$msTargetsImport = $null
if($project.Type -eq "C#")
{
	$msTargetsImport = $msbuild.Xml.Imports | Where-Object { $_.Project.EndsWith("Microsoft.CSharp.targets") }
}
elseif($project.Type -eq "VB.NET")
{
	$msTargetsImport = $msbuild.Xml.Imports | Where-Object { $_.Project.EndsWith("Microsoft.VisualBasic.targets") }
}

if($msTargetsImport -ne $null)
{
	$msbuild.Xml.InsertAfterChild($openAccessTargetsImport, $msTargetsImport)
}
else
{
	$msbuild.Xml.AddImport($openAccessTargetsImport) 
}

# Save the project
$project.Save()
# SIG # Begin signature block
# MIIXkwYJKoZIhvcNAQcCoIIXhDCCF4ACAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU+E2LAGzg2+uqQHzW6SWDOQ3h
# CpygghK5MIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggS/MIIDp6ADAgECAhAUWbKknAzZKgj5xQMVzT2KMA0GCSqGSIb3DQEBCwUAMH8x
# CzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEfMB0G
# A1UECxMWU3ltYW50ZWMgVHJ1c3QgTmV0d29yazEwMC4GA1UEAxMnU3ltYW50ZWMg
# Q2xhc3MgMyBTSEEyNTYgQ29kZSBTaWduaW5nIENBMB4XDTE2MDEyODAwMDAwMFoX
# DTE2MTIxNjIzNTk1OVowVzELMAkGA1UEBhMCQkcxDjAMBgNVBAgTBVNvZmlhMQ4w
# DAYDVQQHEwVTb2ZpYTETMBEGA1UEChQKVEVMRVJJSyBBRDETMBEGA1UEAxQKVEVM
# RVJJSyBBRDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALZXufjISN0m
# XyNP67TrDt6eIyposvPvYDsvM28ugGnMPr6KAR8iBBocd4i97eQwq4IqiNIb1nSg
# 2OPlmCgAod7mUZO71GS9kW2njwcs7i0PN8xoFnlPAiM8bmdPWlqrc3RRqtvOkRsi
# NtUoOMaIc4Zyd21G136DKxf9zWCIWJfv9z3YicbY1h5PJelS+FVcTtAqujKjPrBz
# MyODNom5Nhljdg4HdlxNuYfOvP0E6A/0eUvh5ni1idt6sZw3JVZTtv+gWoIUfS4I
# aSuCoiemzgKXR+8TlObcYW2BBhcZ8Netd6Ey1QEeXWBi9I2D7XihSIc+/cfx3eUT
# aJNMRu9c5b0CAwEAAaOCAV0wggFZMAkGA1UdEwQCMAAwDgYDVR0PAQH/BAQDAgeA
# MCsGA1UdHwQkMCIwIKAeoByGGmh0dHA6Ly9zdi5zeW1jYi5jb20vc3YuY3JsMGEG
# A1UdIARaMFgwVgYGZ4EMAQQBMEwwIwYIKwYBBQUHAgEWF2h0dHBzOi8vZC5zeW1j
# Yi5jb20vY3BzMCUGCCsGAQUFBwICMBkMF2h0dHBzOi8vZC5zeW1jYi5jb20vcnBh
# MBMGA1UdJQQMMAoGCCsGAQUFBwMDMFcGCCsGAQUFBwEBBEswSTAfBggrBgEFBQcw
# AYYTaHR0cDovL3N2LnN5bWNkLmNvbTAmBggrBgEFBQcwAoYaaHR0cDovL3N2LnN5
# bWNiLmNvbS9zdi5jcnQwHwYDVR0jBBgwFoAUljtT8Hkzl699g+8uK8zKt4YecmYw
# HQYDVR0OBBYEFHyLDsSFScdMklkrzSXW+JAAuOrjMA0GCSqGSIb3DQEBCwUAA4IB
# AQAHn1Y3Ot+ZXyoxm4XQTWJ0u9cadtpHfBShYvWLor42/V4Ddoaw9P5e3RQ6K8mJ
# BGBamC4vIaWe0angg7+F8oRQMt4tBGu3qqsUZbZP4mcNXQ4ytnCdcgoZK+hLF0x2
# dmzVPdtX+AAtPzp0VMpe8X7pFYKfTIJXMye9cWkCnYxiiHQlpAj9y+O1bUIcqNu1
# +hgodwGSOYN7/9qsqPBLOvZVlIntuuUq1jC3aG/afd8R3bm4E4ns8a0ueUuzUDBp
# U1JPzPG2Ia2Ogmd7D3jN3iPOnG066ADd81Ve4rv8lMyBLJ0c9O0AsR2GrYsv0PHb
# PIUAyT5HS+4HsGRsU/xbzhrKMIIFWTCCBEGgAwIBAgIQPXjX+XZJYLJhffTwHsqG
# KjANBgkqhkiG9w0BAQsFADCByjELMAkGA1UEBhMCVVMxFzAVBgNVBAoTDlZlcmlT
# aWduLCBJbmMuMR8wHQYDVQQLExZWZXJpU2lnbiBUcnVzdCBOZXR3b3JrMTowOAYD
# VQQLEzEoYykgMjAwNiBWZXJpU2lnbiwgSW5jLiAtIEZvciBhdXRob3JpemVkIHVz
# ZSBvbmx5MUUwQwYDVQQDEzxWZXJpU2lnbiBDbGFzcyAzIFB1YmxpYyBQcmltYXJ5
# IENlcnRpZmljYXRpb24gQXV0aG9yaXR5IC0gRzUwHhcNMTMxMjEwMDAwMDAwWhcN
# MjMxMjA5MjM1OTU5WjB/MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMg
# Q29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxMDAu
# BgNVBAMTJ1N5bWFudGVjIENsYXNzIDMgU0hBMjU2IENvZGUgU2lnbmluZyBDQTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAJeDHgAWryyx0gjE12iTUWAe
# cfbiR7TbWE0jYmq0v1obUfejDRh3aLvYNqsvIVDanvPnXydOC8KXyAlwk6naXA1O
# pA2RoLTsFM6RclQuzqPbROlSGz9BPMpK5KrA6DmrU8wh0MzPf5vmwsxYaoIV7j02
# zxzFlwckjvF7vjEtPW7ctZlCn0thlV8ccO4XfduL5WGJeMdoG68ReBqYrsRVR1PZ
# szLWoQ5GQMWXkorRU6eZW4U1V9Pqk2JhIArHMHckEU1ig7a6e2iCMe5lyt/51Y2y
# NdyMK29qclxghJzyDJRewFZSAEjM0/ilfd4v1xPkOKiE1Ua4E4bCG53qWjjdm9sC
# AwEAAaOCAYMwggF/MC8GCCsGAQUFBwEBBCMwITAfBggrBgEFBQcwAYYTaHR0cDov
# L3MyLnN5bWNiLmNvbTASBgNVHRMBAf8ECDAGAQH/AgEAMGwGA1UdIARlMGMwYQYL
# YIZIAYb4RQEHFwMwUjAmBggrBgEFBQcCARYaaHR0cDovL3d3dy5zeW1hdXRoLmNv
# bS9jcHMwKAYIKwYBBQUHAgIwHBoaaHR0cDovL3d3dy5zeW1hdXRoLmNvbS9ycGEw
# MAYDVR0fBCkwJzAloCOgIYYfaHR0cDovL3MxLnN5bWNiLmNvbS9wY2EzLWc1LmNy
# bDAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUHAwMwDgYDVR0PAQH/BAQDAgEG
# MCkGA1UdEQQiMCCkHjAcMRowGAYDVQQDExFTeW1hbnRlY1BLSS0xLTU2NzAdBgNV
# HQ4EFgQUljtT8Hkzl699g+8uK8zKt4YecmYwHwYDVR0jBBgwFoAUf9Nlp8Ld7Lvw
# MAnzQzn6Aq8zMTMwDQYJKoZIhvcNAQELBQADggEBABOFGh5pqTf3oL2kr34dYVP+
# nYxeDKZ1HngXI9397BoDVTn7cZXHZVqnjjDSRFph23Bv2iEFwi5zuknx0ZP+XcnN
# XgPgiZ4/dB7X9ziLqdbPuzUvM1ioklbRyE07guZ5hBb8KLCxR/Mdoj7uh9mmf6RW
# pT+thC4p3ny8qKqjPQQB6rqTog5QIikXTIfkOhFf1qQliZsFay+0yQFMJ3sLrBkF
# IqBgFT/ayftNTI/7cmd3/SeUx7o1DohJ/o39KK9KEr0Ns5cF3kQMFfo2KwPcwVAB
# 8aERXRTl4r0nS1S+K4ReD6bDdAUK75fDiSKxH3fzvc1D1PFMqT+1i4SvZPLQFCEx
# ggREMIIEQAIBATCBkzB/MQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMg
# Q29ycG9yYXRpb24xHzAdBgNVBAsTFlN5bWFudGVjIFRydXN0IE5ldHdvcmsxMDAu
# BgNVBAMTJ1N5bWFudGVjIENsYXNzIDMgU0hBMjU2IENvZGUgU2lnbmluZyBDQQIQ
# FFmypJwM2SoI+cUDFc09ijAJBgUrDgMCGgUAoHgwGAYKKwYBBAGCNwIBDDEKMAig
# AoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEEAYI3AgEL
# MQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUDufSEuSiYJ1TdypO/LSP
# MMZyAmAwDQYJKoZIhvcNAQEBBQAEggEAa9r3NgXwMcbvvsFe2WJ7wWPY/TjzVo4e
# TCw9MKU/Vw6blNyn4puxZQXMShBQMXxM6njpcw084md3McLatM/hIOWowgyoO3jS
# umS9Bhg+sOUyXnOm/KyAq0QMNNe8YxG1TrrpNVYNnLYw6U+gtPIhRUpSCG38TmSZ
# 1xE0ffZprCscsDJKRfjH5qzfR0p9U9B4/ZRU7amdPkdmRSh8pa78LjxwXH6C2LYZ
# ZfU6bE8Ttoinb6s0u3vOW6p8eMAUhe1wx/jgLoBPhUypmlJRQDefHlpy9xeI4NJT
# YiWhyeoEsMJ1P4SdFKTuRYBDhlqcRNGmmkfViwCX14GccxD03ge6laGCAgswggIH
# BgkqhkiG9w0BCQYxggH4MIIB9AIBATByMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQK
# ExRTeW1hbnRlYyBDb3Jwb3JhdGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBT
# dGFtcGluZyBTZXJ2aWNlcyBDQSAtIEcyAhAOz/Q4yP6/NW4E2GqYGxpQMAkGBSsO
# AwIaBQCgXTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEP
# Fw0xNjA4MjIxNTA1MTRaMCMGCSqGSIb3DQEJBDEWBBRJIawYZHdKto588E5WJGmt
# Hd2hqzANBgkqhkiG9w0BAQEFAASCAQAukruvsTjhuxbfSx5NYtw5inxcr8uJV7XR
# KenH0uthIWVIROUFUYYFzYrMSDeUn/uSyAIUGaJ/jNCiD28Z/mGTU+t0l6ohYHrj
# O1ADJ3wgzU4tt4/PXjDd8d6fFKcjULzQHoyEMR0l6r4DOdUy6Gv5HMyXB2pEn1SE
# rm5glpYQBuFBmASgQCf3xx1xGqr86CMNQPHJdYvkAfzW+16KInHEBe/qnj0o1owS
# jLIjL643GeGWfdjOLq/SeISIx6u+YCtw05aYF6EinJnaig9ThVH9AFVgD4BGSqMF
# qs/M9O7BdoSv69qGlmdZOPN90Glmg/sNF2GVmb3vlvwRVwc8SOnF
# SIG # End signature block
