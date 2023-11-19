export const Ctrl = "Ctrl";
export const Meta = "Meta";
export const Alt = "Alt";
export const Shift = "Shift";

type LeaderKey = typeof Ctrl | typeof Meta | typeof Alt | typeof Shift;
export type HotKey = [LeaderKey, string];

type KeyInterceptDefinition = { key: string; fn: (e: KeyboardEvent) => void };
type HotKeyDefinition = { keys: HotKey; description: string | null; fn: () => void };

const palette = document.getElementById("command-palette") as HTMLDivElement;

const keyIntercepts: KeyInterceptDefinition[] = [];
export function registerIntercept(key: string, fn: (e: KeyboardEvent) => void) {
	keyIntercepts.push({ key, fn });
}

const hotKeys: HotKeyDefinition[] = [];
export function registerCombination(keys: HotKey[], description: string | null, fn: () => void) {
	for (const key of keys) {
		if (key.length !== 2) {
			throw new Error("An hot key mapping must be an array of length 2");
		}

		hotKeys.push({ keys: key, description, fn });
	}
}

// All keypresses and hotkeys need to be registered before calling init()
export function init() {
	document.addEventListener("keydown", (event) => {
		for (const { key, fn } of keyIntercepts) {
			interceptKeyPress(event, key, fn);
		}
	});

	document.addEventListener("keydown", (event) => {
		for (const hotKey of hotKeys) {
			handleHotKey(event, hotKey);
		}
	});
}

export function destroy() {
	document.removeEventListener("keydown", (event) => {
		for (const { key, fn } of keyIntercepts) {
			interceptKeyPress(event, key, fn);
		}
	});

	document.removeEventListener("keydown", (event) => {
		for (const hotKey of hotKeys) {
			handleHotKey(event, hotKey);
		}
	});
}

function interceptKeyPress(event: KeyboardEvent, key: string, fn: (e: KeyboardEvent) => void) {
	if (event.key === key) {
		fn(event);
	}
}

function handleHotKey(event: KeyboardEvent, hotKey: HotKeyDefinition) {
	const [leader, secondaryKey] = hotKey.keys;
	if (isModifierKey(event.key)) return;
	if (event.key === secondaryKey && event[getModifierKey(leader)]) {
		event.preventDefault();
		event.stopPropagation();
		hotKey.fn();
	}
}

function getModifierKey(key: LeaderKey) {
	switch (key) {
		case Ctrl:
			return "ctrlKey";
		case Alt:
			return "altKey";
		case Meta:
			return "metaKey";
		case Shift:
			return "shiftKey";
	}
}

function isModifierKey(key: string) {
	return key === Ctrl || key === Alt || key === Meta || key === Shift;
}

export function handleTab(e: KeyboardEvent, editor: HTMLTextAreaElement | null): void {
	if (document.activeElement == editor) {
		e.preventDefault();
		e.stopPropagation();

		const start = editor?.selectionStart;
		const end = editor?.selectionEnd;
		if (start && end && editor) {
			editor.value = editor.value.substring(0, start) + "\t" + editor.value.substring(end);
			editor.selectionStart = editor.selectionEnd = start + 1;
		}
	} else if (palette && !palette.classList.contains("hidden")) {
		e.preventDefault();
		e.stopPropagation();
		const items = palette.getElementsByTagName("button");
		// if a button is focused, go back to the input or vice versa
		if (items.length > 0) {
			const active = document.activeElement as HTMLButtonElement;
			if (active && active.tagName === "BUTTON") {
				palette.getElementsByTagName("input")[0].focus();
			} else {
				items[0].focus();
			}
		}
	}
}

export function navigatePalette(e: KeyboardEvent, direction: "up" | "down") {
	if (!palette || palette.classList.contains("hidden")) return;
	e.preventDefault();
	e.stopPropagation();

	const items = palette.getElementsByTagName("button");
	if (items.length === 0) return;

	const arrItems = Array.from(items);
	const selectedIndex = arrItems.indexOf(document.activeElement as HTMLButtonElement);

	if (selectedIndex === -1) {
		items.item(0)?.focus();
		return;
	}

	let nextIndex = direction === "up" ? selectedIndex - 1 : selectedIndex + 1;
	if ((selectedIndex == 0 && direction == "up") || (nextIndex == items.length && direction == "down")) {
		return;
	}

	arrItems[nextIndex].focus();
}

export function handlePaletteNavigation() { }
