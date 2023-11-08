import * as toast from "./toast.js";
import * as markupfns from "./markup.js";

type SaveResponse = {
	ok: boolean;
	error?: string;
	data: {
		document_id: string;
		content: string;
		updated_at: string;
	};
};

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
		} else {
			sidebar?.classList.remove("sidebar-closed");
			sidebar?.classList.add("sidebar-opened");
			sidebar?.setAttribute("data-status", "open");
			sidebarToggleIcon?.classList.remove("ti-layout-sidebar-left-expand");
			sidebarToggleIcon?.classList.add("ti-layout-sidebar-right-expand");
		}
	}

	public saveDocument() {
		const document_id = this.editor.dataset.documentId;
		if (!document_id) return toast.error("No document ID found, please refresh the page and try again");
		const content = this.editor.value;
		if (!content) return toast.error("No content found!");
		if (!this.isValidJSON(content)) return toast.error("Invalid JSON");
		const description = this.editor.dataset.description;

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
				toast.error(err);
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
