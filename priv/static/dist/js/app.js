import * as toast from "./toast.js";
let editor = null;
window.onload = run;
function run() {
    toast.init();
    editor = document.querySelector("#editor");
    if (editor) {
        editor.addEventListener("keydown", (event) => {
            const e = event;
            interceptKeyPress(e, "Tab", () => {
                // TODO: insert 4 spaces
            });
        });
        updatePreview();
    }
    function interceptKeyPress(event, key, fn) {
        if (event.key === key) {
            event.preventDefault();
            event.stopPropagation();
        }
        fn();
    }
    function updatePreview() {
        const doc = editor === null || editor === void 0 ? void 0 : editor.value;
        if (!doc) {
            return;
        }
        const jsonDoc = _safeJSONParse(doc);
        if (!jsonDoc) {
            return;
        }
        // Update text editor with formatted JSON
        if (editor) {
            editor.value = JSON.stringify(jsonDoc, null, 2);
        }
        // Update preview
        const markup = toMarkUp(jsonDoc);
        const preview = document.querySelector("#preview");
        if (preview) {
            preview.innerHTML = markup;
        }
    }
    function _safeJSONParse(text) {
        try {
            return JSON.parse(text);
        }
        catch (e) {
            toast.error("Invalid JSON", "3s");
            return null;
        }
    }
    function getIndentationClass(isNested) {
        return isNested ? "ml-4" : "";
    }
    function toMarkUp(doc, isNested = false) {
        let result = "";
        for (const field in doc) {
            if (typeof doc[field] === "object") {
                if (Array.isArray(doc[field])) {
                    result += makeArrayMarkup(field, doc[field], isNested);
                }
                else {
                    result += makeObjectMarkup(field, doc[field], isNested);
                }
            }
            else {
                result += makeFieldMarkup(field, doc[field], isNested);
            }
        }
        return result;
    }
    function makeObjectMarkup(key, value, isNested) {
        let result = "";
        result += `<div class="${getIndentationClass(isNested)}" id="field-obj"><b>${key}</b> <span id="obj-indicator">{...}</span>`;
        result += toMarkUp(value, true);
        result += "</div>";
        return result;
    }
    function makeFieldMarkup(key, value, isNested = false) {
        const t = typeof value;
        let displayValue = value;
        if (t === "boolean") {
            displayValue = `<span class="text-${value ? "true" : "false"}">${value}</span>`;
        }
        else if (t === "string") {
            displayValue = `"${value}"`;
        }
        else if (t === "number") {
            displayValue = `${value}`;
        }
        return `<div class="${getIndentationClass(isNested)}"><b>${key}</b>: ${displayValue}</div>`;
    }
    function makeArrayMarkup(key, value, isNested) {
        let result = `<div class="${getIndentationClass(isNested)}"><b>${key}</b>: [`;
        for (const item of value) {
            if (typeof item === "object") {
                result += makeFieldMarkup(key, toMarkUp(item), true);
                continue;
            }
            result += `<div class="${getIndentationClass(true)}">${item}</div>`;
        }
        result += "]</div>";
        return result;
    }
}
