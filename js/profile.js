// Profile oldal funkciók (Pontok KISZEDVE)
document.addEventListener('DOMContentLoaded', function () {
    const currentUser = getCurrentUser();

    if (!currentUser) {
        showToast('Kérlek először jelentkezz be!', true);
        setTimeout(() => {
            window.location.href = 'login.html';
        }, 1500);
        return;
    }

    loadProfileEnhanced();
});

function loadProfileEnhanced() {
    const currentUser = getCurrentUser();
    if (!currentUser) return;

    // Basic user
    const firstName = (currentUser.name || '').trim().split(' ')[0] || 'Felhasználó';
    const fullName = currentUser.name || firstName;

    const profileName = document.getElementById('profileName');
    const profileEmail = document.getElementById('profileEmail');
    const totalBookings = document.getElementById('totalBookings');
    const userNameTop = document.getElementById('userName');

    if (profileName) profileName.textContent = fullName;
    if (profileEmail) profileEmail.textContent = currentUser.email || '-';
    if (totalBookings) totalBookings.textContent = String(currentUser.bookings || 0);
    if (userNameTop) userNameTop.textContent = firstName;

    // Member since (user.id Date.now())
    const memberSince = document.getElementById('memberSince');
    if (memberSince) {
        const dt = safeDateFromUserId(currentUser.id);
        memberSince.textContent = dt ? formatHuDate(dt) : '—';
    }

    // Favorites count
    const favCountEl = document.getElementById('favCount');
    if (favCountEl) {
        const favs = getFavorites();
        favCountEl.textContent = String(Array.isArray(favs) ? favs.length : 0);
    }

    // Tier badge from bookings
    const tierBadge = document.getElementById('tierBadge');
    if (tierBadge) {
        const b = Number(currentUser.bookings || 0);
        const tier = getTierFromBookings(b);
        tierBadge.textContent = tier.label;
        tierBadge.classList.add(tier.className);
    }

    // Next ticket preview
    renderNextTicket();
}

function renderNextTicket() {
    const currentUser = getCurrentUser();
    const area = document.getElementById('nextTicketArea');
    if (!area || !currentUser) return;

    const all = getUserBookings();
    const my = all.filter(b => b.userId === currentUser.id);

    const next = pickNextBooking(my);

    if (!next) {
        area.innerHTML = `
            <div class="empty-state">
                <div class="empty-box">
                    <i class="bi bi-film"></i>
                    <h3>Még nincs közelgő jegyed</h3>
                    <p>Foglalj egy filmet, és itt megjelenik “rendes” mozijegyként.</p>
                    <div class="mt-3">
                        <a href="movies.html" class="btn btn-gold">
                            <i class="bi bi-ticket-perforated"></i> Foglalok most
                        </a>
                    </div>
                </div>
            </div>
        `;
        return;
    }

    const movie = (typeof movies !== 'undefined')
        ? movies.find(m => m.id === next.movieId || m.title === next.movieTitle)
        : null;

    const poster = movie?.poster || 'https://via.placeholder.com/400x600?text=CINEMAX';
    const meta = [
        movie?.category ? movie.category : null,
        movie?.duration ? movie.duration : null,
        movie?.rating ? `⭐ ${movie.rating}` : null
    ].filter(Boolean).join(' • ');

    const seatsText = String(next.seats || '').trim();
    const seats = seatsText ? seatsText.split(',').map(s => s.trim()).filter(Boolean) : [];

    const ticketTypes = next.ticketTypes || {};
    const labelMap = {
        adult: 'Felnőtt',
        student: 'Diák',
        child: 'Gyerek',
        senior: 'Nyugdíjas',
        disabled: 'Fogyatékos'
    };

    const breakdown = Object.entries(ticketTypes)
        .filter(([, v]) => Number(v) > 0)
        .map(([k, v]) => `${labelMap[k] || k}: ${v}`)
        .join(' • ');

    const totalFt = Number(next.total || 0).toLocaleString();

    area.innerHTML = `
        <div class="next-ticket">
            <img class="nt-poster" src="${poster}" alt="${next.movieTitle} poszter">

            <div class="nt-mid">
                <div class="nt-title">${next.movieTitle}</div>
                <div class="nt-meta">${meta || 'Mozijegy foglalás'}</div>

                <div class="nt-row">
                    <div class="nt-pill">
                        <i class="bi bi-calendar3"></i>
                        <span>${next.date}</span>
                    </div>
                    <div class="nt-pill">
                        <i class="bi bi-clock"></i>
                        <span>${next.time}</span>
                    </div>
                    <div class="nt-pill">
                        <i class="bi bi-ticket-perforated"></i>
                        <span>${next.tickets} db</span>
                    </div>
                </div>

                <div class="mt-3">
                    <div class="fw-bold mb-2"><i class="bi bi-pin-map"></i> Ülések</div>
                    <div class="nt-seats">
                        ${seats.length ? seats.map(s => `<span class="nt-seat">${s}</span>`).join('') : `<span class="nt-seat">-</span>`}
                    </div>
                </div>

                <div class="mt-3 nt-muted">
                    ${breakdown ? `<div><strong>Bontás:</strong> ${breakdown}</div>` : ``}
                    <div class="mt-1"><strong>Összeg:</strong> ${totalFt} Ft</div>
                </div>

                <div class="mt-3">
                    <a href="bookings.html" class="btn btn-outline-light">
                        <i class="bi bi-list-check"></i> Összes foglalás
                    </a>
                </div>
            </div>

            <div class="nt-right">
                <div class="nt-stub">
                    <div class="nt-stub-title">BELÉPŐ</div>
                    <div class="nt-muted mt-1">
                        Kapunyitás: 30 perccel előtte
                    </div>
                    <div class="nt-qr" aria-label="QR kód helye"></div>
                    <div class="nt-muted">
                        Ref: <strong>${String(next.id || '').slice(-8) || '—'}</strong><br>
                        Mutasd fel belépésnél
                    </div>
                </div>
            </div>
        </div>
    `;
}

