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
const toastHTML = `
<div class="fixed right-6 bottom-6 p-3 rounded-md" id="toast-container">
  <div class="toast" id="toast">
    <div class="toast-header">
      <h4 id="toast-header"></h4>
    </div>
    <div class="toast-body">
      <p id="toast-body"></p>
    </div>
  </div>
</div>
`;
export function init() {
    var _a;
    const toastContainer = document.createElement("div");
    toastContainer.innerHTML = toastHTML;
    (_a = document.querySelector("body")) === null || _a === void 0 ? void 0 : _a.appendChild(toastContainer);
}
