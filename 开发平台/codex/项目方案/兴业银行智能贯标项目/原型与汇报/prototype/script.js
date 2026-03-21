const navItems = document.querySelectorAll(".nav-item");
const screens = document.querySelectorAll(".screen");

navItems.forEach((item) => {
  item.addEventListener("click", () => {
    navItems.forEach((button) => button.classList.remove("active"));
    screens.forEach((screen) => screen.classList.remove("active"));
    item.classList.add("active");
    document.getElementById(`screen-${item.dataset.screen}`).classList.add("active");
  });
});
