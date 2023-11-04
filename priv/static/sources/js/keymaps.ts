export const Ctrl = "Ctrl";
export const Meta = "Meta";
export const Alt = "Alt";
export const Shift = "Shift";

type LeaderKey = typeof Ctrl | typeof Meta | typeof Alt | typeof Shift;
type HotKey = [LeaderKey, string];

type KeyInterceptDefinition = { key: string; description: string | null; fn: () => void };
type HotKeyDefinition = { keys: HotKey; description: string | null; fn: () => void };

const keyIntercepts: KeyInterceptDefinition[] = [];
export function registerKeyIntercept(key: string, description: string | null, fn: () => void) {
  keyIntercepts.push({ key, description, fn });
}

const hotKeys: HotKeyDefinition[] = [];
export function registerHotKey(keys: HotKey, description: string | null, fn: () => void) {
  hotKeys.push({ keys, description, fn });
}

// All keypresses and hotkeys need to be registered before calling init()
export function init() {
  document.addEventListener("keydown", (event) => {
    for (const { key, fn } of keyIntercepts) {
      interceptKeyPress(event, key, fn);
    }
  });

  document.addEventListener("keydown", (event) => {
    for (const hotKey of hotKeys) {
      handleHotKey(event, hotKey);
    }
  });
}

function interceptKeyPress(event: KeyboardEvent, key: string, fn: () => void) {
  if (event.key === key) {
    event.preventDefault();
    event.stopPropagation();
    fn();
  }
}

function handleHotKey(event: KeyboardEvent, hotKey: HotKeyDefinition) {
  const [leader, secondaryKey] = hotKey.keys;
  if (isModifierKey(event.key)) return;
  if (event.key === secondaryKey && event[getModifierKey(leader)]) {
    event.preventDefault();
    event.stopPropagation();
    hotKey.fn();
  }
}

function getModifierKey(key: LeaderKey) {
  switch (key) {
    case Ctrl:
      return "ctrlKey";
    case Alt:
      return "altKey";
    case Meta:
      return "metaKey";
    case Shift:
      return "shiftKey";
  }
}

function isModifierKey(key: string) {
  return key === Ctrl || key === Alt || key === Meta || key === Shift;
}

export function handleTab(editor: HTMLTextAreaElement | null): () => void {
  return () => {
    const start = editor?.selectionStart;
    const end = editor?.selectionEnd;
    if (start && end && editor) {
      editor.value = editor.value.substring(0, start) + "\t" + editor.value.substring(end);
      editor.selectionStart = editor.selectionEnd = start + 1;
    }
  };
}
