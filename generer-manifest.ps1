# Met a jour manifest.json a partir des .jar du dossier "mods".
# Lance-le apres avoir ajoute / retire / remplace un mod, puis envoie tout sur GitHub.
$ErrorActionPreference = 'Stop'
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$base = 'https://raw.githubusercontent.com/Close24/atom-modpack/main/mods/'
$manifestPath = Join-Path $here 'manifest.json'

$old = Get-Content $manifestPath -Raw | ConvertFrom-Json
$ver = 1
if ($old.packVersion -match '^\d+$') { $ver = [int]$old.packVersion + 1 }

$mods = @()
Get-ChildItem (Join-Path $here 'mods') -Filter *.jar | Sort-Object Name | ForEach-Object {
  $sha = (Get-FileHash $_.FullName -Algorithm SHA1).Hash.ToLower()
  $mods += [ordered]@{
    file = $_.Name
    url  = $base + [uri]::EscapeDataString($_.Name)
    sha1 = $sha
    size = $_.Length
  }
  Write-Host ("  + " + $_.Name)
}

$manifest = [ordered]@{
  name        = 'ATOM'
  packVersion = "$ver"
  minecraft   = $old.minecraft
  forge       = $old.forge
  mods        = @($mods)
}
$json = ConvertTo-Json -InputObject $manifest -Depth 5
[System.IO.File]::WriteAllText($manifestPath, $json, (New-Object System.Text.UTF8Encoding $false))
Write-Host ""
Write-Host ("manifest.json mis a jour : version " + $ver + ", " + $mods.Count + " mod(s).")
