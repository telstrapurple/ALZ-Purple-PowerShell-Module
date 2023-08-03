param(
    [string]$version,
    [string]$prerelease = ""
)

New-Item "ALZ-PURPLE" -ItemType Directory -Force
Copy-Item -Path "./src/Artifacts/*" -Destination "./ALZ-PURPLE" -Recurse -Exclude "ccReport", "testOutput"  -Force

Update-ModuleManifest -Path "./ALZ-PURPLE/ALZ.psd1" -ModuleVersion $version -Prerelease $prerelease

