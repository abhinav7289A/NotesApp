Push-Location $PSScriptRoot\..
python -c "import json; from app.main import app; print(json.dumps(app.openapi(), indent=2, sort_keys=True))" `
  | Set-Content -Path ..\contracts\openapi.json -Encoding utf8NoBOM
Pop-Location