import * as keymaps from "./keymaps.js";
import * as toast from "./toast.js";
import * as cmd from "./commands.js";

let editor: HTMLTextAreaElement | null = null;
window.onload = run;

function $(selector: string): HTMLElement | null {
	return document.querySelector(selector);
}

function run() {
	toast.init();
	editor = document.querySelector("#editor");

	if (!editor) return;

	keymaps.registerIntercept("Tab", null, keymaps.handleTab(editor));

	keymaps.registerCombination(
		[
			["Ctrl", "Enter"],
			["Meta", "Enter"],
		],
		"Format JSON",
		updatePreview
	);
	keymaps.registerCombination(
		[
			["Ctrl", "s"],
			["Meta", "s"],
		],
		"Save document",
		() => console.log("Save")
	);
	keymaps.registerCombination(
		[
			["Ctrl", "k"],
			["Meta", "k"],
		],
		"Toggle sidebar",
		cmd.toggleSidebar
	);

	keymaps.init();

	$("#sidebar-toggle")?.addEventListener("click", cmd.toggleSidebar);

	updatePreview();
}

function updatePreview() {
	const doc = editor?.value;
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

function _safeJSONParse(text: string): Record<string, unknown> | null {
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

function toMarkUp(doc: Record<string, unknown>, isNested: boolean = false) {
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
	result += `<div class="${getIndentationClass(isNested)}" id="field-obj"><b>${key}</b> <span id="obj-indicator">{...}</span>`;
	result += toMarkUp(value, true);
	result += "</div>";
	return result;
}

function makeFieldMarkup(key: string, value: string | number | boolean, isNested: boolean = false): string {
	const t = typeof value;
	let displayValue = value;
	if (t === "boolean") {
		displayValue = `<span class="text-${value ? "true" : "false"}">${value}</span>`;
	} else if (t === "string") {
		displayValue = `"${value}"`;
	} else if (t === "number") {
		displayValue = `${value}`;
	}

	return `<div class="${getIndentationClass(isNested)}"><b>${key}</b>: ${displayValue}</div>`;
}

function makeArrayMarkup(key: string, value: any[], isNested: boolean): string {
	let result = `<div class="${getIndentationClass(isNested)}"><b>${key}</b>: [`;
	for (const item of value) {
		if (typeof item === "object") {
			result += makeFieldMarkup(key, toMarkUp(item as Record<string, unknown>), true);
			continue;
		}
		result += `<div class="${getIndentationClass(true)}">${item}</div>`;
	}
	result += "]</div>";
	return result;
}
