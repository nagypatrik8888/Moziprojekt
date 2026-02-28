/* ============================================================
   CINEMAX - MOVIES.JS
   Filmek listázása és jegyfoglalás - backend API alapján
============================================================ */

let currentFilter = 'Összes';
let allMovies = [];
let currentMovieDetail = null; // { movie, prices } - a kiválasztott film részletei

// Jegytípusok - a backend price táblából jönnek, de fallback:
let TICKET_TYPES = [];

const SEAT_LAYOUT = { rows: ['A','B','C','D','E','F'], cols: 10 };

let bookingState = resetBookingState(null);

document.addEventListener('DOMContentLoaded', async () => {
    await loadMovies();

    // Ha URL-ben van movie paraméter, nyissuk meg a foglalást
    const params = new URLSearchParams(window.location.search);
    const movieParam = params.get('movie');
    if (movieParam) {
        const movie = allMovies.find(m => String(m.movie_id) === String(movieParam));
        if (movie) openBookingModal(movie.movie_id);
    }
});

// ===================== FILMEK BETÖLTÉSE =====================

async function loadMovies() {
    const grid = document.getElementById('allMovies');
    if (!grid) return;

    grid.innerHTML = `
        <div class="col-12 text-center py-5">
            <div class="spinner-border text-warning" role="status"></div>
            <p class="mt-2 text-muted">Filmek betöltése...</p>
        </div>
    `;

    // Szűrő gombok betöltése
    const filterContainer = document.getElementById('genreFilters');

    try {
        const data = await apiGetMovies();
        allMovies = data.movies || [];
        window.moviesCache = allMovies;

        // Szűrő gombok renderelése
        if (filterContainer && data.genres) {
            renderGenreFilters(data.genres);
        }

        renderMovies(currentFilter);
    } catch (err) {
        grid.innerHTML = `
            <div class="col-12 text-center py-5">
                <i class="bi bi-exclamation-triangle text-warning" style="font-size:2rem;"></i>
                <p class="mt-2">Nem sikerült betölteni a filmeket.</p>
                <p class="text-muted small">Ellenőrizd, hogy fut-e a Laravel szerver (port 8888).</p>
            </div>
        `;
        console.error(err);
    }
}

function renderGenreFilters(genres) {
    const filterContainer = document.getElementById('genreFilters');
    if (!filterContainer) return;

    // Megtartjuk az "Összes" gombot ha van, különben hozzáadjuk
    const allBtn = filterContainer.querySelector('[data-genre="Összes"]') ||
        Object.assign(document.createElement('button'), {
            className: 'filter-btn btn btn-outline-gold btn-sm active',
            textContent: 'Összes',
            onclick: () => filterMovies('Összes')
        });
    allBtn.setAttribute('data-genre', 'Összes');

    filterContainer.innerHTML = '';
    filterContainer.appendChild(allBtn);

    genres.forEach(g => {
        if (!g.genre_name) return;
        const btn = document.createElement('button');
        btn.className = 'filter-btn btn btn-outline-gold btn-sm';
        btn.textContent = g.genre_name;
        btn.setAttribute('data-genre', g.genre_name);
        btn.onclick = () => filterMovies(g.genre_name);
        filterContainer.appendChild(btn);
    });
}

// ===================== FILMEK RENDERELÉSE =====================

