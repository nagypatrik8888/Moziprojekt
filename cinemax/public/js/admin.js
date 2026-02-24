function safeParse(key, fallback) {
  const raw = localStorage.getItem(key);
  if (!raw) return fallback;
  try { return JSON.parse(raw); } catch { return fallback; }
}
function save(key, value) {
  localStorage.setItem(key, JSON.stringify(value));
}

function isAdminUser(user) {
  if (!user) return false;
  if (user.isAdmin === true) return true;
  const email = String(user.email || "").toLowerCase().trim();
  return email === "admin@cinema.hu" || email === "admin@cinemax.hu";
}

function fmtWhen(iso) {
  try {
    const d = new Date(iso);
    if (isNaN(d.getTime())) return String(iso || "");
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, "0");
    const dd = String(d.getDate()).padStart(2, "0");
    const hh = String(d.getHours()).padStart(2, "0");
    const mi = String(d.getMinutes()).padStart(2, "0");
    return `${yyyy}-${mm}-${dd} ${hh}:${mi}`;
  } catch {
    return String(iso || "");
  }
}

function loadMovies() {
  // movies: common.js globális
  const local = safeParse("cinemax_movies", null);
  if (Array.isArray(local)) return local;
  if (Array.isArray(window.movies)) return window.movies;
  return [];
}

function saveMovies(ms) {
  save("cinemax_movies", ms);
}

function loadBookings() {
  return safeParse("cinemax_bookings", []);
}

function loadUsers() {
  return safeParse("users", []);
}

function calcTicketCount(bookings) {
  let n = 0;
  for (const b of bookings) {
    const seats = Array.isArray(b.seats) ? b.seats : [];
    n += Math.max(1, seats.length);
  }
  return n;
}

function setStats() {
  const users = loadUsers();
  const bookings = loadBookings();
  const ms = loadMovies();

  document.getElementById("statUsers").textContent = String(users.length);
  document.getElementById("statBookings").textContent = String(bookings.length);
  document.getElementById("statTickets").textContent = String(calcTicketCount(bookings));
  document.getElementById("statMovies").textContent = String(ms.length);
}

function renderMovies() {
  const ms = loadMovies();
  const tbody = document.getElementById("moviesTable");
  tbody.innerHTML = "";

  ms.forEach(m => {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${m.id ?? ""}</td>
      <td class="fw-semibold">${m.title ?? ""}</td>
      <td>${m.category ?? m.genre ?? ""}</td>
      <td>⭐ ${m.rating ?? ""}</td>
      <td>
        <button class="btn btn-sm btn-danger" data-del-movie="${m.id}"><i class="bi bi-trash3"></i></button>
      </td>
    `;
    tbody.appendChild(tr);
  });

  tbody.querySelectorAll("[data-del-movie]").forEach(btn => {
    btn.addEventListener("click", () => {
      const id = btn.getAttribute("data-del-movie");
      const next = loadMovies().filter(x => String(x.id) !== String(id));
      saveMovies(next);
      renderMovies();
      setStats();
    });
  });
}

function renderBookings() {
  const q = String(document.getElementById("q").value || "").toLowerCase().trim();
  const bookings = loadBookings();
  const tbody = document.getElementById("bookingsTable");
  tbody.innerHTML = "";

  const rows = bookings.filter(b => {
    if (!q) return true;
    const title = String(b.title || "").toLowerCase();
    const email = String(b.userEmail || b.email || "").toLowerCase();
    const seats = (Array.isArray(b.seats) ? b.seats.join(",") : "").toLowerCase();
    return title.includes(q) || email.includes(q) || seats.includes(q);
  });

  rows.forEach(b => {
    const seats = Array.isArray(b.seats) ? b.seats.join(", ") : "—";
    const email = b.userEmail || b.email || "—";
    const when = fmtWhen(b.whenISO || b.when);

    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${when}</td>
      <td class="fw-semibold">${b.title || ""}</td>
      <td><span class="badge text-bg-warning text-dark">${seats}</span></td>
      <td>${email}</td>
      <td>
        <button class="btn btn-sm btn-danger" data-del-booking="${b.id}"><i class="bi bi-trash3"></i></button>
      </td>
    `;
    tbody.appendChild(tr);
  });

  tbody.querySelectorAll("[data-del-booking]").forEach(btn => {
    btn.addEventListener("click", () => {
      const id = btn.getAttribute("data-del-booking");
      const next = loadBookings().filter(x => String(x.id) !== String(id));
      save("cinemax_bookings", next);
      renderBookings();
      setStats();
    });
  });
}

function addMoviePrompt() {
  const title = prompt("Film címe:");
  if (!title) return;

  const category = prompt("Kategória (pl. Akció):", "Akció") || "";
  const ratingStr = prompt("Értékelés (pl. 8.2):", "8.0") || "";
  const rating = Number(ratingStr);

  const ms = loadMovies();
  const maxId = ms.reduce((a, x) => Math.max(a, Number(x.id) || 0), 0);
  const movie = {
    id: maxId + 1,
    title,
    category,
    rating: Number.isFinite(rating) ? rating : 0,
    poster: ""
  };
  ms.push(movie);
  saveMovies(ms);
  renderMovies();
  setStats();
}

function resetDemoData() {
  // Demo: visszaállítjuk a common.js movies listát a localStorage-be
  if (Array.isArray(window.movies)) {
    saveMovies(window.movies);
  }
  setStats();
  renderMovies();
  renderBookings();
}

function wipeAll() {
  if (!confirm("Biztos törlöd az összes localStorage adatot?")) return;
  localStorage.clear();
  // auth.js úgyis beállítja a navot, de biztos ami biztos:
  window.location.href = "login";
}

function initAdmin() {
  // auth
  if (!window.cmxRequireAuth || !cmxRequireAuth()) return;

  const user = safeParse("cinemax_user", null);
  const ok = isAdminUser(user);

  // admin link a navban
  const navAdminItem = document.getElementById("navAdminItem");
  if (navAdminItem) navAdminItem.style.display = ok ? "" : "none";

  if (!ok) {
    document.getElementById("adminSub").textContent = "Nincs admin jogosultság.";
    document.getElementById("noAccess").style.display = "block";
    document.getElementById("adminWrap").style.display = "none";
    return;
  }

  document.getElementById("adminSub").textContent = `Bejelentkezve: ${(user.email || user.name || user.username || "").toString()}`;
  document.getElementById("noAccess").style.display = "none";
  document.getElementById("adminWrap").style.display = "block";

  // hook buttons
  document.getElementById("btnAddMovie").addEventListener("click", addMoviePrompt);
  document.getElementById("btnRefresh").addEventListener("click", () => { setStats(); renderBookings(); });
  document.getElementById("q").addEventListener("input", renderBookings);
  document.getElementById("btnResetDemo").addEventListener("click", resetDemoData);
  document.getElementById("btnWipeAll").addEventListener("click", wipeAll);

  // initial
  if (!safeParse("cinemax_movies", null)) resetDemoData();
  setStats();
  renderMovies();
  renderBookings();
}

document.addEventListener("DOMContentLoaded", initAdmin);
