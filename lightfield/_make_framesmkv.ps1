Param(
    [string]$Target,
    [string]$Output = "_frames.mkv",
    [switch]$NoRotate
    )

$TargetFile = Resolve-Path $Target

$rotate_transpose = "transpose=clock,"
if ($NoRotate -eq $true) {
    $rotate_transpose = ""
}

#$vf_string = ("-vf `"" + $rotate_transpose + "drawtext=fontfile='c\:/Windows/Fonts/meiryo.ttc':text=%{n}:x=(w-tw)/2:y=h-(2*1h):fontcolor=white:box=1:boxcolor=0x00000099:fontsize=72`"")
$vf_string = ("-vf `"" + $rotate_transpose + "drawtext=fontfile='c\:/Windows/Fonts/meiryo.ttc':text='%{pts\:flt}':x=(w-tw)/2:y=h-(2*1h):fontcolor=white:box=1:boxcolor=0x00000099:fontsize=72`"")
$FFmpegArgs = @('-i ', "`"$TargetFile`"", $vf_string, '-y', '-c:v h264_nvenc', '-cq 40', "`"$Output`"")
$arg = $FFmpegArgs -join " "
$arg = 'ffmpeg ' + $arg
Write-Host $arg

Invoke-Expression $arg

