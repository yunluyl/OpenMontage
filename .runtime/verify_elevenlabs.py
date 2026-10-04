"""Read-only credential and OpenMontage adapter check; never synthesizes audio."""
import json
import os
import sys
from pathlib import Path

import requests

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))


def main():
    key = os.environ.get('ELEVENLABS_API_KEY', '')
    if not key or key.startswith('op://'):
        print('Start .runtime/Start-ElevenLabsSession.ps1 first.')
        return 1

    from tools.tool_registry import registry
    from tools.base_tool import ToolStatus

    registry.discover('tools.audio.elevenlabs_tts')
    tool = registry.get('elevenlabs_tts')
    available = tool is not None and tool.get_status() == ToolStatus.AVAILABLE
    report = {'tool': 'elevenlabs_tts', 'registry_available': available}
    success = available
    for name, path in [('user', '/v1/user'), ('voices', '/v2/voices?page_size=1')]:
        try:
            response = requests.get(
                'https://api.elevenlabs.io' + path,
                headers={'xi-api-key': key}, timeout=30, allow_redirects=False,
            )
            report[name + '_http_status'] = response.status_code
            success = success and response.status_code == 200
            if name == 'voices' and response.status_code == 200:
                report['voice_visible'] = bool(response.json().get('voices'))
        except (requests.RequestException, ValueError) as exc:
            report[name + '_error'] = type(exc).__name__
            success = False
    print(json.dumps(report))
    return 0 if success else 1


if __name__ == '__main__':
    raise SystemExit(main())
