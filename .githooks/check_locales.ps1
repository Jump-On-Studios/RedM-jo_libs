$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$localesDirectory = Join-Path $root "jo_libs\locales"
$useIndex = $args -notcontains "--worktree"

function Write-LocalError {
  param([string]$Message)

  [Console]::Error.WriteLine($Message)
}

function Read-IndexOrWorktree {
  param([string]$RelativePath)

  if ($useIndex) {
    $content = & git -C $root show ":$RelativePath" 2>$null
    if ($LASTEXITCODE -eq 0) {
      return ($content -join [Environment]::NewLine)
    }
  }

  $path = Join-Path $root $RelativePath
  return [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
}

function Get-LeafKeys {
  param(
    [object]$Value,
    [string]$Prefix
  )

  if ($null -eq $Value -or $Value -is [string] -or $Value -isnot [pscustomobject]) {
    return $Prefix
  }

  $properties = @($Value.PSObject.Properties)
  if ($properties.Count -eq 0) {
    return $Prefix
  }

  $keys = @()
  foreach ($property in $properties) {
    $key = if ($Prefix) { "$Prefix.$($property.Name)" } else { $property.Name }
    $keys += @(Get-LeafKeys -Value $property.Value -Prefix $key)
  }
  return $keys
}

function Get-LocaleKeys {
  param([string]$Filename)

  $relativePath = "jo_libs/locales/$Filename"
  try {
    $data = Read-IndexOrWorktree -RelativePath $relativePath | ConvertFrom-Json
  } catch {
    throw "Invalid JSON or missing file: $relativePath"
  }

  if ($null -eq $data) {
    throw "The JSON root must be an object: $relativePath"
  }

  return [System.Collections.Generic.HashSet[string]]::new(
    [string[]](Get-LeafKeys -Value $data -Prefix "")
  )
}

try {
  $referenceKeys = Get-LocaleKeys -Filename "en.json"
  $localeFiles = @(Get-ChildItem -Path $localesDirectory -Filter "*.json" -File | Sort-Object Name)
  $errors = 0

  foreach ($localeFile in $localeFiles) {
    if ($localeFile.Name -eq "en.json") {
      continue
    }

    try {
      $localeKeys = Get-LocaleKeys -Filename $localeFile.Name
    } catch {
      Write-LocalError "[locales] ERROR: $($_.Exception.Message)"
      $errors++
      continue
    }

    $missingKeys = @($referenceKeys | Where-Object { -not $localeKeys.Contains($_) } | Sort-Object)
    $extraKeys = @($localeKeys | Where-Object { -not $referenceKeys.Contains($_) } | Sort-Object)

    if ($missingKeys.Count -gt 0) {
      Write-LocalError "[locales] ERROR: $($localeFile.Name) missing keys: $($missingKeys -join ", ")"
      $errors++
    }

    if ($extraKeys.Count -gt 0) {
      Write-LocalError "[locales] ERROR: $($localeFile.Name) extra keys not present in en.json: $($extraKeys -join ", ")"
      $errors++
    }
  }

  if ($errors -gt 0) {
    Write-LocalError "[locales] Commit rejected. Synchronize keys with en.json."
    exit 1
  }

  Write-Output "[locales] OK: $($referenceKeys.Count) keys checked in $($localeFiles.Count) files."
  exit 0
} catch {
  Write-LocalError "[locales] ERROR: $($_.Exception.Message)"
  exit 1
}
