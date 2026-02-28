/* ============================================================
   CINEMAX - BOOKINGS.JS
   Foglalásaim oldal - API-ból tölti a saját jegyeket
============================================================ */

function randomHex(bytes = 12) {
    const arr = new Uint8Array(bytes);
    crypto.getRandomValues(arr);
    return [...arr].map(b => b.toString(16).padStart(2, '0')).join('');
}

function randomRef8() {
    return Math.floor(10000000 + Math.random() * 90000000);
}

function formatDateTime(dateStr, timeStr) {
    if (!dateStr) return '';
    return `${dateStr} • ${timeStr || ''}`.trim();
}

function renderQrInto(el, qrData) {
    el.innerHTML = '';
    if (typeof QRCode !== 'undefined') {
        new QRCode(el, {
            text: qrData,
            width: 140,
            height: 140,
            correctLevel: QRCode.CorrectLevel.M
        });
    } else {
        el.innerHTML = '<div class="text-muted small">QR N/A</div>';
    }
}

function ticketCardHTML(t) {
    const sub = [t.genre, t.duration ? t.duration + ' perc' : '', t.rating ? `⭐ ${t.rating}` : '']
        .filter(Boolean).join(' • ');

    return `
        <div class="ticket">
            <div class="left">
                <img class="poster" src="${t.poster || 'https://via.placeholder.com/120x180?text=Film'}" 
                     alt="${t.movieTitle}" onerror="this.src='https://via.placeholder.com/120x180?text=Film'">
                <div class="left-meta">
                    <div>
                        <div class="title">${t.movieTitle}</div>
                        <div class="sub">${sub}</div>
                    </div>
                    <div class="brand-badge">
                        <div>
                            <div class="badge-top">CINEMAX</div>
                            <div class="badge-sub">Digital Ticket</div>
                        </div>
                    </div>
                </div>
            </div>
            <div class="mid">
                <div class="box">
                    <div class="label"><i class="bi bi-calendar-event"></i> Mikor</div>
                    <div class="value">${formatDateTime(t.screening_date, t.screening_time)}</div>
                </div>
                <div class="box">
                    <div class="label"><i class="bi bi-ticket-perforated"></i> Jegytípus</div>
                    <div class="value">${t.ticket_type || '—'}</div>
                </div>
                <div class="box">
                    <div class="label"><i class="bi bi-cash-coin"></i> Összeg</div>
                    <div class="value price">${t.total_price ? Number(t.total_price).toLocaleString() + ' Ft' : '—'}</div>
                </div>
            </div>
            <div class="right">
                <div class="entry">BELÉPŐ</div>
                <div class="entry-when">${formatDateTime(t.screening_date, t.screening_time)}</div>
                <div class="qr-wrap">
                    <div class="qr-box" id="qr_${t.ticketId}"></div>
                </div>
                <div class="ref">Ref. ${t.ref}</div>
                <div class="hint">Mutasd fel belépésnél</div>
            </div>
        </div>
    `;
}

async function renderBookings() {
    if (typeof updateUserInterface === 'function') updateUserInterface();

    const user = getCurrentUser();
    if (!user) {
        window.location.href = 'login.html';
        return;
    }

    const listEl = document.getElementById('bookingsList');
    const emptyEl = document.getElementById('emptyState');
    if (!listEl) return;

    listEl.innerHTML = `
        <div class="text-center py-5">
            <div class="spinner-border text-warning" role="status"></div>
            <p class="mt-2 text-muted">Jegyek betöltése...</p>
        </div>
    `;

    try {
        const data = await apiGetProfileTicketOrders();
        const orders = data.ticket_orders || [];

        if (!orders.length) {
            listEl.innerHTML = '';
            if (emptyEl) emptyEl.style.display = '';
            return;
        }

        if (emptyEl) emptyEl.style.display = 'none';

        // Minden order egy jegy (a backend seat-enként bonthatna, de jelenleg orderenként 1 rekord)
        const tickets = orders.map(o => ({
            ticketId: `${Date.now()}_${randomHex(4)}`,
            movieTitle: o.movie_name || 'Ismeretlen film',
            genre: o.movie_genre || '',
            duration: o.movie_duration || '',
            rating: o.movie_rating || '',
            poster: '',
            screening_date: o.screening_date || '',
            screening_time: o.screening_time || '',
            total_price: o.total_price,
            ticket_type: o.ticket_type || '',
            ref: randomRef8(),
        }));

        listEl.innerHTML = tickets.map(ticketCardHTML).join('');

        // QR kódok generálása
        tickets.forEach(t => {
            const el = document.getElementById(`qr_${t.ticketId}`);
            if (!el) return;
            renderQrInto(el, JSON.stringify({
                v: 1, ticketId: t.ticketId, movie: t.movieTitle,
                date: t.screening_date, time: t.screening_time, ref: t.ref
            }));
        });

    } catch (err) {
        listEl.innerHTML = `
            <div class="text-center py-5">
                <i class="bi bi-exclamation-triangle text-warning" style="font-size:2rem;"></i>
                <p class="mt-2 text-muted">Nem sikerült betölteni a foglalásokat.</p>
            </div>
        `;
        console.error(err);
    }
}

document.addEventListener('DOMContentLoaded', renderBookings);
window.addEventListener('pageshow', renderBookings);
