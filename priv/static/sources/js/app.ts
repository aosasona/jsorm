import * as keymaps from "./keymaps.js";
import * as toast from "./toast.js";
import { Commands } from "./commands.js";
import { _safeJSONParse } from "./markup.js";

let editor: HTMLTextAreaElement | null = null;
window.onload = run;

function $(selector: string): HTMLElement | null {
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
	editor = document.querySelector("#editor");

	if (!editor) {
		console.error("Editor instance not found in DOM");
		return;
	}

	// Set cursor to end of text on load
	editor.focus();
	editor.setSelectionRange(editor.value.length, editor.value.length);

	const cmd = new Commands(editor);
	const bindings = _safeJSONParse($("#keymaps")?.innerHTML ?? "[]") as unknown as { description: string; combos: keymaps.HotKey[]; action: string }[];

	keymaps.registerIntercept("Tab", () => keymaps.handleTab(editor));
	keymaps.registerIntercept("Escape", (e) => (cmd.isCommandPaletteOpen() ? cmd.toggleCommandPalette() : {}));

	for (const binding of bindings) {
		const fn = cmd.getCommandByAction(binding.action);
		keymaps.registerCombination(binding.combos, binding.description, fn);
	}

	keymaps.init();

	$("#sidebar-toggle")?.addEventListener("click", cmd.toggleLeftSidebar);
	$("#save-document-btn")?.addEventListener("click", () => cmd.saveDocument());

	cmd.updatePreview({ showToast: false });

	window.onbeforeunload = () => {
		keymaps.destroy();
	};
}
