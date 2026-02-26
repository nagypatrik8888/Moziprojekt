// =============================================================
// CINEMAX – MOVIES.JS  (API-alapú)
// =============================================================

let currentFilter = 'Összes';

// Az árak és szék-layout az API-ból jön (apiGetMovie),
// de fallback értékeket tartunk, ha a backend screenings még üres.
let TICKET_TYPES = [
    { key: 'adult',    label: 'Felnőtt',    price: 2490, price_id: null },
    { key: 'student',  label: 'Diák',       price: 1990, price_id: null },
    { key: 'child',    label: 'Gyerek',     price: 1690, price_id: null },
    { key: 'senior',   label: 'Nyugdíjas',  price: 1790, price_id: null },
    { key: 'disabled', label: 'Fogyatékos', price: 1490, price_id: null },
];

const SEAT_LAYOUT = { rows: ['A','B','C','D','E','F'], cols: 10 };

let bookingState = resetBookingState(null);
// Aktuális film részletes adatai (screenings, prices) az API-ból
let currentMovieDetail = null;

// =============================================================
// INIT
// =============================================================

document.addEventListener('DOMContentLoaded', () => {
    // Filmek betöltése API-ból, majd renderelés
    loadMoviesFromAPI(() => {
        renderFilterButtons();
        renderMovies(currentFilter);
    });
});

// =============================================================
// SZŰRŐ GOMBOK – API-ból jövő műfajok alapján
// =============================================================

function renderFilterButtons() {
    const wrap = document.querySelector('.filter-buttons');
    if (!wrap) return;

    const allGenres = ['Összes', ...genres];
    wrap.innerHTML = allGenres.map((g, i) => `
        <button class="btn filter-btn${i === 0 ? ' active' : ''}"
                onclick="filterMovies('${g}', this)">${g}</button>
    `).join('');
}

// =============================================================
// FILMEK LISTÁJA + SZŰRŐ
// =============================================================

function renderMovies(category) {
    currentFilter = category;

    const filtered = category === 'Összes'
        ? movies
        : movies.filter(m => m.category === category);

    const grid = document.getElementById('allMovies');
    if (!grid) return;

    if (filtered.length === 0) {
        const cat = (category || '').toLowerCase();
        grid.innerHTML = `
            <div class="col-12">
                <div class="text-center py-5">
                    <i class="bi bi-film" style="font-size:4rem; opacity:0.55;"></i>
                    <h3 class="mt-3">Ezen a héten nem vetítünk ${cat} filmet.</h3>
                    <p class="text-muted mt-2 mb-0">Válassz másik kategóriát, vagy nézz vissza később 🎬</p>
                </div>
            </div>`;
        return;
    }

    const favorites = getFavorites();

    grid.innerHTML = filtered.map(movie => `
        <div class="col-md-6 col-lg-4">
            <div class="movie-card">
                <div class="position-relative overflow-hidden">
                    <img src="${movie.poster}" alt="${movie.title}" class="movie-poster">
                    <button class="favorite-btn" onclick="event.stopPropagation(); toggleFavorite(${movie.id})">
                        ${favorites.includes(movie.id) ? '❤️' : '🤍'}
                    </button>
                </div>
                <div class="p-3">
                    <h5 class="fw-bold mb-2">${movie.title}</h5>
                    <div class="d-flex gap-3 mb-2 small text-muted">
                        <span><i class="bi bi-tag"></i> ${movie.category}</span>
                        <span><i class="bi bi-star-fill text-warning"></i> ${movie.rating}</span>
                        <span><i class="bi bi-clock"></i> ${movie.duration}</span>
                    </div>
                    <p class="text-muted small">${movie.description}</p>
                    <button class="btn btn-gold w-100 mt-2" onclick="openBookingModal(${movie.id})">
                        <i class="bi bi-ticket-perforated"></i> Jegyvásárlás
                    </button>
                </div>
            </div>
        </div>
    `).join('');
}