function renderMovies(category) {
    currentFilter = category;
    const favorites = getFavorites();

    const filtered = category === 'Összes'
        ? allMovies
        : allMovies.filter(m => m.genre_name === category);

    const grid = document.getElementById('allMovies');
    if (!grid) return;

    if (filtered.length === 0) {
        grid.innerHTML = `
            <div class="col-12">
                <div class="text-center py-5">
                    <i class="bi bi-film" style="font-size:4rem; opacity:0.55;"></i>
                    <h3 class="mt-3">Ezen a héten nem vetítünk ${(category || '').toLowerCase()} filmet.</h3>
                    <p class="text-muted mt-2 mb-0">Válassz másik kategóriát, vagy nézz vissza később 🎬</p>
                </div>
            </div>
        `;
        return;
    }

    grid.innerHTML = filtered.map(movie => `
        <div class="col-md-6 col-lg-4">
            <div class="movie-card">
                <div class="position-relative overflow-hidden">
                    <img src="${movie.poster_url || 'https://via.placeholder.com/300x450?text=No+Poster'}" 
                         alt="${movie.title}" class="movie-poster"
                         onerror="this.src='https://via.placeholder.com/300x450?text=No+Poster'">
                    <button class="favorite-btn" onclick="event.stopPropagation(); toggleFavorite(${movie.movie_id})">
                        ${favorites.includes(movie.movie_id) ? '❤️' : '🤍'}
                    </button>
                </div>
                <div class="p-3">
                    <h5 class="fw-bold mb-2">${movie.title}</h5>
                    <div class="d-flex gap-3 mb-2 small text-muted">
                        <span><i class="bi bi-tag"></i> ${movie.genre_name || ''}</span>
                        <span><i class="bi bi-star-fill text-warning"></i> ${movie.rating || ''}</span>
                        <span><i class="bi bi-clock"></i> ${movie.duration ? movie.duration + ' perc' : ''}</span>
                    </div>
                    <p class="text-muted small">${movie.description || ''}</p>
                    <button class="btn btn-gold w-100 mt-2" onclick="openBookingModal(${movie.movie_id})">
                        <i class="bi bi-ticket-perforated"></i> Jegyvásárlás
                    </button>
                </div>
            </div>
        </div>
    `).join('');
}

function filterMovies(category) {
    document.querySelectorAll('.filter-btn').forEach(btn => btn.classList.remove('active'));
    const activeBtn = document.querySelector(`.filter-btn[data-genre="${category}"]`);
    if (activeBtn) activeBtn.classList.add('active');
    renderMovies(category);
}

function toggleFavorite(movieId) {
    let favorites = getFavorites();
    const idx = favorites.indexOf(movieId);
    if (idx > -1) {
        favorites.splice(idx, 1);
        showToast('Eltávolítva a kedvencekből');
    } else {
        favorites.push(movieId);
        showToast('Hozzáadva a kedvencekhez! ❤️');
    }
    setFavorites(favorites);
    renderMovies(currentFilter);
}

// ===================== BOOKING MODAL =====================

function resetBookingState(movieId) {
    return {
        movieId,
        screeningId: null,
        selectedSeats: [],
        ticketCounts: {}
    };
}

async function openBookingModal(movieId) {
    const currentUser = getCurrentUser();
    if (!currentUser) {
        showToast('Kérlek először jelentkezz be!', true);
        setTimeout(() => window.location.href = 'login', 1000);
        return;
    }

    bookingState = resetBookingState(movieId);

    // Modal megjelenítése töltés jelzővel
    const modalEl = document.getElementById('bookingModal');
    if (!modalEl) return;

    document.getElementById('bookingMovieTitle').textContent = 'Betöltés...';
    document.getElementById('bookingMovieMeta').textContent = '';
    document.getElementById('bookingTimes').innerHTML = '<div class="text-muted small">Vetítések betöltése...</div>';
    document.getElementById('seatsArea').innerHTML = '<div class="text-muted py-4">Válassz vetítést.</div>';

    const modal = new bootstrap.Modal(modalEl);
    modal.show();

    try {
        const data = await apiGetMovie(movieId);
        currentMovieDetail = data;

        const movie = data.movie;
        const prices = data.prices || [];

        // Jegytípusok a backend áraiból
        TICKET_TYPES = prices.map(p => ({
            key: String(p.price_id),
            label: p.price_type || 'Jegy',
            price: Number(p.price),
            price_id: p.price_id,
        }));

        // Inicializáljuk a ticketCounts-ot
        bookingState.ticketCounts = Object.fromEntries(TICKET_TYPES.map(t => [t.key, 0]));

        document.getElementById('bookingMovieTitle').textContent = movie.title;
        document.getElementById('bookingMovieMeta').textContent =
            `${movie.genre_name} • ${movie.duration} perc • ⭐ ${movie.rating}`;

        // Vetítések renderelése
        renderScreenings(movie.screenings || []);

        // Jegytípus gombok
        renderTicketTypes();

        // Confirm gomb
        document.getElementById('confirmBookingBtn').onclick = confirmBooking;

        updateTicketUI();
        renderSeatsForBooking();
        updateSummary();

        // Szék kattintás
        const seatsArea = document.getElementById('seatsArea');
        seatsArea.onclick = (e) => {
            const seatEl = e.target.closest('.seat[data-seat-id]');
            if (!seatEl || seatEl.classList.contains('occupied')) return;

            const seatId = Number(seatEl.dataset.seatId);
            const idx = bookingState.selectedSeats.findIndex(s => s.seat_id === seatId);

            if (idx > -1) {
                bookingState.selectedSeats.splice(idx, 1);
            } else {
                if (bookingState.selectedSeats.length >= totalTickets()) {
                    showToast(`Maximum ${totalTickets()} széket választhatsz.`, true);
                    return;
                }
                bookingState.selectedSeats.push({ seat_id: seatId });
            }

            renderSeatsForBooking();
            updateSummary();
        };

    } catch (err) {
        document.getElementById('bookingMovieTitle').textContent = 'Hiba';
        document.getElementById('bookingTimes').innerHTML =
            '<div class="text-danger small">Nem sikerült betölteni a vetítési adatokat.</div>';
        console.error(err);
    }
}

