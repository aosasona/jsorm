function durationToSeconds(duration) {
    if (duration.endsWith("ms")) {
        return parseInt(duration.slice(0, -2));
    }
    else if (duration.endsWith("s")) {
        return parseInt(duration.slice(0, -1)) * 1000;
    }
    else if (duration.endsWith("m")) {
        return parseInt(duration.slice(0, -1)) * 1000 * 60;
    }
    return 0;
}
function getClass(type) {
    switch (type) {
        case "error":
            return "bg-red-500 text-white";
        case "warning":
            return "bg-yellow-500 text-black";
        case "success":
            return "bg-green-500 text-white";
    }
}
export function init() {
    var _a;
    const toastContainer = document.createElement("div");
    toastContainer.className = "flex fixed right-6 bottom-6 flex-col items-end z-[9999]";
    toastContainer.id = "toast-container";
    (_a = document.querySelector("body")) === null || _a === void 0 ? void 0 : _a.appendChild(toastContainer);
}
function makeToastID() {
    return Math.random().toString(36).substring(7);
}
function makeToast(id, type, body) {
    const toast = document.createElement("div");
    const classes = getClass(type);
    toast.className = `select-none hover:opacity-80 cursor-pointer py-3 px-4 mb-3 w-max rounded-md shadow-lg transition-all duration-200 min-w-[100px] max-w-[300px] slide-up ${classes}`;
    toast.id = id;
    toast.innerHTML = `
    <p class="text-xs" id="toast-body">${body}</p>
  `;
    toast.addEventListener("click", () => {
        dismissToast(toast);
    });
    return toast;
}
function dismissToast(toast) {
    if (!toast) {
        return;
    }
    toast.classList.add("slide-down");
    setTimeout(() => {
        toast.remove();
    }, 200);
}
function show(body, type, duration = "3s") {
    const toastContainer = document.querySelector("#toast-container");
    if (!toastContainer) {
        return;
    }
    const toastID = makeToastID();
    const toast = makeToast(toastID, type, body);
    const appendedToast = toastContainer.appendChild(toast);
    setTimeout(() => {
        dismissToast(appendedToast);
    }, durationToSeconds(duration) + 190);
}
export function error(body, duration = "4s") {
    show(body, "error", duration);
}
export function warning(body, duration = "4s") {
    show(body, "warning", duration);
}
export function success(body, duration = "4s") {
    show(body, "success", duration);
}
