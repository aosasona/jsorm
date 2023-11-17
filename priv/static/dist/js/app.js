import * as keymaps from "./keymaps.js";
import * as toast from "./toast.js";
import { Commands } from "./commands.js";
import { _safeJSONParse } from "./markup.js";
let editor = null;
window.onload = run;
function $(selector) {
    return document.querySelector(selector);
}
function run() {
    toast.init();
    // If we're on the editor page, attach to the editor - /e/:id, /editor/:id, /editor or /e
    if (location.pathname.match(/^\/(e|editor)(\/[a-zA-Z0-9_]+)?$/)) {
        attachToEditor();
    }
}
function attachToEditor() {
    var _a, _b, _c, _d;
    editor = document.querySelector("#editor");
    if (!editor) {
        console.error("Editor instance not found in DOM");
        return;
    }
    // Set cursor to end of text on load
    editor.focus();
    editor.setSelectionRange(editor.value.length, editor.value.length);
    const cmd = new Commands(editor);
    const bindings = _safeJSONParse((_b = (_a = $("#keymaps")) === null || _a === void 0 ? void 0 : _a.innerHTML) !== null && _b !== void 0 ? _b : "[]");
    keymaps.registerIntercept("Tab", () => keymaps.handleTab(editor));
    keymaps.registerIntercept("Escape", () => (cmd.isCommandPaletteOpen() ? cmd.toggleCommandPalette() : {}));
    for (const binding of bindings) {
        const fn = cmd.getCommandByAction(binding.action);
        keymaps.registerCombination(binding.combos, binding.description, fn);
    }
    keymaps.init();
    (_c = $("#sidebar-toggle")) === null || _c === void 0 ? void 0 : _c.addEventListener("click", cmd.toggleLeftSidebar);
    (_d = $("#save-document-btn")) === null || _d === void 0 ? void 0 : _d.addEventListener("click", () => cmd.saveDocument());
    cmd.updatePreview({ showToast: false });
    window.onbeforeunload = () => {
        keymaps.destroy();
    };
}
