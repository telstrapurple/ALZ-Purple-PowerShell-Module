function Get-ALZLocalRelease {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 1, HelpMessage = "Please Provide the location of the local source directory.")]
        [string]
        $localSourceDirectory,

        [Parameter(Mandatory = $false, Position = 2, HelpMessage = "The current release version of the repo.")]
        [string]
        $releaseVersion = 'V0.1.16',

        [Parameter(Mandatory = $false, Position = 3, HelpMessage = "The directory to download the releases to. Defaults to the current directory.")]
        [string]
        $directoryForReleases = "$PWD/releases",

        [Parameter(Mandatory = $false, Position = 4, HelpMessage = "An array of strings contianing the paths to the directories or files that you wish to keep when downloading and extracting from the releases.")]
        [array]
        $directoryAndFilesToKeep = $null
    )

    # Get latest release on repo

    # Check if directory exists
    Write-Verbose "=====> Checking if directory for releases exists: $directoryForReleases"

    if (!(Test-Path $directoryForReleases)) {
        Write-Verbose "Directory does not exist for releases, will now create: $directoryForReleases"
        New-Item -ItemType Directory -Path $directoryForReleases | Out-String | Write-Verbose
    }

    # Check the firectory for this release
    $releaseDirectory = Join-Path $directoryForReleases $releaseVersion

    Write-Verbose "===> Checking if directory for package name exists: $releaseDirectory"

    if (!(Test-Path $releaseDirectory)) {
        Write-Verbose "Directory does not exist for release $($releaseVersion), will now create: $releaseDirectory"
        New-Item -ItemType Directory -Path $releaseDirectory | Out-String | Write-Verbose
    }

    Write-Verbose "===> Checking if any content exists inside of $releaseDirectory"

    $contentInReleaseDirectory = Get-ChildItem -Path $releaseDirectory -Recurse -ErrorAction SilentlyContinue

    if ($null -eq $contentInReleaseDirectory) {
        Write-Verbose "===> Pulling and extracting release $($releaseVersion) into $releaseDirectory"
        New-Item -ItemType Directory -Path "$releaseDirectory/tmp" | Out-String | Write-Verbose
        #copy the zip file to the tmp directory

        if (!(Test-Path $localSourceDirectory)) {
            Write-Verbose "Local source direcotry does not exist for release $($releaseVersion), Please check the file location"
            return $false
        }

        $archiveTempPath = Join-Path $releaseDirectory 'tmp' "$releaseVersion.zip"
        $extractionFolderPath = Join-Path $releaseDirectory 'tmp' 'extracted'

        Copy-Item -Path $localSourceDirectory -Destination $archiveTempPath -Confirm:$false | Out-String | Write-Verbose

        # Invoke-WebRequest -Uri "https://github.com/$repoOrgPlusRepo/archive/refs/tags/$($release.tag_name).zip" -OutFile "$releaseDirectory/tmp/$($release.tag_name).zip" | Out-String | Write-Verbose
        Expand-Archive -Path $archiveTempPath -DestinationPath $extractionFolderPath | Out-String | Write-Verbose
        $extractedSubFolder = Get-ChildItem -Path $extractionFolderPath -Directory

        if ($null -ne $directoryAndFilesToKeep) {
            foreach ($path in $directoryAndFilesToKeep) {
                Write-Verbose "===> Moving $path into $releaseDirectory."
                Move-Item -Path "$($extractedSubFolder.FullName)/$($path)" -Destination "$releaseDirectory" -ErrorAction SilentlyContinue | Out-String | Write-Verbose
            }
        }

        if ($null -eq $directoryAndFilesToKeep) {
            Write-Verbose "===> Moving all extracted contents into $releaseDirectory."
            Move-Item -Path "$($extractedSubFolder.FullName)/*" -Destination "$releaseDirectory" -ErrorAction SilentlyContinue | Out-String | Write-Verbose
        }

        Remove-Item -Path "$releaseDirectory/tmp" -Force -Recurse

    } else {
        Write-Verbose "===> Content already exists in $releaseDirectory. Skipping"
    }

    return $true
}