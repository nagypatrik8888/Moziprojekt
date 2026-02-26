// =============================================================
// CINEMAX – PROFILE.JS  (API-alapú)
// =============================================================

function fmtNextBooking(bookings) {
    const now  = Date.now();
    const next = (bookings || [])
        .map(b => {
            const iso = `${b.screening_date || b.date || ''}T${(b.screening_time || b.time || '00:00')}:00`;
            const t   = new Date(iso).getTime();
            return { b, t };
        })
        .filter(x => Number.isFinite(x.t) && x.t > now)
        .sort((a, c) => a.t - c.t)[0]?.b;

    if (!next) return 'Nincs';
    const date  = next.screening_date || next.date || '';
    const time  = next.screening_time || next.time || '';
    const title = next.movie_name     || next.movieTitle || '';
    return `${date} • ${time} (${title})`;
}

async function initProfile() {
    if (typeof updateUserInterface === 'function') updateUserInterface();

    const user = (typeof getCurrentUser === 'function') ? getCurrentUser() : null;
    if (!user) { window.location.href = 'login.html'; return; }

    const name   = (user.name || user.username || user.email || '').trim();
    const email  = (user.email || '').trim();
    const points = user.points || 0;

    const usernameEl = document.getElementById('username');
    const emailEl    = document.getElementById('email');
    if (usernameEl) usernameEl.textContent = name;
    if (emailEl)    emailEl.textContent    = email;

    const pointsEl = document.getElementById('points');
    if (pointsEl) pointsEl.textContent = String(points);

    const badge = document.getElementById('badge');
    if (badge) badge.textContent = 'SILVER';

    const logoutBtn = document.getElementById('logoutBtn');
    if (logoutBtn) {
        logoutBtn.addEventListener('click', (e) => {
            e.preventDefault();
            if (typeof logout === 'function') logout();
            else window.location.href = 'index.html';
        });
    }

    // Foglalások betöltése API-ból
    let myBookings = [];
    try {
        const data = await apiGetProfileTicketOrders();
        myBookings = data.ticket_orders || [];
    } catch (err) {
        console.warn('Profil foglalások betöltése sikertelen, localStorage fallback:', err);
        // Fallback: helyi cache
        const all = (typeof getUserBookings === 'function') ? getUserBookings() : [];
        myBookings = all.filter(b => b.userId === user.id);
    }

    const favs = (typeof getFavorites === 'function') ? getFavorites() : [];

    // Foglalások száma: API-ból minden sor = 1 jegy
    const totalTickets = myBookings.length;

    const bookingCountEl = document.getElementById('bookingCount');
    const favCountEl     = document.getElementById('favCount');
    const sumBookingsEl  = document.getElementById('sumBookings');
    const sumNextEl      = document.getElementById('sumNext');

    if (bookingCountEl) bookingCountEl.textContent = String(totalTickets);
    if (favCountEl)     favCountEl.textContent     = String(Array.isArray(favs) ? favs.length : 0);
    if (sumBookingsEl)  sumBookingsEl.textContent   = String(totalTickets);
    if (sumNextEl)      sumNextEl.textContent       = fmtNextBooking(myBookings);
}

document.addEventListener('DOMContentLoaded', initProfile);
document.addEventListener("DOMContentLoaded", loadOrders);

async function loadOrders() {
    try {
        const data = await apiRequest("/api/profile/ticket_orders");

        const container = document.getElementById("ordersContainer");
        if (!container || !data.ticket_orders) return;

        container.innerHTML = "";

        data.ticket_orders.forEach(order => {
            const div = document.createElement("div");
            div.innerHTML = `
                <p>Order ID: ${order.ticket_order_id}</p>
                <p>Összeg: ${order.total_price} Ft</p>
            `;
            container.appendChild(div);
        });

    } catch (error) {
        console.error(error);
    }
}
