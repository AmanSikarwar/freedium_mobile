"""Native intent smoke checks. Run reader_test.dart first to seed local mirrors."""
import subprocess
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer

PACKAGE = 'io.github.amansikarwar.freedium_mobile'


class Fixture(BaseHTTPRequestHandler):
    def do_HEAD(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        broken = self.path.startswith('/bad')
        self.send_response(503 if broken else 200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        title = next((name for name in ['Cold', 'Warm', 'View']
                      if name.lower() in self.path), 'Fixture')
        self.wfile.write(f'<html><head><title>{title} intent article</title></head>'
                         f'<body><article><h1>{title} intent article</h1>'
                         '<p>Local Android intent fixture.</p></article></body></html>'.encode())

    def log_message(self, *args):
        pass


def adb(*args):
    return subprocess.check_output(['adb', *args], text=True, timeout=20)


def wait_for_title(title):
    deadline = time.monotonic() + 35
    latest = ''
    while time.monotonic() < deadline:
        adb('shell', 'uiautomator', 'dump', '/sdcard/freedium-smoke.xml')
        latest = adb('exec-out', 'cat', '/sdcard/freedium-smoke.xml')
        if f'{title} intent article' in latest:
            return
        time.sleep(1)
    raise AssertionError(f'{title} article not displayed: {latest[-2000:]}')


def send(action, title):
    args = ['shell', 'am', 'start', '-W', '-n', f'{PACKAGE}/.MainActivity', '-a', action]
    url = f'https://medium.com/native-{title.lower()}'
    if action.endswith('SEND'):
        args += ['-t', 'text/plain', '--es', 'android.intent.extra.TEXT', url]
    else:
        args += ['-d', url]
    adb(*args)
    wait_for_title(title)
    print(f'PASS: {action.rsplit(".", 1)[-1]} -> {title} article', flush=True)


def main():
    server = HTTPServer(('127.0.0.1', 8787), Fixture)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    adb('reverse', 'tcp:8787', 'tcp:8787')
    try:
        adb('shell', 'am', 'force-stop', PACKAGE)
        send('android.intent.action.SEND', 'Cold')
        send('android.intent.action.SEND', 'Warm')
        send('android.intent.action.VIEW', 'View')
        adb('shell', 'input', 'keyevent', 'KEYCODE_BACK')
        wait_for_title('Warm')
        print('PASS: Android back returns to the previous reader', flush=True)
        adb('shell', 'am', 'force-stop', PACKAGE)
        send('android.intent.action.VIEW', 'View')
    finally:
        adb('shell', 'am', 'force-stop', PACKAGE)
        adb('reverse', '--remove', 'tcp:8787')
        server.shutdown()
        server.server_close()


if __name__ == '__main__':
    main()
