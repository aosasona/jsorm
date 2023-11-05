import * as keymaps from "./keymaps.js";
import * as toast from "./toast.js";
import { Commands } from "./commands.js";
let editor = null;
window.onload = run;
function $(selector) {
    return document.querySelector(selector);
}
function run() {
    var _a, _b;
    toast.init();
    editor = document.querySelector("#editor");
    if (!editor) {
        console.error("Editor instance not found in DOM");
        return;
    }
    // Set cursor to end of text on load
    editor.focus();
    editor.setSelectionRange(editor.value.length, editor.value.length);
    const cmd = new Commands(editor);
    keymaps.registerIntercept("Tab", null, () => keymaps.handleTab(editor));
    keymaps.registerCombination([
        ["Ctrl", "Enter"],
        ["Meta", "Enter"],
    ], "Update preview without saving", () => cmd.updatePreview());
    keymaps.registerCombination([
        ["Ctrl", "s"],
        ["Meta", "s"],
    ], "Save document and update preview", () => cmd.saveDocument());
    keymaps.registerCombination([
        ["Ctrl", "k"],
        ["Meta", "k"],
    ], "Toggle sidebar", cmd.toggleSidebar);
    keymaps.init();
    (_a = $("#sidebar-toggle")) === null || _a === void 0 ? void 0 : _a.addEventListener("click", cmd.toggleSidebar);
    (_b = $("#save-document-btn")) === null || _b === void 0 ? void 0 : _b.addEventListener("click", () => cmd.saveDocument());
    cmd.updatePreview({ showToast: false });
    window.onbeforeunload = () => {
        keymaps.destroy();
    };
}