function filterMovies(category, btnEl) {
    document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
    if (btnEl) btnEl.classList.add('active');
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

// =============================================================
// FOGLALÁS MODAL
// =============================================================

function resetBookingState(movieId) {
    return {
        movieId,
        screeningId: null,
        date: null,
        time: null,
        selectedSeats: [],
        ticketCounts: Object.fromEntries(TICKET_TYPES.map(t => [t.key, 0]))
    };
}

async function openBookingModal(movieId) {
    const currentUser = getCurrentUser();
    if (!currentUser) {
        showToast('Kérlek először jelentkezz be!', true);
        setTimeout(() => window.location.href = 'login.html', 1000);
        return;
    }

    const movie = movies.find(m => m.id === movieId);
    if (!movie) return;

    bookingState = resetBookingState(movieId);

    // Modal fejléc
    document.getElementById('bookingMovieTitle').textContent = movie.title;
    document.getElementById('bookingMovieMeta').textContent =
        `${movie.category} • ${movie.duration} • ⭐ ${movie.rating}`;

    // API: részletes film + árak betöltése
    showToast('Időpontok betöltése...');
    currentMovieDetail = await loadMovieDetailFromAPI(movieId);

    // Árkategóriák frissítése az API válasz alapján
    if (currentMovieDetail?.prices?.length) {
        TICKET_TYPES = currentMovieDetail.prices.map(p => ({
            key:      p.price_type,
            label:    priceTypeLabel(p.price_type),
            price:    Number(p.price),
            price_id: p.price_id,
        }));
        bookingState.ticketCounts = Object.fromEntries(TICKET_TYPES.map(t => [t.key, 0]));
    }

    // Dátum picker
    const dateInput = document.getElementById('bookingDate');
    const now       = new Date();
    const today     = startOfDay(now);
    const weekEnd   = endOfWeek(now);
    dateInput.min   = toISODate(today);
    dateInput.max   = toISODate(weekEnd);
    dateInput.value = toISODate(today);
    bookingState.date = dateInput.value;

    renderQuickDaysRange(today, weekEnd);

    // Vetítési idők – screening adatokból
    const screenings = currentMovieDetail?.movie?.screenings || movie._screenings || [];
    renderTimesFromScreenings(screenings, bookingState.date);

    dateInput.onchange = () => {
        if (dateInput.value < dateInput.min) dateInput.value = dateInput.min;
        if (dateInput.value > dateInput.max) dateInput.value = dateInput.max;
        bookingState.date = dateInput.value || null;
        bookingState.time = null;
        bookingState.screeningId = null;
        bookingState.selectedSeats = [];
        renderTimesFromScreenings(screenings, bookingState.date);
        renderSeats();
        updateSummary();
    };

    bindTicketButtons();
    document.getElementById('confirmBookingBtn').onclick = confirmBooking;

    updateTicketUI();
    renderSeats();
    updateSummary();

    const modalEl = document.getElementById('bookingModal');
    new bootstrap.Modal(modalEl).show();

    const seatsArea = document.getElementById('seatsArea');
    seatsArea.onclick = (e) => {
        const seatEl = e.target.closest('.seat[data-seat]');
        if (!seatEl || seatEl.classList.contains('occupied')) return;
        const seatId = seatEl.dataset.seat;
        const idx = bookingState.selectedSeats.indexOf(seatId);
        if (idx > -1) {
            bookingState.selectedSeats.splice(idx, 1);
        } else {
            if (bookingState.selectedSeats.length >= totalTickets()) {
                showToast(`Maximum ${totalTickets()} széket választhatsz.`, true);
                return;
            }
            bookingState.selectedSeats.push(seatId);
        }
        renderSeats();
        updateSummary();
    };
}

/** API price_type -> magyar felirat */
function priceTypeLabel(type) {
    const map = { adult:'Felnőtt', student:'Diák', child:'Gyerek', senior:'Nyugdíjas', disabled:'Fogyatékos' };
    return map[type] || type;
}

/** Screenings listából időpontok renderelése az adott napra */
function renderTimesFromScreenings(screenings, date) {
    const wrap = document.getElementById('bookingTimes');
    if (!wrap) return;

    // A screening objektum: { screening_id, start_time, date, ... }
    // Ha nincs dátum mező, minden időpontot mutatunk
    const dayScreenings = screenings.filter(s => {
        if (!s.date && !s.screening_date) return true;
        return (s.date || s.screening_date) === date;
    });

    if (!dayScreenings.length) {
        wrap.innerHTML = `<span class="text-muted small">Erre a napra nincs vetítés.</span>`;
        return;
    }

    wrap.innerHTML = dayScreenings.map(s => {
        const time = s.start_time || s.time || '';
        return `
            <button type="button" class="btn btn-outline-gold btn-sm booking-time"
                    data-time="${time}" data-screening-id="${s.screening_id || ''}">
                <i class="bi bi-clock"></i> ${time}
            </button>`;
    }).join('');

    wrap.querySelectorAll('.booking-time').forEach(btn => {
        btn.onclick = () => {
            bookingState.time = btn.dataset.time;
            bookingState.screeningId = btn.dataset.screeningId || null;
            bookingState.selectedSeats = [];
            updateTimesActive();
            renderSeats();
            updateSummary();
        };
    });

    updateTimesActive();
}

function updateTimesActive() {
    document.querySelectorAll('.booking-time').forEach(btn => {
        const active = bookingState.time === btn.dataset.time;
        btn.classList.toggle('btn-gold', active);
        btn.classList.toggle('btn-outline-gold', !active);
    });
}

// =============================================================
// JEGYEK
// =============================================================

function bindTicketButtons() {
    document.querySelectorAll('.ticket-plus').forEach(btn => {
        btn.onclick = () => {
            const type = btn.dataset.type;
            bookingState.ticketCounts[type] = (bookingState.ticketCounts[type] || 0) + 1;
            enforceSeatCount();
            updateTicketUI();
            renderSeats();
            updateSummary();
        };
    });
    document.querySelectorAll('.ticket-minus').forEach(btn => {
        btn.onclick = () => {
            const type = btn.dataset.type;
            bookingState.ticketCounts[type] = Math.max(0, (bookingState.ticketCounts[type] || 0) - 1);
            enforceSeatCount();
            updateTicketUI();
            renderSeats();
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
    return TICKET_TYPES.reduce((sum, t) => sum + (bookingState.ticketCounts[t.key] || 0) * t.price, 0);
}

function breakdownText() {
    return TICKET_TYPES
        .map(t => (bookingState.ticketCounts[t.key] || 0) > 0 ? `${t.label}: ${bookingState.ticketCounts[t.key]}` : null)
        .filter(Boolean).join(' • ');
}

function enforceSeatCount() {
    const max = totalTickets();
    if (bookingState.selectedSeats.length > max)
        bookingState.selectedSeats = bookingState.selectedSeats.slice(0, max);
}

// =============================================================
// SZÉKEK
// =============================================================

function renderSeats() {
    const seatsArea = document.getElementById('seatsArea');
    const hint      = document.getElementById('bookingHint');

    if (!bookingState.date || !bookingState.time) {
        seatsArea.innerHTML = `
            <div class="text-muted py-5">
                <i class="bi bi-calendar3" style="font-size:2rem;"></i>
                <div class="mt-2">Válassz napot és időpontot a székekhez.</div>
            </div>`;
        hint.textContent = 'Válassz napot + időpontot.';
        return;
    }
    if (totalTickets() === 0) {
        seatsArea.innerHTML = `
            <div class="text-muted py-5">
                <i class="bi bi-ticket-perforated" style="font-size:2rem;"></i>
                <div class="mt-2">Előbb válassz jegytípust és darabszámot.</div>
            </div>`;
        hint.textContent = 'Állíts be legalább 1 jegyet.';
        return;
    }

    hint.textContent = `Válassz pontosan ${totalTickets()} széket.`;
    const occupied  = getOccupiedForShow(bookingState.movieId, bookingState.date, bookingState.time);
    seatsArea.innerHTML = buildSeatGridHTML(occupied, bookingState.selectedSeats);
}

function buildSeatGridHTML(occupiedSeats, selectedSeats) {
    const occ = new Set(occupiedSeats);
    const sel = new Set(selectedSeats);
    const rowsHtml = SEAT_LAYOUT.rows.map(r => {
        const colsHtml = Array.from({length: SEAT_LAYOUT.cols}, (_, i) => {
            const num = i + 1;
            const id  = `${r}${num}`;
            const cls = ['seat', occ.has(id) ? 'occupied' : '', sel.has(id) ? 'selected' : ''].join(' ').trim();
            return `<div class="${cls}" data-seat="${id}" title="${id}">${num}</div>`;
        }).join('');
        return `<div class="seat-row"><div class="row-label">${r}</div>${colsHtml}</div>`;
    }).join('');
    return `<div class="seat-grid">${rowsHtml}</div>`;
}

// =============================================================
// ÖSSZESÍTŐ + FOGLALÁS KÜLDÉSE
// =============================================================

function updateSummary() {
    const tCount = totalTickets();
    const sCount = bookingState.selectedSeats.length;

    document.getElementById('ticketCount').textContent     = `${tCount} db`;
    document.getElementById('totalPrice').textContent      = `${totalPrice().toLocaleString()} Ft`;
    document.getElementById('ticketBreakdown').textContent = breakdownText();
    document.getElementById('selectedSeatsText').textContent =
        sCount ? `Kiválasztott ülések: ${bookingState.selectedSeats.join(', ')}` : '';

    const canConfirm = bookingState.movieId && bookingState.date && bookingState.time
        && bookingState.screeningId && tCount > 0 && sCount === tCount;
    document.getElementById('confirmBookingBtn').disabled = !canConfirm;
}

async function confirmBooking() {
    const currentUser = getCurrentUser();
    const movie = movies.find(m => m.id === bookingState.movieId);
    if (!currentUser || !movie) return;

    const tCount = totalTickets();
    if (!bookingState.date || !bookingState.time || tCount === 0) {
        showToast('Válassz napot, időpontot és jegyeket!', true);
        return;
    }
    if (bookingState.selectedSeats.length !== tCount) {
        showToast(`Pontosan ${tCount} széket válassz!`, true);
        return;
    }
    if (!bookingState.screeningId) {
        showToast('Nincs érvényes vetítési időpont kiválasztva!', true);
        return;
    }

    // Duplán ellenőrzés
    const now       = new Date();
    const todayIso  = toISODate(startOfDay(now));
    const weekEndIso = toISODate(endOfWeek(now));
    if (bookingState.date < todayIso || bookingState.date > weekEndIso) {
        showToast('Csak a mai naptól az aktuális hét végéig tudsz foglalni!', true);
        return;
    }

    const occupiedNow = new Set(getOccupiedForShow(bookingState.movieId, bookingState.date, bookingState.time));
    if (bookingState.selectedSeats.some(s => occupiedNow.has(s))) {
        showToast('Valaki közben lefoglalt egy széket. Válassz másikat!', true);
        bookingState.selectedSeats = [];
        renderSeats();
        updateSummary();
        return;
    }

    // API hívás – összerakjuk a seats tömböt
    // Minden szék kap egy price_id-t: a kiválasztott jegytípusokból FIFO
    const seatsPayload = buildSeatsPayload();

    try {
        document.getElementById('confirmBookingBtn').disabled = true;
        const resp = await apiCreateTicketOrder(bookingState.screeningId, seatsPayload);

        // Helyi cache frissítés
        setOccupiedForShow(bookingState.movieId, bookingState.date, bookingState.time,
            [...occupiedNow, ...bookingState.selectedSeats]);

        // Helyi foglalás mentése (bookings.html-hez)
        const all   = getUserBookings();
        const total = totalPrice();
        all.push({
            id:          resp.ticket_order_id || Date.now(),
            userId:      currentUser.id,
            movieId:     movie.id,
            movieTitle:  movie.title,
            date:        bookingState.date,
            time:        bookingState.time,
            tickets:     tCount,
            ticketTypes: bookingState.ticketCounts,
            seats:       bookingState.selectedSeats.join(', '),
            total,
        });
        setUserBookings(all);

        currentUser.bookings = (currentUser.bookings || 0) + tCount;
        currentUser.points   = (currentUser.points || 0) + Math.round(total / 100);
        setCurrentUser(currentUser);

        showToast('Sikeres foglalás! 🎉');
        const modalEl = document.getElementById('bookingModal');
        const modal   = bootstrap.Modal.getInstance(modalEl);
        if (modal) modal.hide();

    } catch (err) {
        console.error('Foglalás sikertelen:', err);
        showToast(`Foglalás sikertelen: ${err.message}`, true);
        document.getElementById('confirmBookingBtn').disabled = false;
    }
}

/**
 * Összerakja a seats[]-t az API-nak.
 * Minden kiválasztott székhez hozzárendeli a megfelelő price_id-t
 * a ticketCounts arányának megfelelően (FIFO).
 */
function buildSeatsPayload() {
    const queue = [];
    for (const t of TICKET_TYPES) {
        const cnt = bookingState.ticketCounts[t.key] || 0;
        for (let i = 0; i < cnt; i++) queue.push(t.price_id);
    }
    return bookingState.selectedSeats.map((seatLabel, i) => ({
        seat_id:  seatIdFromLabel(seatLabel),
        price_id: queue[i] ?? queue[0],
    }));
}

/**
 * 'A3' -> seat_id keresés a backend screening seat listájából,
 * vagy fallback: numerikus konverzió (sor * 10 + szám).
 */
function seatIdFromLabel(label) {
    // Ha a backend visszaad seat listát a screeningben, keressük meg
    const screenings = currentMovieDetail?.movie?.screenings || [];
    const sc = screenings.find(s => s.screening_id == bookingState.screeningId);
    if (sc?.seats) {
        const row = label[0];
        const col = parseInt(label.slice(1));
        const seat = sc.seats.find(s => s.row_num == (row.charCodeAt(0) - 64) && s.column_num == col);
        if (seat) return seat.seat_id;
    }
    // Fallback: sor betű -> szám, oszlop
    const row = label.charCodeAt(0) - 64;  // A=1, B=2...
    const col = parseInt(label.slice(1));
    return row * 10 + col;  // egyszerű hash
}

// =============================================================
// FOGLALT SZÉKEK – CACHE
// =============================================================

function showKey(movieId, date, time) { return `${movieId}|${date}|${time}`; }

function getOccupiedForShow(movieId, date, time) {
    const store = getOccupiedSeats();
    return store[showKey(movieId, date, time)] || [];
}

function setOccupiedForShow(movieId, date, time, seats) {
    const store = getOccupiedSeats();
    store[showKey(movieId, date, time)] = Array.from(new Set(seats));
    setOccupiedSeats(store);
}

// =============================================================
// DÁTUM SEGÉDEK
// =============================================================

function toISODate(d) {
    return `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
}

function startOfDay(d) { const x = new Date(d); x.setHours(0,0,0,0); return x; }

function endOfWeek(d) {
    const x = new Date(d);
    x.setHours(0,0,0,0);
    const day = x.getDay();
    x.setDate(x.getDate() + (day === 0 ? 0 : 7 - day));
    x.setHours(23,59,59,999);
    return x;
}

function renderQuickDaysRange(startDate, endDate) {
    const wrap = document.getElementById('quickDays');
    if (!wrap) return;
    const start = startOfDay(startDate);
    const end   = startOfDay(endDate);
    const days  = [];
    for (let d = new Date(start); d <= end; d.setDate(d.getDate() + 1)) days.push(new Date(d));

    wrap.innerHTML = days.map(d => {
        const iso   = toISODate(d);
        const label = `${d.getMonth()+1}.${String(d.getDate()).padStart(2,'0')}.`;
        return `<button class="btn btn-outline-gold btn-sm" type="button" data-date="${iso}">${label}</button>`;
    }).join('');

    wrap.querySelectorAll('button[data-date]').forEach(btn => {
        btn.onclick = () => {
            const iso = btn.dataset.date;
            document.getElementById('bookingDate').value = iso;
            bookingState.date = iso;
            bookingState.time = null;
            bookingState.screeningId = null;
            bookingState.selectedSeats = [];
            const screenings = currentMovieDetail?.movie?.screenings || [];
            renderTimesFromScreenings(screenings, iso);
            renderSeats();
            updateSummary();
        };
    });
}
