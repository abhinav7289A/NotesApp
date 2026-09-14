#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
python -c "
import json
from app.main import app
print(json.dumps(app.openapi(), indent=2, sort_keys=True))
" > ../contracts/openapi.json
echo "wrote contracts/openapi.json"