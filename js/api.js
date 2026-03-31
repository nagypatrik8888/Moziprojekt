// =============================================================
// CINEMAX – API RÉTEG
// Alap URL: a Laravel backend portja (fejlesztéskor localhost:8888)
// =============================================================

const API_BASE = 'http://localhost:8888';

// --- Segéd ---
async function apiFetch(path, options = {}) {
    const url = `${API_BASE}${path}`;
    const defaults = {
        headers: { 'Accept': 'application/json' },
        credentials: 'include',   // session cookie (Sanctum)
    };
    const res = await fetch(url, { ...defaults, ...options, headers: { ...defaults.headers, ...(options.headers || {}) } });
    if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw Object.assign(new Error(err.message || `HTTP ${res.status}`), { status: res.status, data: err });
    }
    return res.json();
}

// =============================================================
// FILMEK
// =============================================================

/**
 * GET /api/movies
 * Válasz: { movies: [...], genres: [...] }
 */
async function apiGetMovies() {
    return apiFetch('/api/movies');
}

/**
 * GET /api/movies/{movie_id}
 * Válasz: { movie: { ...film, screenings: [...] }, prices: [...] }
 */
async function apiGetMovie(movieId) {
    return apiFetch(`/api/movies/${movieId}`);
}

// =============================================================
// JEGYVÁSÁRLÁS
// =============================================================

/**
 * POST /api/ticket_orders
 * Body (FormData):
 *   screening_id  – kötelező
 *   seats[0][seat_id]   – ülőhely id
 *   seats[0][price_id]  – árkategória id
 *   (többi szék: seats[1]..., seats[2]... stb.)
 *
 * Válasz: { ticket_order_id: 13 }
 */
async function apiCreateTicketOrder(screeningId, seats) {
    // seats: [{ seat_id, price_id }, ...]
    const fd = new FormData();
    fd.append('screening_id', screeningId);
    seats.forEach((s, i) => {
        fd.append(`seats[${i}][seat_id]`, s.seat_id);
        fd.append(`seats[${i}][price_id]`, s.price_id);
    });
    return apiFetch('/api/ticket_orders', { method: 'POST', body: fd });
}

/**
 * GET /api/ticket_orders  (admin)
 * Válasz: { ticket_orders: [...] }
 */
async function apiGetAllTicketOrders() {
    return apiFetch('/api/ticket_orders');
}

/**
 * GET /api/profile/ticket_orders  (bejelentkezett user saját foglalásai)
 * Válasz: { ticket_orders: [...] }
 */
async function apiGetProfileTicketOrders() {
    return apiFetch('/api/profile/ticket_orders');
}

// =============================================================
// AUTH (Breeze / Sanctum web routes)
// =============================================================

/**
 * POST /login   – FormData: email, password
 * Siker esetén a szerver session cookie-t állít be.
 */
async function apiLogin(email, password) {
    const fd = new FormData();
    fd.append('email', email);
    fd.append('password', password);
    return apiFetch('/login', { method: 'POST', body: fd });
}

/**
 * POST /register – FormData: name, email, password, password_confirmation
 */
async function apiRegister(name, email, password) {
    const fd = new FormData();
    fd.append('name', name);
    fd.append('email', email);
    fd.append('password', password);
    fd.append('password_confirmation', password);
    return apiFetch('/register', { method: 'POST', body: fd });
}

/**
 * GET /api/user – visszaadja a bejelentkezett usert (Sanctum)
 */
async function apiGetCurrentUser() {
    return apiFetch('/api/user');
}
