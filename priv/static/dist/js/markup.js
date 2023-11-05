import * as toast from "./toast.js";
export function _safeJSONParse(text) {
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
export function toMarkUp(doc, isNested = false) {
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
    result += `<div class="${getIndentationClass(isNested)}" id="field-obj" data-expanded="false">
  <div class="flex items-center m-0 -ml-1" id="field-obj-title">
    <i class="inline-block mr-1 text-lg text-yellow-400 ti ti-caret-right-filled" id="expanded-icon"></i>
    <b>${key}</b>
  </div>
  `;
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
        displayValue = `<span class="text-stone-400">"${value}"</span>`;
    }
    else if (t === "number") {
        displayValue = `<span class="text-yellow-500">${value}</span>`;
    }
    return `<div class="${getIndentationClass(isNested)}"><b>${key}</b>: ${displayValue}</div>`;
}
function makeArrayMarkup(key, value, isNested) {
    let result = `<div class="${getIndentationClass(isNested)}"><b>${key}</b>: [`;
    for (const [index, item] of value.entries()) {
        if (typeof item === "object") {
            result += makeObjectMarkup(index.toString(), item, true);
            continue;
        }
        result += `<div class="${getIndentationClass(true)}">${item}</div>`;
    }
    result += "]</div>";
    return result;
}
