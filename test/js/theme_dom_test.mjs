import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import test from 'node:test';
import vm from 'node:vm';

const themeSource = readFileSync(
  new URL('../../assets/js/theme.js', import.meta.url),
  'utf8',
);

class FakeClassList {
  constructor(element) {
    this.element = element;
  }

  add(name) {
    const names = new Set((this.element.getAttribute('class') ?? '').split(/\s+/).filter(Boolean));
    names.add(name);
    this.element.setAttribute('class', [...names].join(' '));
  }

  remove(name) {
    const names = (this.element.getAttribute('class') ?? '').split(/\s+/).filter((item) => item && item !== name);
    this.element.setAttribute('class', names.join(' '));
  }

  contains(name) {
    return (this.element.getAttribute('class') ?? '').split(/\s+/).includes(name);
  }
}

class FakeStyle {
  constructor(element) {
    this.element = element;
    this.properties = new Map();
  }

  setProperty(property, value, priority = '') {
    this.properties.set(property, { value, priority });
    if (property === 'color') {
      const declarations = (this.element.getAttribute('style') ?? '')
        .split(';')
        .map((part) => part.trim())
        .filter((part) => part && !/^color\s*:/i.test(part));
      declarations.push(`color: ${value}${priority ? ' !important' : ''}`);
      this.element.setAttribute('style', declarations.join('; '));
    }
  }
}

class FakeElement {
  constructor(document, tagName, attributes = {}, text = '') {
    this.ownerDocument = document;
    this.tagName = tagName.toUpperCase();
    this.nodeType = 1;
    this.attributes = new Map();
    this.children = [];
    this.parentNode = null;
    this.listeners = new Map();
    this._text = text;
    this.style = new FakeStyle(this);
    this.classList = new FakeClassList(this);
    for (const [name, value] of Object.entries(attributes)) {
      this.attributes.set(name, String(value));
    }
  }

  get isConnected() {
    let node = this;
    while (node) {
      if (node === this.ownerDocument) return true;
      node = node.parentNode;
    }
    return false;
  }

  get textContent() {
    return this._text + this.children.map((child) => child.textContent).join('');
  }

  set textContent(value) {
    this._text = String(value);
    this.children = [];
  }

  get innerText() {
    return this.textContent;
  }

  setAttribute(name, value) {
    this.attributes.set(name, String(value));
    this.ownerDocument?.recordAttribute(this, name);
  }

  getAttribute(name) {
    return this.attributes.has(name) ? this.attributes.get(name) : null;
  }

  hasAttribute(name) {
    return this.attributes.has(name);
  }

  removeAttribute(name) {
    this.attributes.delete(name);
    this.ownerDocument?.recordAttribute(this, name);
  }

  appendChild(child) {
    child.parentNode = this;
    this.children.push(child);
    this.ownerDocument?.recordChildList(this, [child]);
    return child;
  }

  replaceChild(replacement, previous) {
    const index = this.children.indexOf(previous);
    assert.notEqual(index, -1, 'replacement target is a child');
    replacement.parentNode = this;
    previous.parentNode = null;
    this.children[index] = replacement;
    this.ownerDocument?.recordChildList(this, [replacement]);
    return previous;
  }

  removeChild(child) {
    const index = this.children.indexOf(child);
    if (index >= 0) {
      this.children.splice(index, 1);
      child.parentNode = null;
      this.ownerDocument?.recordChildList(this, []);
    }
    return child;
  }

  remove() {
    this.parentNode?.removeChild(this);
  }

  contains(other) {
    for (let node = other; node; node = node.parentNode) {
      if (node === this) return true;
    }
    return false;
  }

  closest(selector) {
    for (let node = this; node?.nodeType === 1; node = node.parentNode) {
      if (node.matches(selector)) return node;
    }
    return null;
  }

  matches(selector) {
    return selector.split(',').some((part) => this.matchesOne(part.trim()));
  }

