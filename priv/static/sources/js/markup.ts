import * as toast from "./toast.js";

export function _safeJSONParse(text: string): Record<string, unknown> | null {
	try {
		return JSON.parse(text);
	} catch (e) {
		toast.error("Invalid JSON", "3s");
		return null;
	}
}

function getIndentationClass(isNested: boolean): string {
	return isNested ? "ml-4" : "";
}

export function toMarkUp(doc: Record<string, unknown>, isNested: boolean = false) {
	let result = "";
	for (const field in doc) {
		if (typeof doc[field] === "object") {
			if (Array.isArray(doc[field])) {
				result += makeArrayMarkup(field, doc[field] as any[], isNested);
			} else {
				result += makeObjectMarkup(field, doc[field] as Record<string, unknown>, isNested);
			}
		} else {
			result += makeFieldMarkup(field, doc[field] as string | number | boolean, isNested);
		}
	}

	return result;
}

function makeObjectMarkup(key: string, value: Record<string, unknown>, isNested: boolean): string {
	let result = "";
	result += `<div class="${getIndentationClass(isNested)}" id="field-obj" data-expanded="1">
  <div class="flex items-center m-0 -ml-1" id="field-obj-title">
    <i class="inline-block mr-1 text-lg text-yellow-400 ti ti-caret-down-filled" id="expanded-icon"></i>
    <b>${key}</b>
  </div>
  `;
	result += toMarkUp(value, true);
	result += "</div>";
	return result;
}

function formatValue(value: string | number | boolean): string {
	const t = typeof value;
	let displayValue = value;
	if (t === "boolean") {
		displayValue = `<span class="text-${value ? "true" : "false"}">${value}</span>`;
	} else if (t === "string") {
		displayValue = `<span class="text-stone-400">"${value}"</span>`;
	} else if (t === "number") {
		displayValue = `<span class="text-yellow-500">${value}</span>`;
	}

	return displayValue?.toString();
}

function makeFieldMarkup(key: string, value: string | number | boolean, isNested: boolean = false): string {
	const displayValue = formatValue(value);
	return `<div class="${getIndentationClass(isNested)}"><b>${key}</b>: ${displayValue}</div>`;
}

function makeArrayMarkup(key: string, value: any[], isNested: boolean): string {
	let result = `<div class="${getIndentationClass(isNested)}"><b>${key}</b>: [`;
	for (const [index, item] of value.entries()) {
		if (typeof item === "object") {
			result += makeObjectMarkup(index.toString(), item, true);
			continue;
		}
		result += `<div class="${getIndentationClass(true)}">${formatValue(item)}</div>`;
	}
	result += "]</div>";
	return result;
}