function renderScreenings(screenings) {
    const wrap = document.getElementById('bookingTimes');
    if (!wrap) return;

    if (!screenings.length) {
        wrap.innerHTML = '<div class="text-muted small">Nincs elérhető vetítés.</div>';
        return;
    }

    wrap.innerHTML = screenings.map(s => {
        const label = `${s.start_date} ${s.start_time}`;
        return `
            <button type="button" class="btn btn-outline-gold btn-sm booking-time" 
                    data-screening-id="${s.screening_id}" data-label="${label}">
                <i class="bi bi-clock"></i> ${label}
            </button>
        `;
    }).join('');

    // Széklayout tárolása screening-enként
    wrap.querySelectorAll('.booking-time').forEach(btn => {
        btn.onclick = () => {
            bookingState.screeningId = Number(btn.dataset.screeningId);
            bookingState.selectedSeats = [];

            // Megkeressük a hozzá tartozó screening adatait (szobák, székek)
            const sc = currentMovieDetail.movie.screenings.find(
                s => String(s.screening_id) === btn.dataset.screeningId
            );
            bookingState.currentScreening = sc || null;

            document.querySelectorAll('.booking-time').forEach(b => {
                b.classList.toggle('btn-gold', b === btn);
                b.classList.toggle('btn-outline-gold', b !== btn);
            });

            renderSeatsForBooking();
            updateSummary();
        };
    });
}

function renderTicketTypes() {
    // Dinamikusan generáljuk a jegytípus sorokat a modal ticket-section-jébe
    const section = document.getElementById('ticketSection');
    if (!section) return;

    if (!TICKET_TYPES.length) {
        section.innerHTML = '<p class="text-muted small">Nincsenek elérhető jegytípusok.</p>';
        return;
    }

    section.innerHTML = TICKET_TYPES.map(t => `
        <div class="d-flex justify-content-between align-items-center mb-2">
            <div>
                <span class="fw-semibold">${t.label}</span>
                <span class="text-muted small ms-2">${t.price.toLocaleString()} Ft</span>
            </div>
            <div class="d-flex align-items-center gap-2">
                <button type="button" class="btn btn-outline-secondary btn-sm ticket-minus" data-type="${t.key}">−</button>
                <span class="fw-bold" id="ticket-${t.key}">0</span>
                <button type="button" class="btn btn-outline-secondary btn-sm ticket-plus" data-type="${t.key}">+</button>
            </div>
        </div>
    `).join('');

    section.querySelectorAll('.ticket-plus').forEach(btn => {
        btn.onclick = () => {
            const key = btn.dataset.type;
            bookingState.ticketCounts[key] = (bookingState.ticketCounts[key] || 0) + 1;
            enforceSeatCount();
            updateTicketUI();
            renderSeatsForBooking();
            updateSummary();
        };
    });
    section.querySelectorAll('.ticket-minus').forEach(btn => {
        btn.onclick = () => {
            const key = btn.dataset.type;
            bookingState.ticketCounts[key] = Math.max(0, (bookingState.ticketCounts[key] || 0) - 1);
            enforceSeatCount();
            updateTicketUI();
            renderSeatsForBooking();
            updateSummary();
        };
    });
}

