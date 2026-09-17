Push-Location $PSScriptRoot\..
try {
  $json = python -c "import json; from app.main import app; print(json.dumps(app.openapi(), indent=2, sort_keys=True))"
  if ($LASTEXITCODE -ne 0) { throw "openapi generation failed" }
  $out = Join-Path (Resolve-Path ..) "contracts\openapi.json"
  # UTF-8 without BOM, LF endings, so output matches the bash script and CI
  [IO.File]::WriteAllText($out, (($json -join "`n") + "`n"), (New-Object System.Text.UTF8Encoding $false))
  Write-Host "wrote contracts/openapi.json"
} finally {
  Pop-Location
}
