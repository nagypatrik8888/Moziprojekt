/* =========================================================
   CINEMAX - BOOKINGS
   - A projekt eredeti foglalás struktúrájából dolgozik (common.js userBookings)
   - 1 foglalás (több seat) -> több külön ticket kártya
   - QR mindig random nonce -> minden jegy egyedi
========================================================= */

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

function parseSeats(seatsStr) {
  return String(seatsStr || '')
    .split(',')
    .map(s => s.trim().toUpperCase())
    .filter(Boolean);
}

function makeQrPayload(ticket) {
  return JSON.stringify({
    v: 1,
    ticketId: ticket.ticketId,
    bookingId: ticket.bookingId,
    userId: ticket.userId,
    movieId: ticket.movieId,
    movieTitle: ticket.movieTitle,
    date: ticket.date,
    time: ticket.time,
    seat: ticket.seat,
    ref: ticket.ref,
    nonce: ticket.nonce
  });
}

function renderQrInto(el, qrData) {
  el.innerHTML = '';
  // QRCode lib a bookings.html-ben van betöltve
  new QRCode(el, {
    text: qrData,
    width: 140,
    height: 140,
    correctLevel: QRCode.CorrectLevel.M
  });
}

function getMovieMeta(movieId) {
  // a common.js-ben van a movies tömb
  try {
    if (typeof movies !== 'undefined' && Array.isArray(movies)) {
      return movies.find(m => String(m.id) === String(movieId)) || null;
    }
  } catch {}
  return null;
}

function ticketCardHTML(t) {
  const meta = getMovieMeta(t.movieId);
  const poster = meta?.poster || '';
  const genre = meta?.category || '';
  const duration = meta?.duration || '';
  const rating = (meta?.rating != null) ? meta.rating : '';
  const sub = [genre, duration, rating ? `⭐ ${rating}` : ''].filter(Boolean).join(' • ');

  return `
    <div class="ticket">
      <div class="left">
        <img class="poster" src="${poster}" alt="${t.movieTitle}">
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
          <div class="value">${formatDateTime(t.date, t.time)}</div>
        </div>
        <div class="box">
          <div class="label"><i class="bi bi-grid-3x3-gap"></i> Ülés</div>
          <div class="seat-pill">${t.seat}</div>
        </div>
        <div class="box">
          <div class="label"><i class="bi bi-ticket-perforated"></i> Jegy</div>
          <div class="value">1 db</div>
          <div class="sub">Külön belépő</div>
        </div>
        <div class="box">
          <div class="label"><i class="bi bi-cash-coin"></i> Összeg</div>
          <div class="value price">${t.totalFt} Ft</div>
        </div>
      </div>

      <div class="right">
        <div class="entry">BELÉPŐ</div>
        <div class="entry-when">${formatDateTime(t.date, t.time)}</div>

        <div class="qr-wrap">
          <div class="qr-box" id="qr_${t.ticketId}"></div>
        </div>

        <div class="ref">Ref. ${t.ref}</div>
        <div class="hint">Mutasd fel belépésnél</div>
      </div>
    </div>
  `;
}

function renderBookings() {
  if (typeof updateUserInterface === 'function') updateUserInterface();

  const user = (typeof getCurrentUser === 'function') ? getCurrentUser() : null;
  if (!user) {
    window.location.href = 'login.html';
    return;
  }

  const all = (typeof getUserBookings === 'function') ? getUserBookings() : [];
  const my = (all || []).filter(b => b.userId === user.id);

  const listEl = document.getElementById('bookingsList');
  const emptyEl = document.getElementById('emptyState');
  if (!listEl) return;

  if (!my.length) {
    listEl.innerHTML = '';
    if (emptyEl) emptyEl.style.display = '';
    return;
  }

  if (emptyEl) emptyEl.style.display = 'none';

  // Ticket per seat
  const tickets = [];
  my
    .slice()
    .sort((a, b) => (String(b.date) + String(b.time)).localeCompare(String(a.date) + String(a.time)))
    .forEach(b => {
      const seats = parseSeats(b.seats);
      seats.forEach(seat => {
        tickets.push({
          ticketId: `${b.id}_${seat}_${randomHex(4)}`,
          bookingId: b.id,
          userId: b.userId,
          movieId: b.movieId,
          movieTitle: b.movieTitle,
          date: b.date,
          time: b.time,
          seat,
          // b.total: foglalás összár. ülésenként elosztjuk, hogy legyen értelme a ticketen.
          totalFt: Math.round((Number(b.total) || 0) / Math.max(1, seats.length)),
          ref: randomRef8(),
          nonce: randomHex(12)
        });
      });
    });

  listEl.innerHTML = tickets.map(ticketCardHTML).join('');

  // QR render
  tickets.forEach(t => {
    const el = document.getElementById(`qr_${t.ticketId}`);
    if (!el) return;
    renderQrInto(el, makeQrPayload(t));
  });
}

document.addEventListener('DOMContentLoaded', renderBookings);
window.addEventListener('pageshow', renderBookings);
