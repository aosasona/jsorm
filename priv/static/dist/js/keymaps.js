export const Ctrl = "Ctrl";
export const Meta = "Meta";
export const Alt = "Alt";
export const Shift = "Shift";
const keyIntercepts = [];
export function registerIntercept(key, description, fn) {
    keyIntercepts.push({ key, description, fn });
}
const hotKeys = [];
export function registerCombination(keys, description, fn) {
    for (const key of keys) {
        if (key.length !== 2) {
            throw new Error("An hot key mapping must be an array of length 2");
        }
        hotKeys.push({ keys: key, description, fn });
    }
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
function interceptKeyPress(event, key, fn) {
    if (event.key === key) {
        event.preventDefault();
        event.stopPropagation();
        fn();
    }
}
function handleHotKey(event, hotKey) {
    const [leader, secondaryKey] = hotKey.keys;
    if (isModifierKey(event.key))
        return;
    if (event.key === secondaryKey && event[getModifierKey(leader)]) {
        event.preventDefault();
        event.stopPropagation();
        hotKey.fn();
    }
}
function getModifierKey(key) {
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
function isModifierKey(key) {
    return key === Ctrl || key === Alt || key === Meta || key === Shift;
}
export function handleTab(editor) {
    return () => {
        const start = editor === null || editor === void 0 ? void 0 : editor.selectionStart;
        const end = editor === null || editor === void 0 ? void 0 : editor.selectionEnd;
        if (start && end && editor) {
            editor.value = editor.value.substring(0, start) + "\t" + editor.value.substring(end);
            editor.selectionStart = editor.selectionEnd = start + 1;
        }
    };
}
