import * as toast from "./toast";
let editor = null;
window.onload = run;
function run() {
    toast.init();
    editor = document.querySelector("#editor");
    if (editor) {
        editor.addEventListener("keydown", (event) => {
            const e = event;
            interceptKeyPress(e, "Tab", () => { });
            interceptKeyPress(e, "Enter", updatePreview);
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
    return { hey: "" };
}
function toMarkUp(doc) { }
