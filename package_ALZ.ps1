param(
    [string]$version,
    [string]$prerelease = ""
)

New-Item "ALZPurple" -ItemType Directory -Force
Copy-Item -Path "./src/Artifacts/*" -Destination "./ALZPurple" -Recurse -Exclude "ccReport", "testOutput"  -Force

Update-ModuleManifest -Path "./ALZPurple/ALZPurple.psd1" -ModuleVersion $version -Prerelease $prerelease