function updateTicketUI() {
    for (const t of TICKET_TYPES) {
        const el = document.getElementById(`ticket-${t.key}`);
        if (el) el.textContent = String(bookingState.ticketCounts[t.key] || 0);
    }
}

function totalTickets() {
    return Object.values(bookingState.ticketCounts).reduce((a, b) => a + (b || 0), 0);
}

function totalPrice() {
    return TICKET_TYPES.reduce((sum, t) =>
        sum + (bookingState.ticketCounts[t.key] || 0) * t.price, 0);
}

function breakdownText() {
    return TICKET_TYPES
        .map(t => (bookingState.ticketCounts[t.key] || 0) > 0
            ? `${t.label}: ${bookingState.ticketCounts[t.key]}`
            : null)
        .filter(Boolean)
        .join(' • ');
}

function enforceSeatCount() {
    const max = totalTickets();
    if (bookingState.selectedSeats.length > max) {
        bookingState.selectedSeats = bookingState.selectedSeats.slice(0, max);
    }
}

function renderSeatsForBooking() {
    const seatsArea = document.getElementById('seatsArea');
    const hint = document.getElementById('bookingHint');

    if (!bookingState.screeningId) {
        seatsArea.innerHTML = `
            <div class="text-muted py-5">
                <i class="bi bi-calendar3" style="font-size:2rem;"></i>
                <div class="mt-2">Válassz vetítési időpontot a székekhez.</div>
            </div>
        `;
        if (hint) hint.textContent = 'Válassz vetítési időpontot.';
        return;
    }

    if (totalTickets() === 0) {
        seatsArea.innerHTML = `
            <div class="text-muted py-5">
                <i class="bi bi-ticket-perforated" style="font-size:2rem;"></i>
                <div class="mt-2">Előbb válassz jegytípust és darabszámot.</div>
            </div>
        `;
        if (hint) hint.textContent = 'Állíts be legalább 1 jegyet.';
        return;
    }

    if (hint) hint.textContent = `Válassz pontosan ${totalTickets()} széket.`;

    // Backend-ből jövő szék adatok
    const sc = bookingState.currentScreening;
    const roomSeats = sc && sc.room && sc.room.seats ? sc.room.seats : [];

    // Ha nincs szék adat, fallback statikus elrendezésre
    if (roomSeats.length === 0) {
        seatsArea.innerHTML = buildStaticSeatGridHTML(bookingState.selectedSeats.map(s => s.seat_id));
        return;
    }

    // Backend szék adatok alapján renderelünk
    seatsArea.innerHTML = buildBackendSeatGridHTML(roomSeats, bookingState.selectedSeats.map(s => s.seat_id));
}

function buildBackendSeatGridHTML(seats, selectedIds) {
    const selSet = new Set(selectedIds);
    // Csoportosítás sorok szerint
    const rows = {};
    seats.forEach(seat => {
        const r = seat.row || seat.row_num || 'A';
        if (!rows[r]) rows[r] = [];
        rows[r].push(seat);
    });

    const rowsHtml = Object.keys(rows).sort().map(r => {
        const colsHtml = rows[r]
            .sort((a, b) => (a.column || a.column_num || 0) - (b.column || b.column_num || 0))
            .map(seat => {
                const id = seat.seat_id || seat.id;
                const isSel = selSet.has(id);
                const cls = ['seat', isSel ? 'selected' : ''].join(' ').trim();
                return `<div class="${cls}" data-seat-id="${id}" title="${r}${seat.column || seat.column_num}">${seat.column || seat.column_num}</div>`;
            }).join('');
        return `<div class="seat-row"><div class="row-label">${r}</div>${colsHtml}</div>`;
    }).join('');

    return `<div class="seat-grid">${rowsHtml}</div>`;
}

