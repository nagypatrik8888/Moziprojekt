/* ============================================================
   CINEMAX - ADMIN.JS
   Admin panel - backend API alapján
============================================================ */

function isAdminUser(user) {
    if (!user) return false;
    return user.is_admin === true || user.is_admin === 1;
}

function fmtWhen(dateStr, timeStr) {
    if (!dateStr) return '';
    return `${dateStr} ${timeStr || ''}`.trim();
}

async function initAdmin() {
    const user = getCurrentUser();
    if (!user) {
        window.location.href = 'login.html';
        return;
    }

    if (typeof updateUserInterface === 'function') updateUserInterface();

    const adminSub = document.getElementById('adminSub');
    const noAccess = document.getElementById('noAccess');
    const adminWrap = document.getElementById('adminWrap');

    if (!isAdminUser(user)) {
        if (adminSub) adminSub.textContent = 'Nincs admin jogosultság.';
        if (noAccess) noAccess.style.display = 'block';
        if (adminWrap) adminWrap.style.display = 'none';
        return;
    }

    if (adminSub) adminSub.textContent = `Bejelentkezve: ${user.email || user.name || ''}`;
    if (noAccess) noAccess.style.display = 'none';
    if (adminWrap) adminWrap.style.display = 'block';

    // Gombok bekötése
    const btnRefresh = document.getElementById('btnRefresh');
    if (btnRefresh) btnRefresh.addEventListener('click', loadAdminData);

    const qInput = document.getElementById('q');
    if (qInput) qInput.addEventListener('input', () => renderScreeningsFilter());

    const btnAddMovie = document.getElementById('btnAddMovie');
    if (btnAddMovie) btnAddMovie.addEventListener('click', showAddMovieModal);

    // Adatok betöltése
    await loadAdminData();
}

async function loadAdminData() {
    await Promise.all([
        loadAdminStats(),
        loadAdminFilms(),
        loadAdminScreenings(),
        loadAdminUsers(),
    ]);
}

// ===================== STATS =====================

async function loadAdminStats() {
    try {
        const [usersData, filmsData, screeningsData] = await Promise.all([
            apiAdminGetUsers(),
            apiAdminGetFilms(),
            apiAdminGetScreenings(),
        ]);

        const statUsers = document.getElementById('statUsers');
        const statMovies = document.getElementById('statMovies');
        const statBookings = document.getElementById('statBookings');
        const statTickets = document.getElementById('statTickets');

        if (statUsers) statUsers.textContent = (usersData.users || []).length;
        if (statMovies) statMovies.textContent = (filmsData.films || []).length;
        if (statBookings) statBookings.textContent = (screeningsData.screenings || []).length;
        if (statTickets) statTickets.textContent = '—';

    } catch (err) {
        console.error('Stats betöltési hiba:', err);
    }
}

// ===================== FILMEK =====================

let adminFilms = [];

async function loadAdminFilms() {
    const tbody = document.getElementById('moviesTable');
    if (!tbody) return;

    try {
        const data = await apiAdminGetFilms();
        adminFilms = data.films || [];
        renderAdminFilms();
    } catch (err) {
        if (tbody) tbody.innerHTML = `<tr><td colspan="5" class="text-danger">Hiba: ${err.message}</td></tr>`;
    }
}

function renderAdminFilms() {
    const tbody = document.getElementById('moviesTable');
    if (!tbody) return;

    if (!adminFilms.length) {
        tbody.innerHTML = '<tr><td colspan="5" class="text-muted">Nincsenek filmek.</td></tr>';
        return;
    }

    tbody.innerHTML = adminFilms.map(m => `
        <tr>
            <td>${m.film_id ?? ''}</td>
            <td class="fw-semibold">${m.title ?? ''}</td>
            <td>${(m.genre && m.genre.name) || ''}</td>
            <td>⭐ ${m.rating ?? ''}</td>
            <td>
                <span class="text-muted small">${m.duration_min ? m.duration_min + ' perc' : ''}</span>
            </td>
        </tr>
    `).join('');
}

// ===================== VETÍTÉSEK =====================

let adminScreenings = [];

async function loadAdminScreenings() {
    const tbody = document.getElementById('bookingsTable');
    if (!tbody) return;

    try {
        const data = await apiAdminGetScreenings();
        adminScreenings = data.screenings || [];
        renderScreeningsFilter();
    } catch (err) {
        if (tbody) tbody.innerHTML = `<tr><td colspan="4" class="text-danger">Hiba: ${err.message}</td></tr>`;
    }
}

function renderScreeningsFilter() {
    const q = String(document.getElementById('q')?.value || '').toLowerCase().trim();
    const tbody = document.getElementById('bookingsTable');
    if (!tbody) return;

    const filtered = adminScreenings.filter(s => {
        if (!q) return true;
        const title = String(s.film?.title || '').toLowerCase();
        const room = String(s.room?.name || '').toLowerCase();
        return title.includes(q) || room.includes(q);
    });

    if (!filtered.length) {
        tbody.innerHTML = '<tr><td colspan="4" class="text-muted">Nincs találat.</td></tr>';
        return;
    }

    tbody.innerHTML = filtered.map(s => `
        <tr>
            <td>${fmtWhen(s.screening_date, s.start_time)}</td>
            <td class="fw-semibold">${s.film?.title || '—'}</td>
            <td>${(s.film?.genre?.name) || '—'}</td>
            <td>${s.room?.name || s.room?.room_id || '—'}</td>
        </tr>
    `).join('');
}

// ===================== FELHASZNÁLÓK =====================

async function loadAdminUsers() {
    const container = document.getElementById('usersTable');
    if (!container) return;

    try {
        const data = await apiAdminGetUsers();
        const users = data.users || [];

        container.innerHTML = users.map(u => `
            <tr>
                <td>${u.user_id}</td>
                <td class="fw-semibold">${u.name || ''}</td>
                <td>${u.email || ''}</td>
            </tr>
        `).join('');
    } catch (err) {
        container.innerHTML = `<tr><td colspan="3" class="text-danger">Hiba: ${err.message}</td></tr>`;
    }
}

// ===================== ÚJ FILM HOZZÁADÁSA =====================

function showAddMovieModal() {
    const title = prompt('Film címe:');
    if (!title) return;
    showToast('Film hozzáadáshoz töltsd ki a teljes admin formot.', false);
}

document.addEventListener('DOMContentLoaded', initAdmin);
