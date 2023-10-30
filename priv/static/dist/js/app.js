import * as toast from "./toast.js";
let editor = null;
window.onload = run;
function run() {
    toast.init();
    editor = document.querySelector("#editor");
    if (editor) {
        editor.addEventListener("keydown", (event) => {
            const e = event;
            interceptKeyPress(e, "Tab", () => { });
        });
    }
}
function interceptKeyPress(event, key, fn) {
    if (event.key === key) {
        event.preventDefault();
        event.stopPropagation();
    }
    fn();
}
function updatePreview() {
    const document = editor === null || editor === void 0 ? void 0 : editor.value;
}
function _safeJSONParse(text) {
    try {
        return JSON.parse(text);
    }
    catch (e) {
        toast.error("Invalid JSON", "3s");
        return {};
    }
}
function toMarkUp(doc) {
    let result = "";
    for (const field in doc) {
    }
    return result;
}
