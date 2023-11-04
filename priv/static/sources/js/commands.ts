export function toggleSidebar() {
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
