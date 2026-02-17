// =========================================================
// CINEMAX - PROFILE (a projekt eredeti auth rendszerével)
// - currentUser (common.js) az egyetlen forrás
// - logout: common.js logout()
// =========================================================

function fmtNextBooking(bookings) {
  const now = Date.now();
  const next = (bookings || [])
    .map(b => {
      const iso = `${b.date || ''}T${(b.time || '00:00')}:00`;
      const t = new Date(iso).getTime();
      return { b, t };
    })
    .filter(x => Number.isFinite(x.t) && x.t > now)
    .sort((a, c) => a.t - c.t)[0]?.b;

  if (!next) return 'Nincs';
  return `${next.date} • ${next.time} (${next.movieTitle || ''})`;
}

function initProfile() {
  // common.js biztosítja
  const user = (typeof getCurrentUser === 'function') ? getCurrentUser() : null;
  if (!user) {
    window.location.href = 'login.html';
    return;
  }

  const allBookings = (typeof getUserBookings === 'function') ? getUserBookings() : [];
  const myBookings = (allBookings || []).filter(b => b.userId === user.id);
  const favs = (typeof getFavorites === 'function') ? getFavorites() : [];

  const name = (user.name || user.username || user.email || '').trim();
  const email = (user.email || '').trim();
  const points = user.points || 0;

  const usernameEl = document.getElementById('username');
  const emailEl = document.getElementById('email');
  if (usernameEl) usernameEl.textContent = name;
  if (emailEl) emailEl.textContent = email;

  const bookingCountEl = document.getElementById('bookingCount');
  const favCountEl = document.getElementById('favCount');
  const pointsEl = document.getElementById('points');

  const totalTickets = myBookings.reduce((sum, b) => sum + (Number(b.tickets) || 0), 0);

  if (bookingCountEl) bookingCountEl.textContent = String(totalTickets);
  if (favCountEl) favCountEl.textContent = String(Array.isArray(favs) ? favs.length : 0);
  if (pointsEl) pointsEl.textContent = String(points);

  const sumBookingsEl = document.getElementById('sumBookings');
  const sumNextEl = document.getElementById('sumNext');
  if (sumBookingsEl) sumBookingsEl.textContent = String(totalTickets);
  if (sumNextEl) sumNextEl.textContent = fmtNextBooking(myBookings);

  // badge csak dizájn
  const badge = document.getElementById('badge');
  if (badge) badge.textContent = 'SILVER';

  // logout gomb
  const logoutBtn = document.getElementById('logoutBtn');
  if (logoutBtn) {
    logoutBtn.addEventListener('click', (e) => {
      e.preventDefault();
      if (typeof logout === 'function') logout();
      else window.location.href = 'index.html';
    });
  }

  // navbar frissítés (common.js)
  if (typeof updateUserInterface === 'function') updateUserInterface();
}

document.addEventListener('DOMContentLoaded', initProfile);
