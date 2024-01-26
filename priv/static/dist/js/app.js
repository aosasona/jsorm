import * as keymaps from "./keymaps.js";
import * as toast from "./toast.js";
import { Commands } from "./commands.js";
import { _safeJSONParse } from "./markup.js";
let editor = null;
document.addEventListener("DOMContentLoaded", run);
function $(selector) {
    return document.querySelector(selector);
}
function run() {
    toast.init();
    // If we're on the editor page, attach to the editor - /e/:id, /editor/:id, /editor or /e
    if (location.pathname.match(/^\/(e|editor)(\/[a-zA-Z0-9_-]+)?$/)) {
        attachToEditor();
    }
}
function attachToEditor() {
    var _a, _b;
    editor = document.querySelector("#editor");
    if (!editor)
        return;
    // Set cursor to end of text on load
    editor.focus();
    editor.setSelectionRange(editor.value.length, editor.value.length);
    const cmd = new Commands(editor);
    const bindings = _safeJSONParse((_b = (_a = $("#keymaps")) === null || _a === void 0 ? void 0 : _a.innerHTML) !== null && _b !== void 0 ? _b : "[]");
    keymaps.registerIntercept("Tab", (e) => keymaps.handleTab(e, editor));
    keymaps.registerIntercept("Escape", () => (cmd.isCommandPaletteOpen() ? cmd.toggleCommandPalette() : {}));
    keymaps.registerIntercept("ArrowUp", (e) => keymaps.navigatePalette(e, "up"));
    keymaps.registerIntercept("ArrowDown", (e) => keymaps.navigatePalette(e, "down"));
    for (const binding of bindings) {
        const fn = cmd.getCommandByAction(binding.action);
        keymaps.registerCombination(binding.combos, binding.description, fn);
    }
    keymaps.init();
    handleEventListener("#sidebar-toggle", "click", cmd.toggleLeftSidebar);
    handleEventListener("#palette-toggle", "click", cmd.toggleCommandPalette);
    handleEventListener("#palette-toggle-inner", "click", cmd.toggleCommandPalette);
    handleEventListener("#save-document-btn", "click", () => cmd.saveDocument());
    cmd.updatePreview({ showToast: false });
    cmd.handleEditDetails();
}
function handleEventListener(selector, event, callback) {
    let obj = typeof selector === "string" ? $(selector) : selector;
    if (!obj)
        return;
    obj.addEventListener(event, callback);
    //TODO: handle deinit later
}
