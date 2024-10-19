Param(
    [Alias("i")]
    [Parameter(Mandatory=$true,
               Position=0,
               HelpMessage="Literal path to movie file.")]
    [ValidateNotNullOrEmpty()]
    [string]
    $MovieFile,
    [Alias("d")]
    [Parameter(Mandatory=$true,
               HelpMessage="Name of directory for generating image files.")]
    [ValidateNotNullOrEmpty()]
    [string]
    $DirectoryName,
    [Alias("ts")]
    [Parameter(HelpMessage="Target Frame([sec]) which is focused.")]
    [float]
    $TargetSeconds = -1,
    [Alias("ws")]
    [Parameter()]
    [float]
    $WidthSeconds = -1,
    [Alias("ss")]
    [Parameter()]
    [float]
    $StartSeconds = -1,
    [Alias("to")]
    [Parameter()]
    [float]
    $EndSeconds = -1,
    [Alias("r")]
    [Parameter()]
    [float]
    $Framerate = -1,
    [Alias("transpose")]
    [Parameter()]
    [ValidateSet("clock", "cclock", "none")]
    [string[]]
    $ImageRotation = "clock"
)

if (($StartSeconds -lt 0) -or ($EndSeconds -lt 0)) {
    if (($TargetSeconds -lt 0) -or ($WidthSeconds -eq 0)) {
        Write-Error "Cannot determine frames to be extracted."
        Exit
    } else {
        if ($WidthSeconds -lt 0) {
            $WidthSeconds = $WidthSeconds * -1.0
        }
        $StartSeconds = $TargetSeconds - ($WidthSeconds / 2)
        $EndSeconds = $TargetSeconds + ($WidthSeconds / 2)
        if ($StartSeconds -lt 0) {
            Write-Error "WidthSeconds is invalid (ss < 0)."
            Exit
        }
    }
} elseif ($EndSeconds -le $StartSeconds) {
    Write-Error "EndSeconds must be greater than StartSeconds."
    Exit
}

$MovieFileMeta = ffprobe -i $MovieFile -v error -show_streams -of json | ConvertFrom-Json
$MovieMeta = @($MovieFileMeta.streams | ? { $_.codec_type -eq 'video' })
$MovieMeta = $MovieMeta[0]
if ($MovieMeta.r_frame_rate -match '(\d+)/(\d+)') {
    Write-Verbose ("r_frame_rate: {0}" -f $MovieMeta.r_frame_rate)
    $CalculateFramerate = [float]$Matches.1 / [float]$Matches.2
    Write-Verbose ("Calculate framerate: {0}" -f $CalculateFramerate)
    if (($CalculateFramerate -ge 1) -and ($Framerate -le 0)) {
        $Framerate = $CalculateFramerate
    }
}

if ((Test-Path -Path $DirectoryName) -and (Test-Path -Path $DirectoryName -PathType Leaf)) {
    Write-Error $DirectoryName " exists and not directory. exit."
    Exit
}

if (-not(Test-Path -Path $DirectoryName -PathType Container)) {
    Write-Verbose ("Create Directory: {0}" -f $DirectoryName)
    try {
        New-Item -Path $DirectoryName -ItemType Directory
    }
    catch {
        throw $_.Exception.Message
    }
}

$gci_result = Get-ChildItem -Path $DirectoryName -Filter *.png
if ($gci_result.Length -ne 0) {
    try {
        Write-Verbose ("Try to remove images: {0} for {1}" -f $DirectoryName, $gci_result.Length)
        $gci_result | % { Remove-Item $_ }
    }
    catch {
        throw $_.Exception.Message
    }
}

$NumberOfImages = [int][System.Math]::Floor(($EndSeconds - $StartSeconds) * $Framerate)
Write-Verbose ("Images: {0}" -f $NumberOfImages)
$ss = $StartSeconds
<#
$HalfOfImages = [int][System.Math]::Floor(($NumberOfImages / 2))
Write-Verbose ("Images: {0} / 2 -> {1}" -f $NumberOfImages, $HalfOfImages)
$ss = (($TargetFrameNumber - $HalfOfImages) / $Framerate)
$ss = [Math]::Round($ss, 3)
#>



$clockwise = @("-vf", ('transpose={0}' -f $ImageRotation))
if ($ImageRotation -eq "none") {
    $clockwise = @()
}

$param = @("-ss", $ss, "-i", $MovieFile) + $clockwise + @("-pix_fmt", "yuv420p", "-frames:v", $NumberOfImages, "-qmin", 1, "-q:v", 1, ("{0}\%06d.jpg" -f $DirectoryName))
Write-Host $param

& ffmpeg $param
