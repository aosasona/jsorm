export function toggleSidebar() {
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
    }
    else {
        sidebar === null || sidebar === void 0 ? void 0 : sidebar.classList.remove("sidebar-closed");
        sidebar === null || sidebar === void 0 ? void 0 : sidebar.classList.add("sidebar-opened");
        sidebar === null || sidebar === void 0 ? void 0 : sidebar.setAttribute("data-status", "open");
        sidebarToggleIcon === null || sidebarToggleIcon === void 0 ? void 0 : sidebarToggleIcon.classList.remove("ti-layout-sidebar-left-expand");
        sidebarToggleIcon === null || sidebarToggleIcon === void 0 ? void 0 : sidebarToggleIcon.classList.add("ti-layout-sidebar-right-expand");
    }
}
