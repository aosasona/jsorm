import * as toast from "./toast.js";
import * as markupfns from "./markup.js";
export class Commands {
    constructor(editor) {
        this.editor = editor;
    }
    getCommandByAction(action) {
        let fn;
        switch (action) {
            case "new-document":
                fn = this.newDocument;
                break;
            case "save-document":
                fn = this.saveDocument;
                break;
            case "update-preview":
                fn = this.updatePreview;
                break;
            case "toggle-left-sidebar":
                fn = this.toggleLeftSidebar;
                break;
            case "toggle-command-palette":
                fn = this.toggleCommandPalette;
                break;
            default:
                console.error(`Unknown binding action: ${action}`);
                fn = () => { };
        }
        return fn.bind(this);
    }
    isCommandPaletteOpen() {
        const commandPalette = document.getElementById("command-palette");
        if (!commandPalette)
            return false;
        return !commandPalette.classList.contains("hidden");
    }
    toggleCommandPalette() {
        var _a;
        const commandPalette = document.getElementById("command-palette");
        if (!commandPalette)
            return;
        if (commandPalette.classList.contains("hidden")) {
            commandPalette.classList.remove("hidden");
            commandPalette.classList.add("command-palette-opened");
            const commandPaletteInput = commandPalette.getElementsByTagName("input")[0];
            if (commandPaletteInput) {
                commandPaletteInput.focus();
                commandPaletteInput.value = "";
                commandPaletteInput.dispatchEvent(new Event("input"));
            }
        }
        else {
            commandPalette.classList.remove("command-palette-opened");
            commandPalette.classList.add("hidden");
            (_a = this.editor) === null || _a === void 0 ? void 0 : _a.focus();
        }
    }
    newDocument() {
        this.saveDocument();
        window.location.href = "/e";
    }
    toggleLeftSidebar() {
        var _a, _b;
        const sidebar = document.getElementById("sidebar");
        if (!sidebar)
            return;
        const sidebarToggle = document.getElementById("sidebar-toggle");
        const sidebarToggleIcon = sidebarToggle === null || sidebarToggle === void 0 ? void 0 : sidebarToggle.querySelector("i");
        if (!sidebarToggle)
            return;
        const status = sidebar.dataset.status;
        if (status === "open") {
            sidebar === null || sidebar === void 0 ? void 0 : sidebar.classList.remove("sidebar-opened");
            sidebar === null || sidebar === void 0 ? void 0 : sidebar.classList.add("sidebar-closed");
            sidebar === null || sidebar === void 0 ? void 0 : sidebar.setAttribute("data-status", "closed");
            sidebarToggleIcon === null || sidebarToggleIcon === void 0 ? void 0 : sidebarToggleIcon.classList.remove("ti-layout-sidebar-right-expand");
            sidebarToggleIcon === null || sidebarToggleIcon === void 0 ? void 0 : sidebarToggleIcon.classList.add("ti-layout-sidebar-left-expand");
            (_a = this.editor) === null || _a === void 0 ? void 0 : _a.focus();
        }
        else {
            sidebar === null || sidebar === void 0 ? void 0 : sidebar.classList.remove("sidebar-closed");
            sidebar === null || sidebar === void 0 ? void 0 : sidebar.classList.add("sidebar-opened");
            sidebar === null || sidebar === void 0 ? void 0 : sidebar.setAttribute("data-status", "open");
            sidebarToggleIcon === null || sidebarToggleIcon === void 0 ? void 0 : sidebarToggleIcon.classList.remove("ti-layout-sidebar-left-expand");
            sidebarToggleIcon === null || sidebarToggleIcon === void 0 ? void 0 : sidebarToggleIcon.classList.add("ti-layout-sidebar-right-expand");
            (_b = sidebar === null || sidebar === void 0 ? void 0 : sidebar.getElementsByTagName("input")) === null || _b === void 0 ? void 0 : _b[0].focus();
        }
    }
    saveDocument() {
        const saveBtn = document.querySelector("#save-document-btn");
        if (saveBtn === null || saveBtn === void 0 ? void 0 : saveBtn.hasAttribute("disabled"))
            return;
        const document_id = this.editor.dataset.documentId;
        if (!document_id)
            return toast.error("No document ID found, please refresh the page and try again");
        const content = this.editor.value;
        if (!content)
            return toast.error("No content found!");
        if (!this.isValidJSON(content))
            return toast.error("Invalid JSON");
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
            .then((data) => {
            var _a, _b;
            if (data === null || data === void 0 ? void 0 : data.ok) {
                toast.success("Document saved");
                if ((_a = data === null || data === void 0 ? void 0 : data.data) === null || _a === void 0 ? void 0 : _a.content)
                    this.editor.value = data.data.content;
                this.updatePreview({ showToast: false });
                // Update document ID in URL if it isn't already present (e.g. when creating a new document)
                if (!window.location.href.includes((_b = data.data) === null || _b === void 0 ? void 0 : _b.document_id)) {
                    window.history.replaceState(null, "", `/e/${data.data.document_id}`);
                }
                return;
            }
            toast.error((data === null || data === void 0 ? void 0 : data.error) || "An unknown error occurred");
        })
            .catch((err) => {
            console.error(err);
            toast.error("An unknown error occurred!");
        })
            .finally(() => {
            if (!saveBtn)
                return;
            saveBtn.removeAttribute("disabled");
            saveBtn.textContent = "Save";
        });
    }
    handleEditDetails() {
        const form = document.querySelector("#edit-details-form");
        if (!form)
            return;
        form.addEventListener("submit", (e) => {
            var _a;
            e.preventDefault();
            e.stopPropagation();
            const data = new FormData(form);
            const document_id = this.editor.dataset.documentId;
            if (!document_id)
                return toast.error("No document ID found, please refresh the page and try again");
            const title = data.get("title");
            const isPublic = data.get("is_public") && data.get("is_public") === "on" ? 1 : 0;
            console.log({ document_id, title, isPublic });
            (_a = form.querySelector("button")) === null || _a === void 0 ? void 0 : _a.setAttribute("disabled", "true");
            fetch("/documents/details", {
                method: "PATCH",
                headers: {
                    "Content-Type": "application/json",
                },
                body: JSON.stringify({ document_id, title, is_public: isPublic }),
            })
                .then((res) => res.json())
                .then((data) => {
                if (data === null || data === void 0 ? void 0 : data.ok) {
                    toast.success("Details updated");
                    return;
                }
                toast.error((data === null || data === void 0 ? void 0 : data.error) || "An unknown error occurred");
            })
                .catch((err) => {
                console.error(err);
                toast.error("An unknown error occurred!");
            })
                .finally(() => {
                var _a;
                (_a = form.querySelector("button")) === null || _a === void 0 ? void 0 : _a.removeAttribute("disabled");
            });
        });
    }
    updatePreview({ showToast } = { showToast: true }) {
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
        this.handleExpandedAction();
        if (showToast) {
            toast.success("Preview updated");
        }
    }
    isValidJSON(text) {
        try {
            JSON.parse(text);
            return true;
        }
        catch (e) {
            return false;
        }
    }
    handleExpandedAction() {
        const objs = document.querySelectorAll("#object-markup-title");
        objs.forEach((obj) => {
            obj.addEventListener("click", (_) => {
                var _a, _b, _c, _d, _e;
                const expanded = parseInt((_b = (_a = obj.parentElement) === null || _a === void 0 ? void 0 : _a.getAttribute("data-expanded")) !== null && _b !== void 0 ? _b : "0");
                const markup = (_c = obj.parentElement) === null || _c === void 0 ? void 0 : _c.querySelector("#object-markup");
                const icon = obj.querySelector("#expanded-status-icon");
                if (!markup || !icon)
                    return;
                if (expanded) {
                    markup.classList.add("hidden");
                    (_d = obj.parentElement) === null || _d === void 0 ? void 0 : _d.setAttribute("data-expanded", "0");
                    icon.classList.replace("ti-caret-down-filled", "ti-caret-right-filled");
                }
                else {
                    markup.classList.remove("hidden");
                    (_e = obj.parentElement) === null || _e === void 0 ? void 0 : _e.setAttribute("data-expanded", "1");
                    icon.classList.replace("ti-caret-right-filled", "ti-caret-down-filled");
                }
            });
        });
    }
}