  matchesOne(selector) {
    if (selector === 'pre.shiki code span[style]') {
      return this.tagName === 'SPAN' &&
        this.hasAttribute('style') &&
        this.closest('code') !== null &&
        this.closest('pre.shiki') !== null;
    }
    if (selector === 'pre.shiki') {
      return this.tagName === 'PRE' && this.classList.contains('shiki');
    }
    if (selector === 'pre') return this.tagName === 'PRE';
    if (selector === 'button') return this.tagName === 'BUTTON';
    if (selector === '.hljs-copy') return this.classList.contains('hljs-copy');
    if (selector === '.theme-toggle') return this.classList.contains('theme-toggle');
    if (selector === '.ready') return this.classList.contains('ready');
    if (selector === '.success') return this.classList.contains('success');
    if (selector === '.relative') return this.classList.contains('relative');
    if (selector === '#darkModeToggle') return this.getAttribute('id') === 'darkModeToggle';
    if (selector === "button.code-copy-btn[data-code]") {
      return this.tagName === 'BUTTON' && this.classList.contains('code-copy-btn') && this.hasAttribute('data-code');
    }
    if (selector === "button[aria-label='Copy code'][data-code]") {
      return this.tagName === 'BUTTON' && this.getAttribute('aria-label') === 'Copy code' && this.hasAttribute('data-code');
    }
    if (selector === 'style[data-freedium-injected]') {
      return this.tagName === 'STYLE' && this.hasAttribute('data-freedium-injected');
    }
    if (selector === 'link[href*="highlight.js"][href*="styles"]') {
      return this.tagName === 'LINK' &&
        (this.getAttribute('href') ?? '').includes('highlight.js') &&
        (this.getAttribute('href') ?? '').includes('styles');
    }
    if (selector.startsWith('pre:not(.hidden) code')) {
      return this.tagName === 'CODE' && this.closest('pre') !== null && !this.closest('pre').classList.contains('hidden');
    }
    if (selector === 'pre code') return this.tagName === 'CODE' && this.closest('pre') !== null;
    if (selector === 'code') return this.tagName === 'CODE';
    if (selector === 'h1') return this.tagName === 'H1';
    if (selector === 'p') return this.tagName === 'P';
    if (selector === 'span') return this.tagName === 'SPAN';
    if (selector === 'div') return this.tagName === 'DIV';
    return false;
  }

  querySelectorAll(selector) {
    return this.ownerDocument.queryWithin(this, selector);
  }

  querySelector(selector) {
    return this.querySelectorAll(selector)[0] ?? null;
  }

  cloneNode(deep = false) {
    const clone = new FakeElement(
      this.ownerDocument,
      this.tagName,
      Object.fromEntries(this.attributes),
      this._text,
    );
    if (deep) {
      this.children.forEach((child) => clone.appendChild(child.cloneNode(true)));
    }
    return clone;
  }

  addEventListener(type, callback) {
    const listeners = this.listeners.get(type) ?? new Set();
    listeners.add(callback);
    this.listeners.set(type, listeners);
  }

  dispatch(type, event = {}) {
    for (const callback of this.listeners.get(type) ?? []) callback(event);
  }

  focus() {}
  select() {}
}

class FakeMutationObserver {
  constructor(document, callback) {
    this.document = document;
    this.callback = callback;
    this.targets = [];
    this.records = [];
    this.disconnected = false;
    document.observers.add(this);
  }

  observe(target, options) {
    this.targets.push({ target, options });
    this.disconnected = false;
  }

  disconnect() {
    this.targets = [];
    this.records = [];
    this.disconnected = true;
  }
}

class FakeDocument {
  constructor() {
    this.nodeType = 9;
    this.parentNode = null;
    this.observers = new Set();
    this.metrics = { fullDocumentCodeScans: 0, codeNodeVisits: 0, subtreeCodeScans: 0 };
    this.readyState = 'complete';
    this.title = 'Test article | Freedium';
    this.baseURI = 'https://mirror.example/article';
    this.eventListeners = new Map();
    this.documentElement = new FakeElement(this, 'html');
    this.head = new FakeElement(this, 'head');
    this.body = new FakeElement(this, 'body');
    this.documentElement.appendChild(this.head);
    this.documentElement.appendChild(this.body);
    this.documentElement.parentNode = this;
    this.execCommandCalls = [];
    this.lastTextarea = null;
  }

  createElement(tagName) {
    const element = new FakeElement(this, tagName);
    if (tagName.toLowerCase() === 'textarea') this.lastTextarea = element;
    return element;
  }

