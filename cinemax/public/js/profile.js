/* ============================================================
   CINEMAX - PROFILE.JS
   Profil oldal - saját foglalások betöltése API-ból
============================================================ */

async function initProfile() {
    const user = getCurrentUser();
    if (!user) {
        window.location.href = 'login';
        return;
    }

    // Alapadatok megjelenítése
    const name = (user.name || user.email || '').trim();
    const email = (user.email || '').trim();

    const usernameEl = document.getElementById('username');
    const emailEl = document.getElementById('email');
    if (usernameEl) usernameEl.textContent = name;
    if (emailEl) emailEl.textContent = email;

    const badge = document.getElementById('badge');
    if (badge) badge.textContent = 'SILVER';

    if (typeof updateUserInterface === 'function') updateUserInterface();

    // Foglalások betöltése API-ból
    await loadProfileTicketOrders();
}

async function loadProfileTicketOrders() {
    const bookingCountEl = document.getElementById('bookingCount');
    const sumBookingsEl = document.getElementById('sumBookings');
    const sumNextEl = document.getElementById('sumNext');
    const pointsEl = document.getElementById('points');
    const favCountEl = document.getElementById('favCount');

    const favs = getFavorites();
    if (favCountEl) favCountEl.textContent = String(favs.length);

    try {
        const data = await apiGetProfileTicketOrders();
        const orders = data.ticket_orders || [];

        if (bookingCountEl) bookingCountEl.textContent = String(orders.length);
        if (sumBookingsEl) sumBookingsEl.textContent = String(orders.length);

        // Következő vetítés
        if (sumNextEl) {
            const now = new Date();
            const future = orders.filter(o => {
                if (!o.screening_date) return false;
                const d = new Date(`${o.screening_date}T${o.screening_time || '00:00'}:00`);
                return d > now;
            }).sort((a, b) =>
                new Date(`${a.screening_date}T${a.screening_time || '00:00'}`) -
                new Date(`${b.screening_date}T${b.screening_time || '00:00'}`)
            );

            if (future.length > 0) {
                const next = future[0];
                sumNextEl.textContent = `${next.screening_date} ${next.screening_time || ''} (${next.movie_name || ''})`;
            } else {
                sumNextEl.textContent = 'Nincs';
            }
        }

        // Pontszám (ha a backend ad, különben lokális)
        const user = getCurrentUser();
        if (pointsEl) pointsEl.textContent = String(user?.points || 0);

        // Foglalások listázása ha van ilyen elem
        renderProfileOrders(orders);

    } catch (err) {
        console.error('Profil foglalások betöltési hiba:', err);
        if (bookingCountEl) bookingCountEl.textContent = '0';
        if (sumBookingsEl) sumBookingsEl.textContent = '0';
        if (sumNextEl) sumNextEl.textContent = 'Nincs';

        const user = getCurrentUser();
        if (pointsEl) pointsEl.textContent = String(user?.points || 0);
    }
}

function renderProfileOrders(orders) {
    const container = document.getElementById('profileOrdersList');
    if (!container) return;

    if (!orders.length) {
        container.innerHTML = '<p class="text-muted">Még nincs foglalásod.</p>';
        return;
    }

    container.innerHTML = orders.map(o => `
        <div class="card mb-2 bg-dark border-secondary">
            <div class="card-body py-2 px-3">
                <div class="d-flex justify-content-between align-items-center">
                    <div>
                        <span class="fw-bold">${o.movie_name || 'Ismeretlen film'}</span>
                        <span class="text-muted small ms-2">${o.movie_genre || ''} • ${o.movie_duration ? o.movie_duration + ' perc' : ''}</span>
                    </div>
                    <span class="badge bg-warning text-dark">⭐ ${o.movie_rating || ''}</span>
                </div>
                <div class="text-muted small mt-1">
                    <i class="bi bi-calendar"></i> ${o.screening_date || ''} ${o.screening_time || ''}
                    ${o.total_price ? ` • <i class="bi bi-cash"></i> ${Number(o.total_price).toLocaleString()} Ft` : ''}
                </div>
            </div>
        </div>
    `).join('');
}

document.addEventListener('DOMContentLoaded', initProfile);
