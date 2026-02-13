// Bookings oldal funkciók - CINEMA TICKET VIEW
document.addEventListener('DOMContentLoaded', function () {
    const currentUser = getCurrentUser();

    if (!currentUser) {
        showToast('Kérlek először jelentkezz be!', true);
        setTimeout(() => {
            window.location.href = 'login.html';
        }, 1500);
        return;
    }

    loadBookings();
});

function loadBookings() {
    const currentUser = getCurrentUser();
    if (!currentUser) return;

    const allBookings = getUserBookings();
    const myBookings = allBookings.filter(b => b.userId === currentUser.id);
    const bookingsList = document.getElementById('bookingsList');
    if (!bookingsList) return;

    if (myBookings.length === 0) {
        bookingsList.innerHTML = `
            <div class="no-bookings">
                <i class="bi bi-film no-bookings-icon"></i>
                <h2>Még nincs foglalásod</h2>
                <p class="text-muted mb-4">Válassz filmet és foglalj jegyet most!</p>
                <a href="movies.html" class="btn btn-gold">
                    <i class="bi bi-search"></i> Filmek böngészése
                </a>
            </div>
        `;
        return;
    }

    // legfrissebb legyen felül
    const sorted = [...myBookings].sort((a, b) => (b.id || 0) - (a.id || 0));

    const labelMap = {
        adult: 'Felnőtt',
        student: 'Diák',
        child: 'Gyerek',
        senior: 'Nyugdíjas',
        disabled: 'Fogyatékos'
    };

    bookingsList.innerHTML = sorted.map(booking => {
        const movie = (typeof movies !== 'undefined')
            ? movies.find(m => m.id === booking.movieId || m.title === booking.movieTitle)
            : null;

        const poster = movie?.poster || 'https://via.placeholder.com/400x600?text=CINEMAX';
        const meta = [
            movie?.category ? movie.category : null,
            movie?.duration ? movie.duration : null,
            movie?.rating ? `⭐ ${movie.rating}` : null
        ].filter(Boolean).join(' • ');

        const types = booking.ticketTypes || {};
        const typeText = Object.entries(types)
            .filter(([, v]) => Number(v) > 0)
            .map(([k, v]) => `${labelMap[k] || k}: ${v}`)
            .join(' • ');

        const totalFt = Number(booking.total || 0).toLocaleString();
        const seatText = String(booking.seats || '').trim();
        const seatsArr = seatText ? seatText.split(',').map(s => s.trim()).filter(Boolean) : [];

        // "Row" meg "Seat" kiemelés (ha pl. A5, B10)
        const seatPills = seatsArr.length
            ? seatsArr.map(s => `<span class="seat-pill">${s}</span>`).join('')
            : `<span class="seat-pill seat-pill-empty">-</span>`;

        const whenText = `${booking.date} • ${booking.time}`;

        return `
            <div class="ticket-card">
                <div class="ticket-left">
                    <img class="ticket-poster" src="${poster}" alt="${booking.movieTitle}">
                    <div class="ticket-brand">
                        <div class="ticket-brand-title"><i class="bi bi-film"></i> CINEMAX</div>
                        <div class="ticket-brand-sub">Digital Ticket</div>
                    </div>
                </div>

                <div class="ticket-mid">
                    <div class="ticket-title">${booking.movieTitle}</div>
                    <div class="ticket-meta">${meta || 'Mozijegy foglalás'}</div>

                    <div class="ticket-grid">
                        <div class="ticket-field">
                            <div class="ticket-label"><i class="bi bi-calendar3"></i> Mikor</div>
                            <div class="ticket-value">${whenText}</div>
                        </div>

                        <div class="ticket-field">
                            <div class="ticket-label"><i class="bi bi-ticket-perforated"></i> Jegyek</div>
                            <div class="ticket-value">${booking.tickets} db</div>
                            ${typeText ? `<div class="ticket-sub">${typeText}</div>` : ``}
                        </div>

                        <div class="ticket-field">
                            <div class="ticket-label"><i class="bi bi-pin-map"></i> Ülések</div>
                            <div class="ticket-seats">${seatPills}</div>
                        </div>

                        <div class="ticket-field">
                            <div class="ticket-label"><i class="bi bi-cash-coin"></i> Összeg</div>
                            <div class="ticket-value ticket-price">${totalFt} Ft</div>
                            <div class="ticket-sub">Kapunyitás: 30 perccel előtte</div>
                        </div>
                    </div>
                </div>

                <div class="ticket-right">
                    <div class="ticket-stub">
                        <div class="stub-title">BELÉPŐ</div>
                        <div class="stub-when">${booking.date}<br>${booking.time}</div>

                        <div class="stub-qr" aria-label="QR kód helye"></div>

                        <div class="stub-small">
                            Ref: <strong>${String(booking.id || '').slice(-8) || '—'}</strong><br>
                            Mutasd fel belépésnél
                        </div>
                    </div>
                </div>
            </div>
        `;
    }).join('');
}
