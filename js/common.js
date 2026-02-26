<<<<<<< HEAD
// =============================================================
// CINEMAX – COMMON.JS
// A filmadatok mostantól az API-ból jönnek (api.js).
// =============================================================

// Globális filmcache – api.js apiGetMovies() tölti fel
let movies = [];
let genres = [];

/**
 * Betölti a filmeket a backendről, eltárolja a globális `movies`-ba,
 * majd meghívja az opcionális callback-et (pl. renderMovies).
 */
async function loadMoviesFromAPI(callback) {
    try {
        const data = await apiGetMovies();
        movies = (data.movies || []).map(m => ({
            id: m.movie_id,
            title: m.title,
            category: m.genre_name,
            duration: `${m.duration} perc`,
            rating: m.rating,
            description: m.description,
            poster: m.poster_url || posterFallback(m.title),
            showtimes: (m.screenings || []).map(s => s.start_time).filter(Boolean),
            _raw: m,
        }));
        genres = (data.genres || []).map(g => g.genre_name);
    } catch (err) {
        console.error('Filmek betöltése sikertelen:', err);
        movies = [];
        genres = [];
    }
    if (typeof callback === 'function') callback();
}

/**
 * Egy film részletes adatai (screenings + prices).
 * Visszaad: { movie, prices } vagy null hiba esetén.
 */
async function loadMovieDetailFromAPI(movieId) {
    try {
        const data = await apiGetMovie(movieId);
        const idx = movies.findIndex(m => m.id == movieId);
        if (idx !== -1 && data.movie) {
            movies[idx].showtimes    = (data.movie.screenings || []).map(s => s.start_time).filter(Boolean);
            movies[idx]._screenings  = data.movie.screenings || [];
        }
        return data;
    } catch (err) {
        console.error(`Film ${movieId} betöltése sikertelen:`, err);
        return null;
    }
}

/** TMDB poszter fallback filmcím alapján */
function posterFallback(title) {
    const map = {
        'Avatar (2009)':               'https://image.tmdb.org/t/p/original/6EiRUJpuoeQPghrs3YNktfnqOVh.jpg',
        'Avengers: Endgame':           'https://image.tmdb.org/t/p/original/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg',
        'Star Wars: The Force Awakens':'https://image.tmdb.org/t/p/original/wqnLdwVXoBjKibFRR5U3y0aDUhs.jpg',
        'Jurassic World':              'https://image.tmdb.org/t/p/original/rhr4y79GpxQF9IsfJItRXVaoGs4.jpg',
        'Spider-Man: No Way Home':     'https://image.tmdb.org/t/p/original/rjbNpRMoVvqHmhmksbokcyCr7wn.jpg',
        'Zootopia':                    'https://image.tmdb.org/t/p/original/hlK0e0wAQ3VLuJcsfIYPvb4JVud.jpg',
    };
    return map[title] || '';
}

// =============================================================
// AUTH
// =============================================================

function getCurrentUser() {
    const userStr = localStorage.getItem('currentUser');
    if (userStr) { try { return JSON.parse(userStr); } catch {} }
    const alt = localStorage.getItem('cinemax_user');
    if (alt) { try { return JSON.parse(alt); } catch {} }
    return null;
}

function setCurrentUser(user) {
    if (user) {
        const { password, ...safeUser } = user;
        localStorage.setItem('currentUser', JSON.stringify(safeUser));
        localStorage.setItem('cinemax_user', JSON.stringify(safeUser));
    } else {
        localStorage.removeItem('currentUser');
        localStorage.removeItem('cinemax_user');
    }
}

// =============================================================
// KEDVENCEK
// =============================================================

function getFavorites() {
    const favStr = localStorage.getItem('favorites');
    return favStr ? JSON.parse(favStr) : [];
}

function setFavorites(favorites) {
    localStorage.setItem('favorites', JSON.stringify(favorites));
}

// =============================================================
// FOGLALÁSOK – localStorage cache
// =============================================================

function getUserBookings() {
    const bookingsStr = localStorage.getItem('userBookings');
    return bookingsStr ? JSON.parse(bookingsStr) : [];
}

function setUserBookings(bookings) {
    localStorage.setItem('userBookings', JSON.stringify(bookings));
}

// =============================================================
// FOGLALT SZÉKEK – localStorage cache
// =============================================================

function getOccupiedSeats() {
    const seatsStr = localStorage.getItem('occupiedSeats');
    return seatsStr ? JSON.parse(seatsStr) : {};
}

function setOccupiedSeats(seats) {
    localStorage.setItem('occupiedSeats', JSON.stringify(seats));
}

// =============================================================
// UI
// =============================================================

function showToast(message, isError = false) {
    const toast = document.getElementById('liveToast');
    if (!toast) return;
    const toastEl = new bootstrap.Toast(toast);
    const toastMessage = document.getElementById('toastMessage');
    if (toastMessage) toastMessage.textContent = message;
    if (isError) toast.classList.add('error');
    else toast.classList.remove('error');
    toastEl.show();
}

function updateUserInterface() {
    const loginBtn    = document.getElementById('loginBtn');
    const userBtn     = document.getElementById('userBtn');
    const bookingsNav = document.getElementById('bookingsNav');
    const currentUser = getCurrentUser();

    if (loginBtn && userBtn) {
        if (currentUser) {
            loginBtn.style.display = 'none';
            userBtn.style.display  = 'inline-block';
            const userName = document.getElementById('userName');
            if (userName) {
                const n = (currentUser.name || currentUser.username || currentUser.email || '').trim();
                userName.textContent = n ? n.split(' ')[0] : '';
            }
        } else {
            loginBtn.style.display = 'inline-block';
            userBtn.style.display  = 'none';
=======
const API_BASE = "http://localhost:8888";

async function apiRequest(endpoint, method = "GET", body = null) {
    const token = localStorage.getItem("authToken");

    const options = {
        method,
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + token
>>>>>>> 0b09bc06e12b1a018eb3d13f505bf715c2196617
        }
    };

    if (body) {
        options.body = body;
    }
<<<<<<< HEAD
    if (bookingsNav) bookingsNav.style.display = currentUser ? 'list-item' : 'none';
}

function logout() {
    setCurrentUser(null);
    try {
        ['cinemax_token','authToken','token','access_token','loggedInUser']
            .forEach(k => localStorage.removeItem(k));
    } catch {}
    updateUserInterface();
    try { localStorage.setItem('cmx_logout_broadcast', String(Date.now())); } catch {}
    showToast('Sikeresen kijelentkeztél!');
    setTimeout(() => { window.location.href = 'index.html'; }, 400);
}

document.addEventListener('DOMContentLoaded', () => updateUserInterface());
window.addEventListener('pageshow', () => updateUserInterface());
document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') updateUserInterface();
});
window.addEventListener('storage', (e) => {
    if (['currentUser','cmx_logout_broadcast','cinemax_user'].includes(e.key)) updateUserInterface();
});
=======

    const response = await fetch(API_BASE + endpoint, options);

    if (response.status === 401) {
        localStorage.removeItem("authToken");
        window.location.href = "login.html";
        return;
    }

    if (!response.ok) {
        throw new Error("API error");
    }

    return response.json();
}

function logout() {
    localStorage.removeItem("authToken");
    window.location.href = "login.html";
}
>>>>>>> 0b09bc06e12b1a018eb3d13f505bf715c2196617
