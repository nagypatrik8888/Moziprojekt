/* =========================================================
   CINEMAX - AUTH + NAV (HARD FIX)
   - navbar mindig frissül: load + pageshow(BFCache) + visibility
   - logout: minden kulcs törlés + cross-tab broadcast
========================================================= */

const CMX_KEYS_TO_CLEAR = [
  "cinemax_user",
  "cinemax_token",
  "cinemax_bookings",
  "cinemax_favorites",

  // régi / gyakori
  "token",
  "access_token",
  "authToken",
  "currentUser",
  "user",
  "loggedInUser",
  "username",
  "email",
  "cinemax_username",
  "cinemax_email",
];

const CMX_BROADCAST_KEY = "cmx_logout_broadcast";

function cmxSafeParse(key) {
  const raw = localStorage.getItem(key);
  if (!raw) return null;
  try { return JSON.parse(raw); } catch { return null; }
}

function cmxGetUser() {
  const u = cmxSafeParse("cinemax_user");
  if (u && (u.username || u.name || u.email)) return u;
  return null;
}

function cmxDisplayName(user) {
  if (!user) return "";
  return (user.username || user.name || user.email || "").trim();
}

function cmxSetNavbar() {
  const user = cmxGetUser();
  const nameEl = document.getElementById("navUsername");
  const linkEl = document.getElementById("navUserLink");

  if (nameEl) {
    nameEl.textContent = user
      ? (cmxDisplayName(user).toUpperCase() || "PROFIL")
      : "BEJELENTKEZÉS";
  }

  if (linkEl) {
    linkEl.href = user ? "profile" : "login";
  }

  
  // Admin menüpont (ha van a navbarban). Egyetlen forrás: backend `is_admin` flag.
  const adminItem = document.getElementById("navAdminItem");
  if (adminItem) {
    const isAdmin = !!(user && user.is_admin === true);
    adminItem.style.display = isAdmin ? "" : "none";
  }

  // Logout gombok elrejtése, ha nincs user
  document.querySelectorAll("[data-cmx-logout]").forEach(btn => {
    btn.style.display = user ? "" : "none";
  });
}

function cmxRequireAuth() {
  const user = cmxGetUser();
  if (!user) {
    window.location.href = "login";
    return false;
  }
  return true;
}

function cmxLogout(redirectTo = "login") {
  CMX_KEYS_TO_CLEAR.forEach(k => localStorage.removeItem(k));

  try {
    sessionStorage.removeItem("cinemax_user");
    sessionStorage.removeItem("cinemax_token");
    sessionStorage.removeItem("token");
  } catch {}

  localStorage.setItem(CMX_BROADCAST_KEY, String(Date.now()));
  cmxSetNavbar();
  window.location.href = redirectTo;
}

function cmxBindLogoutButtons() {
  document.querySelectorAll("[data-cmx-logout]").forEach(btn => {
    btn.addEventListener("click", (e) => {
      e.preventDefault();
      cmxLogout("login");
    });
  });
}

document.addEventListener("DOMContentLoaded", () => {
  cmxSetNavbar();
  cmxBindLogoutButtons();
});

window.addEventListener("pageshow", () => {
  cmxSetNavbar();
});

document.addEventListener("visibilitychange", () => {
  if (document.visibilityState === "visible") cmxSetNavbar();
});

window.addEventListener("storage", (e) => {
  if (e.key === CMX_BROADCAST_KEY) cmxSetNavbar();
  if (CMX_KEYS_TO_CLEAR.includes(e.key)) cmxSetNavbar();
});