  addEventListener(type, callback) {
    const listeners = this.eventListeners.get(type) ?? new Set();
    listeners.add(callback);
    this.eventListeners.set(type, listeners);
  }

  removeEventListener(type, callback) {
    this.eventListeners.get(type)?.delete(callback);
  }

  execCommand(command) {
    this.execCommandCalls.push({ command, value: this.lastTextarea?.value });
    return true;
  }

  querySelectorAll(selector) {
    return this.queryWithin(this, selector);
  }

  querySelector(selector) {
    if (selector.includes('theme-color') || selector.startsWith('article ') || selector === 'h1') {
      return null;
    }
    return this.querySelectorAll(selector)[0] ?? null;
  }

  queryWithin(root, selector) {
    const isCodeWorkSelector = [
      ".hljs-copy, button.code-copy-btn[data-code], button[aria-label='Copy code'][data-code]",
      'pre.shiki code span[style]',
      ".hljs-copy, button.code-copy-btn[data-code], button[aria-label='Copy code'][data-code], pre.shiki code span[style]",
    ].includes(selector);
    const nodes = [];
    const visit = (parent) => {
      for (const child of parent.children ?? []) {
        this.metrics.codeNodeVisits += isCodeWorkSelector ? 1 : 0;
        if (child.matches(selector)) nodes.push(child);
        visit(child);
      }
    };
    visit(root === this ? this.documentElement : root);
    if (isCodeWorkSelector) {
      if (root === this) this.metrics.fullDocumentCodeScans++;
      else this.metrics.subtreeCodeScans++;
    }
    return nodes;
  }

  recordChildList(target, addedNodes) {
    this.recordMutation({ type: 'childList', target, addedNodes });
  }

  recordAttribute(target, attributeName) {
    this.recordMutation({ type: 'attributes', target, attributeName, addedNodes: [] });
  }

  recordMutation(record) {
    for (const observer of this.observers) {
      for (const { target, options } of observer.targets) {
        const insideTarget = target === record.target || (options.subtree && target.contains(record.target));
        if (!insideTarget) continue;
        if (record.type === 'childList' && options.childList) observer.records.push(record);
        if (record.type === 'attributes' && options.attributes && options.attributeFilter.includes(record.attributeName)) {
          observer.records.push(record);
        }
        break;
      }
    }
  }

  flushObservers() {
    for (const observer of this.observers) {
      if (observer.records.length === 0) continue;
      const records = observer.records;
      observer.records = [];
      observer.callback(records, observer);
    }
  }
}

class FakeScheduler {
  constructor() {
    this.now = 0;
    this.nextId = 1;
    this.timers = new Map();
    this.frames = new Map();
  }

  setTimeout(callback, delay = 0) {
    const id = this.nextId++;
    this.timers.set(id, { callback, due: this.now + Math.max(0, delay) });
    return id;
  }

  clearTimeout(id) {
    this.timers.delete(id);
  }

  requestAnimationFrame(callback) {
    const id = this.nextId++;
    this.frames.set(id, callback);
    return id;
  }

  cancelAnimationFrame(id) {
    this.frames.delete(id);
  }

  flushFrame(document) {
    const callbacks = [...this.frames.values()];
    this.frames.clear();
    callbacks.forEach((callback) => callback(this.now));
    document.flushObservers();
  }

  advance(ms, document) {
    const end = this.now + ms;
    while (true) {
      const due = [...this.timers.entries()]
        .filter(([, timer]) => timer.due <= end)
        .sort((a, b) => a[1].due - b[1].due)[0];
      if (!due) break;
      const [id, timer] = due;
      this.timers.delete(id);
      this.now = timer.due;
      timer.callback();
      document.flushObservers();
    }
    this.now = end;
  }
}

