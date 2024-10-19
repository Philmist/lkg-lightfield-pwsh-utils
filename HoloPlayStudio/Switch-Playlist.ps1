Param(
  [string]
  $Playlist = ""
)

$defaultDir = (Resolve-Path ".\New Playlist____").Path

$targetPath = $defaultDir + $Playlist
if (-not (Test-Path $targetPath)) {
  Write-Error "$Playlist dir does not exists: $targetPath"
  Exit
}

$playlistDir = $defaultDir -replace "____", ""

if ((Test-Path $playlistDir) -and ((Get-Item $playlistDir).LinkType -ne "Junction")) {
  Write-Error "Playlist directory is not Junction."
  Exit
}

if (Test-Path $playlistDir) {
  Write-Host "Delete playlist junction: $playlistDir"
  Remove-Item -Path $playlistDir
}

New-Item -ItemType Junction -Path $playlistDir -Target $targetPath -Verbose
