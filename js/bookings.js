// Bookings oldal funkciók
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

    const labelMap = {
        adult: 'Felnőtt',
        student: 'Diák',
        child: 'Gyerek',
        senior: 'Nyugdíjas',
        disabled: 'Fogyatékos'
    };

    bookingsList.innerHTML = myBookings
        .map(booking => {
            const types = booking.ticketTypes || {};
            const typeText = Object.entries(types)
                .filter(([, v]) => Number(v) > 0)
                .map(([k, v]) => `${labelMap[k] || k}: ${v}`)
                .join(' • ');

            const totalFt = Number(booking.total || 0).toLocaleString();

            return `
                <div class="booking-card">
                    <h4 class="section-title h5 mb-3">${booking.movieTitle}</h4>

                    <div class="row">
                        <div class="col-md-6">
                            <p class="mb-2">
                                <i class="bi bi-calendar3"></i>
                                <strong>Időpont:</strong> ${booking.date} - ${booking.time}
                            </p>

                            <p class="mb-1">
                                <i class="bi bi-ticket-perforated"></i>
                                <strong>Jegyek:</strong> ${booking.tickets} db
                            </p>

                            ${typeText ? `
                                <p class="mb-2 small text-muted">
                                    <strong>Bontás:</strong> ${typeText}
                                </p>
                            ` : ``}
                        </div>

                        <div class="col-md-6">
                            <p class="mb-2">
                                <i class="bi bi-pin-map"></i>
                                <strong>Ülések:</strong> ${booking.seats}
                            </p>

                            <p class="text-warning mb-0">
                                <i class="bi bi-cash-coin"></i>
                                <strong>Összeg:</strong> ${totalFt} Ft
                            </p>
                        </div>
                    </div>
                </div>
            `;
        })
        .join('');
}
