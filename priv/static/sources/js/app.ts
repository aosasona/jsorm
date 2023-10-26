import * as toast from "./toast";

let editor: HTMLTextAreaElement | null = null;
window.onload = run;

function run() {
  toast.init();
  editor = document.querySelector("#editor");

  if (editor) {
    editor.addEventListener("keydown", (event) => {
      const e = event as unknown as KeyboardEvent;
      interceptKeyPress(e, "Tab", () => { });
      interceptKeyPress(e, "Enter", updatePreview);
    });
  }
}

function interceptKeyPress(event: KeyboardEvent, key: string, fn: () => void) {
  if (event.key === key) {
    event.preventDefault();
    event.stopPropagation();
  }

  fn();
}

function updatePreview() {
  const document = editor?.value;
}

function _safeJSONParse(text: string): Record<string, unknown> {
  return { hey: "" };
}

function toMarkUp(doc: Record<string, unknown>) { }