function buildStaticSeatGridHTML(selectedIds) {
    const sel = new Set(selectedIds);
    const rowsHtml = SEAT_LAYOUT.rows.map(r => {
        const colsHtml = Array.from({length: SEAT_LAYOUT.cols}, (_, i) => {
            const num = i + 1;
            // Statikus esetben nincs valós seat_id, stringet használunk
            const fakeId = `${r}${num}`;
            const cls = ['seat', sel.has(fakeId) ? 'selected' : ''].join(' ').trim();
            return `<div class="${cls}" data-seat-id="${fakeId}" title="${fakeId}">${num}</div>`;
        }).join('');
        return `<div class="seat-row"><div class="row-label">${r}</div>${colsHtml}</div>`;
    }).join('');
    return `<div class="seat-grid">${rowsHtml}</div>`;
}

function updateSummary() {
    const tCount = totalTickets();
    const sCount = bookingState.selectedSeats.length;

    const tcEl = document.getElementById('ticketCount');
    const tpEl = document.getElementById('totalPrice');
    const tbEl = document.getElementById('ticketBreakdown');
    const ssEl = document.getElementById('selectedSeatsText');
    const confirmBtn = document.getElementById('confirmBookingBtn');

    if (tcEl) tcEl.textContent = `${tCount} db`;
    if (tpEl) tpEl.textContent = `${totalPrice().toLocaleString()} Ft`;
    if (tbEl) tbEl.textContent = breakdownText();
    if (ssEl) ssEl.textContent = sCount
        ? `Kiválasztott ülések: ${bookingState.selectedSeats.length} db`
        : '';

    const canConfirm = bookingState.movieId && bookingState.screeningId && tCount > 0 && sCount === tCount;
    if (confirmBtn) confirmBtn.disabled = !canConfirm;
}

async function confirmBooking() {
    const currentUser = getCurrentUser();
    if (!currentUser) return;

    const tCount = totalTickets();
    if (!bookingState.screeningId || tCount === 0) {
        showToast('Válassz vetítési időpontot és jegyeket!', true);
        return;
    }
    if (bookingState.selectedSeats.length !== tCount) {
        showToast(`Pontosan ${tCount} széket válassz!`, true);
        return;
    }

    const confirmBtn = document.getElementById('confirmBookingBtn');
    if (confirmBtn) { confirmBtn.disabled = true; confirmBtn.textContent = 'Foglalás...'; }

    try {
        // Összeállítjuk a seats tömböt: mindegyik szék kap egy price_id-t
        const seatsPayload = [];
        for (const t of TICKET_TYPES) {
            const count = bookingState.ticketCounts[t.key] || 0;
            for (let i = 0; i < count; i++) {
                const seat = bookingState.selectedSeats[seatsPayload.length];
                if (seat) {
                    seatsPayload.push({
                        seat_id: seat.seat_id,
                        price_id: t.price_id,
                    });
                }
            }
        }

        const res = await apiCreateTicketOrder(bookingState.screeningId, seatsPayload);
        const data = await res.json();

        if (res.ok && data.ticket_order_id) {
            showToast('Sikeres foglalás! 🎉');

            // Frissítjük a user pont adatait
            const user = getCurrentUser();
            if (user) {
                user.points = (user.points || 0) + Math.round(totalPrice() / 100);
                setCurrentUser(user);
            }

            const modalEl = document.getElementById('bookingModal');
            const modal = bootstrap.Modal.getInstance(modalEl);
            if (modal) modal.hide();

        } else {
            const msg = extractBookingError(data) || 'Foglalási hiba.';
            showToast(msg, true);
        }
    } catch (err) {
        showToast('Nem sikerült a foglalás. Ellenőrizd a kapcsolatot!', true);
        console.error(err);
    } finally {
        if (confirmBtn) { confirmBtn.disabled = false; confirmBtn.textContent = 'Foglalás megerősítése'; }
    }
}

function extractBookingError(data) {
    if (!data) return null;
    if (data.errors && Array.isArray(data.errors)) return data.errors[0];
    if (data.errors && typeof data.errors === 'object') {
        const first = Object.values(data.errors)[0];
        return Array.isArray(first) ? first[0] : first;
    }
    if (data.message) return data.message;
    return null;
}
