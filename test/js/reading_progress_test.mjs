import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const themeSource = readFileSync(
  new URL('../../assets/js/theme.js', import.meta.url),
  'utf8',
);
const trackerStart = themeSource.indexOf(
  '  function installReadingProgressTracking() {',
);
const trackerEnd = themeSource.indexOf(
  '\n  function extractArticleMeta()',
  trackerStart,
);
assert.notEqual(trackerStart, -1, 'reader progress tracker exists in theme.js');
assert.notEqual(trackerEnd, -1, 'reader progress tracker has a closing boundary');
const trackerSource = themeSource.slice(trackerStart, trackerEnd);

function eventTarget() {
  const listeners = new Map();
  return {
    addEventListener(type, callback) {
      const callbacks = listeners.get(type) ?? new Set();
      callbacks.add(callback);
      listeners.set(type, callbacks);
    },
    removeEventListener(type, callback) {
      listeners.get(type)?.delete(callback);
    },
    dispatch(type) {
      for (const callback of listeners.get(type) ?? []) callback();
    },
    listenerCount(type) {
      return listeners.get(type)?.size ?? 0;
    },
  };
}

test('flushes on hide/pagehide and replaces handlers on theme reapply', () => {
  const window = Object.assign(eventTarget(), {
    ReadingProgress: {
      postMessage(message) {
        messages.push(JSON.parse(message));
      },
    },
    location: { href: 'https://mirror.example/article' },
    innerHeight: 500,
    scrollY: 600,
    _freediumReadingProgressPageToken: 12,
  });
  const document = Object.assign(eventTarget(), {
    body: { scrollHeight: 1500 },
    documentElement: { scrollHeight: 1500 },
    visibilityState: 'visible',
  });
  const messages = [];
  const timers = new Map();
  let nextTimerId = 1;
  const context = vm.createContext({
    window,
    document,
    Math,
    JSON,
    setTimeout(callback) {
      const id = nextTimerId++;
      timers.set(id, callback);
      return id;
    },
    clearTimeout(id) {
      timers.delete(id);
    },
  });
  const install = () => {
    vm.runInContext(
      `${trackerSource}\ninstallReadingProgressTracking();`,
      context,
    );
  };

  install();
  window.dispatch('scroll');
  assert.equal(timers.size, 1, 'scroll progress is initially debounced');

  document.visibilityState = 'hidden';
  document.dispatch('visibilitychange');
  assert.equal(timers.size, 0, 'hiding cancels the debounce timer');
  assert.deepEqual(messages, [
    {
      url: 'https://mirror.example/article',
      pageToken: 12,
      progress: '0.600',
    },
  ]);

  window.dispatch('pagehide');
  assert.equal(messages.length, 1, 'duplicate exit signals are deduplicated');

  install();
  assert.equal(window.listenerCount('scroll'), 1);
  assert.equal(window.listenerCount('pagehide'), 1);
  assert.equal(document.listenerCount('visibilitychange'), 1);

  window.scrollY = 650;
  window.dispatch('scroll');
  install();
  assert.equal(
    timers.size,
    0,
    'reapply flushes pending progress before cleanup',
  );
  assert.equal(messages[1].progress, '0.650');
  assert.equal(window.listenerCount('scroll'), 1);

  window.scrollY = 700;
  window.dispatch('scroll');
  for (const [id, callback] of timers) {
    timers.delete(id);
    callback();
  }
  assert.equal(messages.length, 3);
  assert.equal(messages[2].progress, '0.700');
});
