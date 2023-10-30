import * as toast from "./toast.js";

let editor: HTMLTextAreaElement | null = null;
window.onload = run;

function run() {
  toast.init();
  editor = document.querySelector("#editor");

  if (editor) {
    editor.addEventListener("keydown", (event) => {
      const e = event as unknown as KeyboardEvent;
      interceptKeyPress(e, "Tab", () => { });
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
  try {
    return JSON.parse(text);
  } catch (e) {
    toast.error("Invalid JSON", "3s");
    return {};
  }
}

function toMarkUp(doc: Record<string, unknown>) {
  let result = "";
  for (const field in doc) {
  }

  return result;
}
