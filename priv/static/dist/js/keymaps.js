export const Ctrl = "Ctrl";
export const Meta = "Meta";
export const Alt = "Alt";
export const Shift = "Shift";
const palette = document.getElementById("command-palette");
const keyIntercepts = [];
export function registerIntercept(key, fn) {
    keyIntercepts.push({ key, fn });
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
        fn(event);
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
export function handleTab(e, editor) {
    var _a;
    if (document.activeElement == editor) {
        e.preventDefault();
        e.stopPropagation();
        const start = editor === null || editor === void 0 ? void 0 : editor.selectionStart;
        const end = editor === null || editor === void 0 ? void 0 : editor.selectionEnd;
        if (start && end && editor) {
            editor.value = editor.value.substring(0, start) + "\t" + editor.value.substring(end);
            editor.selectionStart = editor.selectionEnd = start + 1;
        }
    }
    else if (palette && !palette.classList.contains("hidden")) {
        e.preventDefault();
        e.stopPropagation();
        const items = (_a = document.getElementById("documents-list")) === null || _a === void 0 ? void 0 : _a.getElementsByTagName("button");
        if (!items || items.length === 0)
            return;
        // if a button is focused, go back to the input or vice versa
        if (items.length > 0) {
            const active = document.activeElement;
            if (active && active.tagName === "BUTTON") {
                palette.getElementsByTagName("input")[0].focus();
            }
            else {
                items[0].focus();
            }
        }
    }
}
export function navigatePalette(e, direction) {
    var _a, _b;
    if (!palette || palette.classList.contains("hidden"))
        return;
    e.preventDefault();
    e.stopPropagation();
    const items = (_a = document.getElementById("documents-list")) === null || _a === void 0 ? void 0 : _a.getElementsByTagName("button");
    if (!items || items.length === 0)
        return;
    const arrItems = Array.from(items);
    const selectedIndex = arrItems.indexOf(document.activeElement);
    if (selectedIndex === -1) {
        (_b = items.item(0)) === null || _b === void 0 ? void 0 : _b.focus();
        return;
    }
    let nextIndex = direction === "up" ? selectedIndex - 1 : selectedIndex + 1;
    if ((selectedIndex == 0 && direction == "up") || (nextIndex == items.length && direction == "down")) {
        return;
    }
    arrItems[nextIndex].focus();
}
export function handlePaletteNavigation() { }
