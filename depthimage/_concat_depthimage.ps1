$in_dir_name = 'in'
$depth_dir_name = 'depth'
$out_dir_name = 'out'
$in_dir_path = Join-Path -Path "." -ChildPath $in_dir_name
$depth_dir_path = Join-Path -Path "." -ChildPath $depth_dir_name
$out_dir_path = Join-Path -Path "." -ChildPath $out_dir_name
if (-not (Test-Path $in_dir_path)) {
  Write-Error "In-Dir does not exists"
  Exit
}
if (-not (Test-Path $depth_dir_path)) {
  Write-Error "Depth-Dir does not exists"
  Exit
}
if (Test-Path $out_dir_path -PathType Leaf) {
  Write-Error "Out-Dir exists but not directory"
  Exit
}
if (-not (Test-Path $out_dir_path)) {
  New-Item -Path "." -Name $out_dir_name -ItemType "directory"
  Write-Host "Create Out-Dir"
}

$depth_image_files = Get-ChildItem -Path $depth_dir_path -Filter "*.*g"

foreach ($ss in $depth_image_files) {
  Write-Host $ss.Name
  if ($ss.Name -match '(.+)\.(.+g)') {
    $orig_filename = $Matches.1 + "." + $Matches.2
    $depth_filename = $Matches.0
    $match_filename = $Matches.1 + "." + "*"
    $orig_file_path = Join-Path -Path $in_dir_path -ChildPath $orig_filename
    $match_file_path = Join-Path -Path $in_dir_path -ChildPath $match_filename
    if (Test-Path $match_file_path) {
      $match_files = Get-ChildItem $match_file_path
      if ($match_files.Length -eq 0) {
        Continue
      }
      $source_file = $match_files[0]
      $out_file_name = $source_file.Name
      $out_file_path = Join-Path -Path $out_dir_path -ChildPath $out_file_name
      Write-Host "Concat: " $ss.Name $source_file.Name
      magick convert $source_file.FullName $ss.FullName +append $out_file_path
    }
  }
}

