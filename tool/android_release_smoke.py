"""Check cold and warm Android intents on an installed release APK.

The smoke test verifies that supported SEND and VIEW intents open the reader.
It does not depend on the live mirror returning article content.
"""

import re
import subprocess
import time
import xml.etree.ElementTree as ET

PACKAGE = 'io.github.amansikarwar.freedium_mobile'
UI_DUMP_PATH = '/sdcard/freedium-release-smoke.xml'
HOME_TEXT = 'Read Article'
ONBOARDING_TEXT = 'Skip'
READER_TEXT_MARKERS = (
    'Failed to Load Article',
    'Current mirror:',
    'Try Another Mirror',
    'Font size',
    'Share article',
    'Save bookmark',
    'Remove bookmark',
)
BOUNDS_PATTERN = re.compile(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]')


def adb(*args, timeout=20):
    return subprocess.check_output(
        ['adb', *args],
        text=True,
        stderr=subprocess.STDOUT,
        timeout=timeout,
    )


def dump_ui():
    adb('shell', 'uiautomator', 'dump', UI_DUMP_PATH)
    return adb('exec-out', 'cat', UI_DUMP_PATH)


def resumed_activity():
    activities = adb('shell', 'dumpsys', 'activity', 'activities')
    for line in activities.splitlines():
        if (
            'io.github.amansikarwar.freedium_mobile/.MainActivity' in line
            and any(
                marker in line
                for marker in ('mResumedActivity', 'topResumedActivity')
            )
        ):
            return line.strip()
    return ''


def wait_for_text(text, timeout=40):
    deadline = time.monotonic() + timeout
    latest = ''
    while time.monotonic() < deadline:
        latest = dump_ui()
        if text in latest:
            return latest
        time.sleep(0.5)
    raise AssertionError(f'{text!r} not displayed: {latest[-2000:]}')


def tap_text(text):
    hierarchy = ET.fromstring(dump_ui())
    for node in hierarchy.iter():
        if text not in (node.attrib.get('text'), node.attrib.get('content-desc')):
            continue
        bounds = BOUNDS_PATTERN.fullmatch(node.attrib.get('bounds', ''))
        if bounds is None:
            continue
        left, top, right, bottom = map(int, bounds.groups())
        adb(
            'shell',
            'input',
            'tap',
            str((left + right) // 2),
            str((top + bottom) // 2),
        )
        return
    raise AssertionError(f'Could not find a tappable node for {text!r}')


def wait_for_reader_route(label, timeout=20):
    deadline = time.monotonic() + timeout
    reader_samples = 0
    latest = ''
    latest_activity = ''
    while time.monotonic() < deadline:
        latest = dump_ui()
        latest_activity = resumed_activity()
        hierarchy = ET.fromstring(latest)
        reader_visible = any(marker in latest for marker in READER_TEXT_MARKERS)
        webview_visible = any(
            node.attrib.get('class') == 'android.webkit.WebView'
            for node in hierarchy.iter()
        )
        if (
            HOME_TEXT not in latest
            and ONBOARDING_TEXT not in latest
            and latest_activity
            and (reader_visible or webview_visible)
        ):
            reader_samples += 1
            if reader_samples >= 2:
                print(f'PASS: {label} displays the reader route', flush=True)
                return
        else:
            reader_samples = 0
        time.sleep(0.25)
    raise AssertionError(
        f'{label} did not display the reader route; '
        f'resumed activity={latest_activity!r}, UI={latest[-2000:]}'
    )


def start_intent(action, url):
    args = [
        'shell',
        'am',
        'start',
        '-W',
        '-n',
        f'{PACKAGE}/.MainActivity',
        '-a',
        f'android.intent.action.{action}',
    ]
    if action == 'SEND':
        args += ['-t', 'text/plain', '--es', 'android.intent.extra.TEXT', url]
    else:
        args += ['-d', url]
    adb(*args)


def return_to_home(label):
    adb('shell', 'input', 'keyevent', 'KEYCODE_BACK')
    wait_for_text(HOME_TEXT)
    if not resumed_activity():
        raise AssertionError(f'Freedium was not foreground after {label} Back')
    print(f'PASS: Back returns from {label} to Home', flush=True)


def main():
    adb('shell', 'am', 'force-stop', PACKAGE)
    adb('shell', 'pm', 'clear', PACKAGE)

    start_intent('SEND', 'https://medium.com/freedium-ci-cold')
    wait_for_text(ONBOARDING_TEXT)
    tap_text(ONBOARDING_TEXT)
    wait_for_reader_route('cold SEND')
    return_to_home('cold SEND')

    start_intent('VIEW', 'https://medium.com/freedium-ci-view')
    wait_for_reader_route('warm VIEW')
    return_to_home('warm VIEW')

    start_intent('SEND', 'https://medium.com/freedium-ci-warm')
    wait_for_reader_route('warm SEND')
    return_to_home('warm SEND')

    adb('shell', 'am', 'force-stop', PACKAGE)
    print('PASS: release APK cold launch and SEND/VIEW intents', flush=True)


if __name__ == '__main__':
    main()