/* =========================
   HELPERS
========================= */

function safeDateFromUserId(id) {
    const n = Number(id);
    if (!Number.isFinite(n) || n < 1000000000) return null;
    const d = new Date(n);
    return isNaN(d.getTime()) ? null : d;
}

function formatHuDate(d) {
    // pl. 2026. 02. 10.
    const yyyy = d.getFullYear();
    const mm = String(d.getMonth() + 1).padStart(2, '0');
    const dd = String(d.getDate()).padStart(2, '0');
    return `${yyyy}. ${mm}. ${dd}.`;
}

function getTierFromBookings(bookings) {
    // Te döntheted: ezek csak "hangulat" határok
    if (bookings >= 12) return { label: 'VIP', className: 'tier-vip' };
    if (bookings >= 6) return { label: 'GOLD', className: 'tier-gold' };
    if (bookings >= 3) return { label: 'SILVER', className: 'tier-silver' };
    return { label: 'CINEMAX', className: 'tier-cinemax' };
}

function parseBookingDateTime(b) {
    // b.date: YYYY-MM-DD, b.time: HH:MM
    const dateStr = String(b.date || '').trim();
    const timeStr = String(b.time || '').trim();

    if (!/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) return null;
    if (!/^\d{2}:\d{2}$/.test(timeStr)) return null;

    const [y, m, d] = dateStr.split('-').map(Number);
    const [hh, mm] = timeStr.split(':').map(Number);

    const dt = new Date(y, (m - 1), d, hh, mm, 0, 0);
    return isNaN(dt.getTime()) ? null : dt;
}

function startOfDay(d) {
    const x = new Date(d);
    x.setHours(0,0,0,0);
    return x;
}

function pickNextBooking(bookings) {
    // Közelgő: mostantól (ma 00:00-tól) a jövőbe
    const now = new Date();
    const min = startOfDay(now);

    const withDt = bookings
        .map(b => ({ b, dt: parseBookingDateTime(b) }))
        .filter(x => x.dt && x.dt >= min);

    if (withDt.length === 0) return null;

    withDt.sort((a, b) => a.dt - b.dt);
    return withDt[0].b;
}
