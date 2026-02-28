/* ============================================================
   CINEMAX - API MODULE
   Backend: http://localhost:8888
   Auth: Laravel Fortify + Sanctum (cookie/session alapú)
   Minden API hívás előtt CSRF token szükséges (sanctum/csrf-cookie)
============================================================ */
const API_BASE = 'http://localhost:8888';

// CSRF token lekérés (Sanctum SPA auth-hoz szükséges)
async function apiCsrf() {
    await fetch(`${API_BASE}/sanctum/csrf-cookie`, {
        credentials: 'include',
    });
}

// Általános fetch helper
async function apiFetch(path, options = {}) {
    const defaultOptions = {
        credentials: 'include',
        headers: {
            'Accept': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            ...(options.headers || {}),
        },
    };

    // XSRF-TOKEN cookie kiolvasása és fejléchez adása
    const xsrfToken = getCookieValue('XSRF-TOKEN');
    if (xsrfToken) {
        defaultOptions.headers['X-XSRF-TOKEN'] = decodeURIComponent(xsrfToken);
    }

    const mergedOptions = { ...defaultOptions, ...options, headers: defaultOptions.headers };
    const response = await fetch(`${API_BASE}${path}`, mergedOptions);
    return response;
}

function getCookieValue(name) {
    const match = document.cookie.match(new RegExp('(^|;\\s*)' + name + '=([^;]*)'));
    return match ? match[2] : null;
}

// FormData POST
async function apiPost(path, data) {
    await apiCsrf();
    const formData = new FormData();
    for (const [key, value] of Object.entries(data)) {
        if (Array.isArray(value)) {
            value.forEach((item, i) => {
                if (typeof item === 'object') {
                    for (const [k, v] of Object.entries(item)) {
                        formData.append(`${key}[${i}][${k}]`, v);
                    }
                } else {
                    formData.append(`${key}[${i}]`, item);
                }
            });
        } else {
            formData.append(key, value);
        }
    }
    return apiFetch(path, { method: 'POST', body: formData });
}

// JSON POST
async function apiPostJson(path, data) {
    await apiCsrf();
    return apiFetch(path, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(data),
    });
}

// GET
async function apiGet(path) {
    return apiFetch(path, { method: 'GET' });
}

/* ============================================================
   AUTH
============================================================ */

async function apiRegister(name, email, password, passwordConfirmation) {
    await apiCsrf();
    const res = await apiPost('/register', {
        name,
        email,
        password,
        password_confirmation: passwordConfirmation,
    });
    return res;
}

async function apiLogin(email, password) {
    await apiCsrf();
    const res = await apiPost('/login', { email, password });
    return res;
}

async function apiLogout() {
    await apiCsrf();
    const res = await apiFetch('/logout', { method: 'POST' });
    return res;
}

async function apiGetCurrentUser() {
    const res = await apiGet('/api/user');
    if (res.ok) return res.json();
    return null;
}

/* ============================================================
   MOVIES
============================================================ */

async function apiGetMovies() {
    const res = await apiGet('/api/movies');
    if (res.ok) return res.json();
    throw new Error('Nem sikerült betölteni a filmeket.');
}

async function apiGetMovie(movieId) {
    const res = await apiGet(`/api/movies/${movieId}`);
    if (res.ok) return res.json();
    throw new Error('Nem sikerült betölteni a film adatait.');
}

/* ============================================================
   TICKET ORDERS
============================================================ */

async function apiGetTicketOrders() {
    const res = await apiGet('/api/ticket_orders');
    if (res.ok) return res.json();
    throw new Error('Nem sikerült betölteni a foglalásokat.');
}

async function apiCreateTicketOrder(screeningId, seats) {
    // seats: [{seat_id, price_id}, ...]
    await apiCsrf();
    const formData = new FormData();
    formData.append('screening_id', screeningId);
    seats.forEach((seat, i) => {
        formData.append(`seats[${i}][seat_id]`, seat.seat_id);
        formData.append(`seats[${i}][price_id]`, seat.price_id);
    });
    const xsrfToken = getCookieValue('XSRF-TOKEN');
    const headers = {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
    };
    if (xsrfToken) headers['X-XSRF-TOKEN'] = decodeURIComponent(xsrfToken);

    return fetch(`${API_BASE}/api/ticket_orders`, {
        method: 'POST',
        credentials: 'include',
        headers,
        body: formData,
    });
}

async function apiGetProfileTicketOrders() {
    const res = await apiGet('/api/profile/ticket_orders');
    if (res.ok) return res.json();
    throw new Error('Nem sikerült betölteni a saját foglalásokat.');
}

/* ============================================================
   ADMIN
============================================================ */

async function apiAdminGetUsers() {
    const res = await apiGet('/api/admin/users');
    if (res.ok) return res.json();
    throw new Error('Nincs jogosultság.');
}

async function apiAdminGetFilms() {
    const res = await apiGet('/api/admin/films');
    if (res.ok) return res.json();
    throw new Error('Nincs jogosultság.');
}

async function apiAdminGetScreenings() {
    const res = await apiGet('/api/admin/screenings');
    if (res.ok) return res.json();
    throw new Error('Nincs jogosultság.');
}

async function apiAdminCreateFilm(data) {
    await apiCsrf();
    return apiPost('/api/admin/films', data);
}

async function apiAdminCreateScreening(data) {
    await apiCsrf();
    return apiPost('/api/admin/screenings', data);
}
