// =============================================================
// CINEMAX – ADMIN.JS  (API-alapú)
// =============================================================

function safeParse(key, fallback) {
    const raw = localStorage.getItem(key);
    if (!raw) return fallback;
    try { return JSON.parse(raw); } catch { return fallback; }
}

function isAdminUser(user) {
    if (!user) return false;
    if (user.isAdmin === true) return true;
    const email = String(user.email || '').toLowerCase().trim();
    return email === 'admin@cinema.hu' || email === 'admin@cinemax.hu';
}

function fmtWhen(dateStr, timeStr) {
    return [dateStr, timeStr].filter(Boolean).join(' ');
}

// =============================================================
// STATISZTIKA
// =============================================================

async function setStats(bookings) {
    // Felhasználók: helyi adat marad (nincs API végpont rá)
    const users = safeParse('users', []);
    document.getElementById('statUsers').textContent     = String(users.length);
    document.getElementById('statBookings').textContent  = String(bookings.length);
    document.getElementById('statTickets').textContent   = String(bookings.length); // 1 API sor = 1 jegy
    document.getElementById('statMovies').textContent    = String(movies.length);
}

// =============================================================
// FILMEK TÁBLÁZAT (API-ból)
// =============================================================

function renderMoviesTable() {
    const tbody = document.getElementById('moviesTable');
    tbody.innerHTML = '';

    movies.forEach(m => {
        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${m.id ?? ''}</td>
            <td class="fw-semibold">${m.title ?? ''}</td>
            <td>${m.category ?? ''}</td>
            <td>⭐ ${m.rating ?? ''}</td>
            <td><span class="badge bg-secondary">Csak backend törölheti</span></td>
        `;
        tbody.appendChild(tr);
    });
}

// =============================================================
// FOGLALÁSOK TÁBLÁZAT (API-ból)
// =============================================================

function renderBookingsTable(bookings) {
    const q     = String(document.getElementById('q')?.value || '').toLowerCase().trim();
    const tbody = document.getElementById('bookingsTable');
    tbody.innerHTML = '';

    const rows = bookings.filter(b => {
        if (!q) return true;
        const title = String(b.movie_name || '').toLowerCase();
        const uname = String(b.user_name  || '').toLowerCase();
        return title.includes(q) || uname.includes(q);
    });

    rows.forEach(b => {
        const seats = (b.seats || []).map(s => `${s.row_num}-${s.column_num}`).join(', ') || '—';
        const when  = fmtWhen(b.screening_date, b.screening_time);

        const tr = document.createElement('tr');
        tr.innerHTML = `
            <td>${b.ticket_order_id ?? ''}</td>
            <td>${when}</td>
            <td class="fw-semibold">${b.movie_name || ''}</td>
            <td><span class="badge text-bg-warning text-dark">${seats}</span></td>
            <td>${b.user_name || '—'}</td>
            <td>${b.total_price ? b.total_price + ' Ft' : '—'}</td>
        `;
        tbody.appendChild(tr);
    });
}

// =============================================================
// INIT
// =============================================================

async function initAdmin() {
    if (!window.cmxRequireAuth || !cmxRequireAuth()) return;

    const user = safeParse('cinemax_user', null);
    const ok   = isAdminUser(user);

    const navAdminItem = document.getElementById('navAdminItem');
    if (navAdminItem) navAdminItem.style.display = ok ? '' : 'none';

    if (!ok) {
        document.getElementById('adminSub').textContent = 'Nincs admin jogosultság.';
        document.getElementById('noAccess').style.display  = 'block';
        document.getElementById('adminWrap').style.display = 'none';
        return;
    }

    document.getElementById('adminSub').textContent =
        `Bejelentkezve: ${(user.email || user.name || user.username || '')}`;
    document.getElementById('noAccess').style.display  = 'none';
    document.getElementById('adminWrap').style.display = 'block';

    // Filmek betöltése API-ból
    await loadMoviesFromAPI(renderMoviesTable);

    // Foglalások betöltése API-ból
    let bookings = [];
    try {
        const data = await apiGetAllTicketOrders();
        bookings   = data.ticket_orders || [];
    } catch (err) {
        console.error('Admin foglalások betöltése sikertelen:', err);
        showToast('Foglalások betöltése sikertelen!', true);
    }

    await setStats(bookings);
    renderBookingsTable(bookings);

    // Keresés
    document.getElementById('q')?.addEventListener('input', () => renderBookingsTable(bookings));

    // Frissítés gomb
    document.getElementById('btnRefresh')?.addEventListener('click', async () => {
        try {
            const data = await apiGetAllTicketOrders();
            bookings   = data.ticket_orders || [];
            await setStats(bookings);
            renderBookingsTable(bookings);
            showToast('Adatok frissítve!');
        } catch (err) {
            showToast('Frissítés sikertelen!', true);
        }
    });
}

document.addEventListener('DOMContentLoaded', initAdmin);
