foreach ($ss in Get-ChildItem '*_depth.*g') {
  Write-Host $ss.Name
  if ($ss.Name -match '(.+)_depth\.(.+g)') {
    $orig_filename = $Matches.1 + "." + $Matches.2
    $depth_filename = $Matches.0
    $match_filename = $Matches.1 + "." + "*"
    if (Test-Path $orig_filename) {
      Write-Host "Concat: " $orig_filename
      magick convert $orig_filename $depth_filename +append $orig_filename
      if (Test-Path $depth_filename) {
        Write-Host "Remove: " $depth_filename
        Remove-Item $depth_filename
      }
    } elseif (Test-Path $match_filename) {
      $png_filename = $Matches.1 + ".png"
      $jpg_filename = $Matches.1 + ".jpg"
      if (Test-Path $png_filename) {
        Write-Host "Concat2: " $png_filename $depth_filename
        magick convert $png_filename $depth_filename +append $png_filename
        Write-Host "Remove: " $depth_filename
        Remove-Item $depth_filename
      } elseif (Test-Path $jpg_filename) {
        Write-Host "Concat3: " $jpg_filename $depth_filename
        magick convert $jpg_filename $depth_filename +append $jpg_filename
        Write-Host "Remove: " $depth_filename
        Remove-Item $depth_filename
      }
    }
  }
}

