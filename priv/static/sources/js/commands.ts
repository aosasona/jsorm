import * as toast from "./toast.js";
import * as markupfns from "./markup.js";

type Response<T> = {
	ok: boolean;
	error?: string;
	data: T;
};

type SaveResponse = Response<{
	document_id: string;
	content: string;
	updated_at: string;
}>;

type EditDetailsResponse = Response<{
	document_id: string;
	title: string;
	is_public: boolean;
}>;

export class Commands {
	private editor: HTMLTextAreaElement;

	constructor(editor: HTMLTextAreaElement) {
		this.editor = editor;
	}

	public getCommandByAction(action: string) {
		let fn: () => void;
		switch (action) {
			case "toggle-left-sidebar":
				fn = this.toggleLeftSidebar;
				break;
			case "toggle-command-palette":
				fn = this.toggleCommandPalette;
				break;
			case "save-document":
				fn = this.saveDocument;
				break;
			case "update-preview":
				fn = this.updatePreview;
				break;
			default:
				console.error(`Unknown binding action: ${action}`);
				fn = () => {};
		}

		return fn.bind(this);
	}

	public isCommandPaletteOpen() {
		const commandPalette = document.getElementById("command-palette");
		if (!commandPalette) return false;
		return !commandPalette.classList.contains("hidden");
	}

	public toggleCommandPalette() {
		const commandPalette = document.getElementById("command-palette");
		if (!commandPalette) return;
		if (commandPalette.classList.contains("hidden")) {
			commandPalette.classList.remove("hidden");
			const commandPaletteInput = commandPalette.getElementsByTagName("input")[0];
			if (commandPaletteInput) {
				commandPaletteInput.focus();
				commandPaletteInput.value = "";
				commandPaletteInput.dispatchEvent(new Event("input"));
			}
		} else {
			commandPalette.classList.add("hidden");
			this.editor?.focus();
		}
	}

	public toggleLeftSidebar() {
		const sidebar = document.getElementById("sidebar");
		if (!sidebar) return;
		const sidebarToggle = document.getElementById("sidebar-toggle");
		const sidebarToggleIcon = sidebarToggle?.querySelector("i");
		if (!sidebarToggle) return;
		const status = sidebar.dataset.status;

		if (status === "open") {
			sidebar?.classList.remove("sidebar-opened");
			sidebar?.classList.add("sidebar-closed");
			sidebar?.setAttribute("data-status", "closed");
			sidebarToggleIcon?.classList.remove("ti-layout-sidebar-right-expand");
			sidebarToggleIcon?.classList.add("ti-layout-sidebar-left-expand");
			this.editor?.focus();
		} else {
			sidebar?.classList.remove("sidebar-closed");
			sidebar?.classList.add("sidebar-opened");
			sidebar?.setAttribute("data-status", "open");
			sidebarToggleIcon?.classList.remove("ti-layout-sidebar-left-expand");
			sidebarToggleIcon?.classList.add("ti-layout-sidebar-right-expand");
			sidebar?.getElementsByTagName("input")?.[0].focus();
		}
	}

	public saveDocument() {
		const saveBtn = document.querySelector("#save-document-btn");
		if (saveBtn?.hasAttribute("disabled")) return;

		const document_id = this.editor.dataset.documentId;
		if (!document_id) return toast.error("No document ID found, please refresh the page and try again");
		const content = this.editor.value;
		if (!content) return toast.error("No content found!");
		if (!this.isValidJSON(content)) return toast.error("Invalid JSON");
		const description = this.editor.dataset.description;

		if (saveBtn) {
			saveBtn.setAttribute("disabled", "true");
			saveBtn.textContent = "Saving...";
		}

		fetch("/documents", {
			method: "PUT",
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify({ document_id, content, description }),
		})
			.then((res) => res.json())
			.then((data: SaveResponse) => {
				if (data?.ok) {
					toast.success("Document saved");
					if (data?.data?.content) this.editor.value = data.data.content;
					this.updatePreview({ showToast: false });
					// Update document ID in URL if it isn't already present (e.g. when creating a new document)
					if (!window.location.href.includes(data.data?.document_id)) {
						window.history.replaceState(null, "", `/e/${data.data.document_id}`);
					}
					return;
				}
				toast.error(data?.error || "An unknown error occurred");
			})
			.catch((err) => {
				console.error(err);
				toast.error("An unknown error occurred!");
			})
			.finally(() => {
				if (!saveBtn) return;
				saveBtn.removeAttribute("disabled");
				saveBtn.textContent = "Save";
			});
	}

	public editDetails() {
		const form = document.querySelector("#edit-details-form") as HTMLFormElement;
		if (!form) return;

		form.addEventListener("submit", (e) => {
			e.preventDefault();
			e.stopPropagation();

			const data = new FormData(form);
			const document_id = this.editor.dataset.documentId;
			if (!document_id) return toast.error("No document ID found, please refresh the page and try again");
			const title = data.get("title");
			const isPublic = data.get("is_public") && data.get("is_public") === "on";

			form.querySelector("button")?.setAttribute("disabled", "true");
			fetch("/documents/details", {
				method: "PATCH",
				headers: {
					"Content-Type": "application/json",
				},
				body: JSON.stringify({ document_id, title, is_public: isPublic ?? false }),
			})
				.then((res) => res.json())
				.then((data: EditDetailsResponse) => {
					if (data?.ok) {
						toast.success("Details updated");
						form.querySelector("[name='title']")?.setAttribute("value", data?.data?.title);
						form.querySelector("[name='is_public']")?.setAttribute("checked", data?.data?.is_public ? "checked" : "");
						return;
					}

					toast.error(data?.error || "An unknown error occurred");
				})
				.catch((err) => {
					console.error(err);
					toast.error("An unknown error occurred!");
				})
				.finally(() => {
					form.querySelector("button")?.removeAttribute("disabled");
				});
		});
	}
	public updatePreview({ showToast } = { showToast: true }) {
		const doc = this.editor.value;
		if (!doc) {
			return;
		}

		const jsonDoc = markupfns._safeJSONParse(doc);
		if (!jsonDoc) {
			return;
		}
		// Update text editor with formatted JSON
		this.editor.value = JSON.stringify(jsonDoc, null, 2);

		// Update preview
		const markup = markupfns.toMarkUp(jsonDoc);
		const preview = document.querySelector("#preview");
		if (preview) {
			preview.innerHTML = markup;
		}

		if (showToast) {
			toast.success("Preview updated");
		}
	}

	private isValidJSON(text: string): boolean {
		try {
			JSON.parse(text);
			return true;
		} catch (e) {
			return false;
		}
	}
}