export function createHarness({ largeTree = 0, secureClipboard = true, source = themeSource } = {}) {
  const document = new FakeDocument();
  const scheduler = new FakeScheduler();
  for (let i = 0; i < largeTree; i++) {
    document.body.appendChild(new FakeElement(document, 'p', {}, `paragraph ${i}`));
  }

  const clipboardWrites = [];
  const toastMessages = [];
  const window = {
    location: { href: document.baseURI },
    isSecureContext: secureClipboard,
    Toaster: { postMessage: (message) => toastMessages.push(message) },
    requestAnimationFrame: (callback) => scheduler.requestAnimationFrame(callback),
    cancelAnimationFrame: (id) => scheduler.cancelAnimationFrame(id),
    addEventListener() {},
    removeEventListener() {},
  };
  const navigator = secureClipboard
    ? { clipboard: { writeText: async (text) => clipboardWrites.push(text) } }
    : {};
  const context = vm.createContext({
    window,
    document,
    navigator,
    MutationObserver: class extends FakeMutationObserver {
      constructor(callback) { super(document, callback); }
    },
    getComputedStyle: () => ({ getPropertyValue: () => 'rgb(255, 255, 255)' }),
    localStorage: { setItem() {} },
    setTimeout: (callback, delay) => scheduler.setTimeout(callback, delay),
    clearTimeout: (id) => scheduler.clearTimeout(id),
    console: { log() {}, warn() {}, error() {} },
    URL,
  });
  const compiledTheme = source
    .replaceAll('%IS_DARK_MODE%', 'false')
    .replaceAll('%SHOW_SITE_POPUPS%', 'true')
    .replaceAll('%CSS_VARS%', '')
    .replaceAll('%CUSTOM_CSS_CONTENT%', '');
  const script = new vm.Script(compiledTheme);

  return {
    clipboardWrites,
    context,
    document,
    scheduler,
    script,
    toastMessages,
    window,
    runTheme() { script.runInContext(context); },
  };
}

function shikiBlock(document, color = '#d73a49', { includeStyle = true } = {}) {
  const pre = new FakeElement(document, 'pre', { class: 'shiki' });
  const code = new FakeElement(document, 'code');
  const attributes = includeStyle ? { style: `color: ${color}` } : {};
  const span = new FakeElement(document, 'span', attributes, 'token');
  code.appendChild(span);
  pre.appendChild(code);
  return { code, pre, span };
}

function copyButton(document, { code = 'const value = 1;', className = 'hljs-copy', includeCode = true } = {}) {
  const attributes = { class: className };
  if (includeCode) attributes['data-code'] = code;
  const button = new FakeElement(document, 'button', attributes);
  button.appendChild(new FakeElement(document, 'span', { class: 'ready block' }, 'Copy'));
  button.appendChild(new FakeElement(document, 'span', { class: 'success hidden' }, 'Copied'));
  return button;
}

function findCopyButton(root) {
  const pending = [...root.children];
  while (pending.length > 0) {
    const node = pending.shift();
    if (node.matches('.hljs-copy, button.code-copy-btn[data-code], button[aria-label=\'Copy code\'][data-code]')) {
      return node;
    }
    pending.unshift(...node.children);
  }
  return null;
}

test('initial code scan colors Shiki tokens and preserves copy clipboard feedback', async () => {
  const harness = createHarness({ largeTree: 3000 });
  const block = shikiBlock(harness.document);
  const sourceButton = copyButton(harness.document);
  block.pre.appendChild(sourceButton);
  harness.document.body.appendChild(block.pre);

  harness.runTheme();

  assert.equal(block.span.style.properties.get('color')?.value, 'var(--app-error)');
  assert.equal(harness.document.metrics.fullDocumentCodeScans, 1);
  assert.equal(harness.document.metrics.codeNodeVisits, 3010);
  const boundButton = findCopyButton(block.pre);
  assert.equal(boundButton.getAttribute('data-freedium-copy-bound'), 'true');
  assert.equal(boundButton.getAttribute('aria-label'), 'Copy code');

  let prevented = false;
  let stopped = false;
  boundButton.dispatch('click', {
    preventDefault() { prevented = true; },
    stopImmediatePropagation() { stopped = true; },
  });
  await Promise.resolve();
  await Promise.resolve();

  assert.equal(prevented, true);
  assert.equal(stopped, true);
  assert.deepEqual(harness.clipboardWrites, ['const value = 1;']);
  assert.deepEqual(harness.toastMessages, ['Text copied to clipboard']);
  assert.equal(boundButton.querySelector('.ready').classList.contains('hidden'), true);
  assert.equal(boundButton.querySelector('.success').classList.contains('block'), true);
});

