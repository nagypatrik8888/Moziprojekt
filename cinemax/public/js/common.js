/* ============================================================
   CINEMAX - COMMON.JS
   Közös segédfüggvények. A filmeket a backend API-ból töltjük be.
============================================================ */

// Globális movies cache (API-ból töltve)
window.moviesCache = [];

// ===================== USER AUTH (localStorage session) =====================

function getCurrentUser() {
    const raw = localStorage.getItem('cinemax_user');
    if (!raw) return null;
    try { return JSON.parse(raw); } catch { return null; }
}

function setCurrentUser(user) {
    if (user) {
        const { password, ...safeUser } = user;
        localStorage.setItem('cinemax_user', JSON.stringify(safeUser));
    } else {
        localStorage.removeItem('cinemax_user');
    }
}

function getFavorites() {
    const raw = localStorage.getItem('cinemax_favorites');
    return raw ? JSON.parse(raw) : [];
}

function setFavorites(favorites) {
    localStorage.setItem('cinemax_favorites', JSON.stringify(favorites));
}

function getUserBookings() {
    const raw = localStorage.getItem('cinemax_bookings');
    return raw ? JSON.parse(raw) : [];
}

function setUserBookings(bookings) {
    localStorage.setItem('cinemax_bookings', JSON.stringify(bookings));
}

function getOccupiedSeats() {
    const raw = localStorage.getItem('cinemax_occupied');
    return raw ? JSON.parse(raw) : {};
}

function setOccupiedSeats(seats) {
    localStorage.setItem('cinemax_occupied', JSON.stringify(seats));
}

// ===================== NAVBAR / UI =====================

function updateUserInterface() {
    const user = getCurrentUser();

    const loginBtn = document.getElementById('loginBtn');
    const userBtn = document.getElementById('userBtn');
    if (loginBtn && userBtn) {
        if (user) {
            loginBtn.style.display = 'none';
            userBtn.style.display = 'inline-block';
            const userNameEl = document.getElementById('userName');
            if (userNameEl) {
                const n = (user.name || user.email || '').trim();
                userNameEl.textContent = n ? n.split(' ')[0] : '';
            }
        } else {
            loginBtn.style.display = 'inline-block';
            userBtn.style.display = 'none';
        }
    }

    // navUsername (auth.js stílusú navbar)
    const nameEl = document.getElementById('navUsername');
    const linkEl = document.getElementById('navUserLink');
    if (nameEl) {
        nameEl.textContent = user
            ? ((user.name || user.email || 'PROFIL').toUpperCase())
            : 'BEJELENTKEZÉS';
    }
    if (linkEl) {
        linkEl.href = user ? 'profile.html' : 'login.html';
    }

    // Admin menüpont
    const adminItem = document.getElementById('navAdminItem');
    if (adminItem) {
        adminItem.style.display = (user && user.is_admin) ? '' : 'none';
    }

    // Logout gombok
    document.querySelectorAll('[data-cmx-logout]').forEach(btn => {
        btn.style.display = user ? '' : 'none';
    });

    // Foglalások menü
    const bookingsNav = document.getElementById('bookingsNav');
    if (bookingsNav) {
        bookingsNav.style.display = user ? 'list-item' : 'none';
    }
}

// ===================== LOGOUT =====================

async function logout() {
    try {
        if (typeof apiLogout === 'function') await apiLogout();
    } catch {}

    setCurrentUser(null);
    try {
        localStorage.removeItem('cinemax_token');
        localStorage.removeItem('cinemax_bookings');
        localStorage.removeItem('cinemax_favorites');
    } catch {}

    updateUserInterface();
    showToast('Sikeresen kijelentkeztél!');
    setTimeout(() => window.location.href = '/', 400);
}

// ===================== TOAST =====================

function showToast(message, isError = false) {
    const toast = document.getElementById('liveToast');
    if (!toast) return;

    const toastEl = new bootstrap.Toast(toast);
    const toastMessage = document.getElementById('toastMessage');
    if (toastMessage) toastMessage.textContent = message;

    if (isError) {
        toast.classList.add('error');
    } else {
        toast.classList.remove('error');
    }

    toastEl.show();
}

// ===================== INIT =====================

document.addEventListener('DOMContentLoaded', () => {
    updateUserInterface();
    document.querySelectorAll('[data-cmx-logout]').forEach(btn => {
        btn.addEventListener('click', e => { e.preventDefault(); logout(); });
    });
    const legacyLogoutBtn = document.getElementById('logoutBtn');
    if (legacyLogoutBtn) {
        legacyLogoutBtn.addEventListener('click', e => { e.preventDefault(); logout(); });
    }
});

window.addEventListener('pageshow', updateUserInterface);
document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') updateUserInterface();
});
window.addEventListener('storage', e => {
    if (e.key === 'cinemax_user') updateUserInterface();
});
