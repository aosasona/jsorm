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
    var _a, _b, _c, _d, _e, _f;
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
    (_c = $("#sidebar-toggle")) === null || _c === void 0 ? void 0 : _c.addEventListener("click", cmd.toggleLeftSidebar);
    (_d = $("#palette-toggle")) === null || _d === void 0 ? void 0 : _d.addEventListener("click", cmd.toggleCommandPalette);
    (_e = $("#palette-toggle-inner")) === null || _e === void 0 ? void 0 : _e.addEventListener("click", cmd.toggleCommandPalette);
    (_f = $("#save-document-btn")) === null || _f === void 0 ? void 0 : _f.addEventListener("click", () => cmd.saveDocument());
    cmd.updatePreview({ showToast: false });
    handleExpandedAction();
    cmd.handleEditDetails();
    window.onbeforeunload = () => {
        keymaps.destroy();
    };
}
function handleExpandedAction() {
    const objs = document.querySelectorAll("#object-markup-title");
    objs.forEach((obj) => {
        obj.addEventListener("click", (_) => {
            var _a, _b, _c, _d, _e;
            const expanded = parseInt((_b = (_a = obj.parentElement) === null || _a === void 0 ? void 0 : _a.getAttribute("data-expanded")) !== null && _b !== void 0 ? _b : "0");
            const markup = (_c = obj.parentElement) === null || _c === void 0 ? void 0 : _c.querySelector("#object-markup");
            const icon = obj.querySelector("#expanded-status-icon");
            if (!markup || !icon)
                return;
            if (expanded) {
                markup.classList.add("hidden");
                (_d = obj.parentElement) === null || _d === void 0 ? void 0 : _d.setAttribute("data-expanded", "0");
                icon.classList.replace("ti-caret-down-filled", "ti-caret-right-filled");
            }
            else {
                markup.classList.remove("hidden");
                (_e = obj.parentElement) === null || _e === void 0 ? void 0 : _e.setAttribute("data-expanded", "1");
                icon.classList.replace("ti-caret-right-filled", "ti-caret-down-filled");
            }
        });
    });
}