test('only recolors the foreground color and ignores its own style mutation', () => {
  const harness = createHarness();
  const pre = new FakeElement(harness.document, 'pre', { class: 'shiki' });
  const code = new FakeElement(harness.document, 'code');
  const backgroundOnly = new FakeElement(harness.document, 'span', {
    style: 'background-color: #d73a49',
  });
  const foreground = new FakeElement(harness.document, 'span', {
    style: 'background-color: #d73a49; color: #24292e',
  });
  code.appendChild(backgroundOnly);
  code.appendChild(foreground);
  pre.appendChild(code);
  harness.document.body.appendChild(pre);

  harness.runTheme();
  assert.equal(backgroundOnly.style.properties.has('color'), false);
  assert.equal(foreground.style.properties.get('color')?.value, 'var(--app-on-surface)');

  harness.document.flushObservers();
  assert.equal(harness.scheduler.frames.size, 0, 'the recolor write does not queue another scan');
});

test('coalesces late subtree and attribute hydration without rescanning the document', () => {
  const harness = createHarness({ largeTree: 2000 });
  const lateStyledBlock = shikiBlock(harness.document, '', { includeStyle: false });
  const emptyButton = copyButton(harness.document, { includeCode: false });
  const lateWrapper = new FakeElement(harness.document, 'section');
  lateWrapper.appendChild(lateStyledBlock.pre);
  lateWrapper.appendChild(emptyButton);
  harness.document.body.appendChild(lateWrapper);
  harness.runTheme();

  // These mutations model syntax highlighting and copy metadata arriving
  // after the markup itself has been inserted.
  lateStyledBlock.span.setAttribute('style', 'color: #d73a49');
  emptyButton.setAttribute('data-code', 'late code payload');
  harness.document.flushObservers();
  assert.equal(harness.scheduler.frames.size, 1, 'one frame batches both mutations');
  harness.scheduler.flushFrame(harness.document);

  assert.equal(lateStyledBlock.span.style.properties.get('color')?.value, 'var(--app-error)');
  const boundButton = findCopyButton(lateWrapper);
  assert.equal(boundButton.getAttribute('data-freedium-copy-bound'), 'true');
  assert.equal(boundButton.contentCopy, 'late code payload');
  assert.equal(harness.document.metrics.fullDocumentCodeScans, 1);
  assert.equal(harness.document.metrics.subtreeCodeScans, 2);
  assert.ok(harness.document.metrics.codeNodeVisits < 2020);
});

test('fallback clipboard still copies late code and notifies the app', async () => {
  const harness = createHarness({ secureClipboard: false });
  harness.runTheme();
  const block = shikiBlock(harness.document);
  const button = copyButton(harness.document, { code: 'fallback payload' });
  block.pre.appendChild(button);
  harness.document.body.appendChild(block.pre);
  harness.document.flushObservers();
  harness.scheduler.flushFrame(harness.document);

  const boundButton = findCopyButton(block.pre);
  boundButton.dispatch('click', { preventDefault() {}, stopImmediatePropagation() {} });
  await Promise.resolve();
  await Promise.resolve();

  assert.deepEqual(harness.document.execCommandCalls, [
    { command: 'copy', value: 'fallback payload' },
  ]);
  assert.deepEqual(harness.toastMessages, ['Text copied to clipboard']);
});

test('re-injection replaces observers/styles and keeps the new observer alive', () => {
  const harness = createHarness();
  harness.runTheme();
  const firstObserver = harness.window._freediumCopyObserver;
  assert.equal(firstObserver.disconnected, false);
  assert.equal(harness.document.head.querySelectorAll('style[data-freedium-injected]').length, 2);

  harness.scheduler.advance(8000, harness.document);
  harness.runTheme();
  const secondObserver = harness.window._freediumCopyObserver;
  assert.notEqual(secondObserver, firstObserver);
  assert.equal(firstObserver.disconnected, true);
  assert.equal(secondObserver.disconnected, false);
  assert.equal(harness.document.head.querySelectorAll('style[data-freedium-injected]').length, 2);

  harness.scheduler.advance(2000, harness.document);
  assert.equal(harness.window._freediumCopyObserver, secondObserver);
  assert.equal(secondObserver.disconnected, false);
});
