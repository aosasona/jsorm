import * as keymaps from "./keymaps.js";
import * as toast from "./toast.js";
import { Commands } from "./commands.js";

let editor: HTMLTextAreaElement | null = null;
window.onload = run;

function $(selector: string): HTMLElement | null {
	return document.querySelector(selector);
}

function run() {
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

	keymaps.registerCombination(
		[
			["Ctrl", "Enter"],
			["Meta", "Enter"],
		],
		"Update preview without saving",
		() => cmd.updatePreview()
	);
	keymaps.registerCombination(
		[
			["Ctrl", "s"],
			["Meta", "s"],
		],
		"Save document and update preview",
		() => cmd.saveDocument()
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
	$("#save-document-btn")?.addEventListener("click", () => cmd.saveDocument());

	cmd.updatePreview({ showToast: false });

	window.onbeforeunload = () => {
		keymaps.destroy();
	};
}
