// Közös adatok és segédfüggvények
const movies = [
  {
    id: 1,
    title: "Avatar (2009)",
    category: "Sci-Fi",
    duration: "162 perc",
    rating: 7.8,
    poster: "https://image.tmdb.org/t/p/original/6EiRUJpuoeQPghrs3YNktfnqOVh.jpg",
    description: "A James Cameron által rendezett epikus sci-fi kaland Pandora világában.",
    showtimes: ["13:30", "16:45", "20:00"]
  },
  {
    id: 2,
    title: "Avengers: Endgame",
    category: "Akció",
    duration: "181 perc",
    rating: 8.4,
    poster: "https://image.tmdb.org/t/p/original/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg",
    description: "A Bosszúállók utolsó csatája Thanos ellen.",
    showtimes: ["14:00", "17:30", "21:00"]
  },
  {
    id: 3,
    title: "Star Wars: The Force Awakens",
    category: "Sci-Fi",
    duration: "138 perc",
    rating: 7.8,
    poster: "https://image.tmdb.org/t/p/original/wqnLdwVXoBjKibFRR5U3y0aDUhs.jpg",
    description: "A Star Wars saga új fejezete, ahol új hősök csatlakoznak a harcba.",
    showtimes: ["12:30", "15:45", "19:15"]
  },
  {
    id: 4,
    title: "Jurassic World",
    category: "Akció",
    duration: "124 perc",
    rating: 7.0,
    poster: "https://image.tmdb.org/t/p/original/rhr4y79GpxQF9IsfJItRXVaoGs4.jpg",
    description: "Dinoszauruszok újra életre kelnek egy élő tematikus parkban.",
    showtimes: ["13:45", "17:00", "20:30"]
  },
  {
    id: 5,
    title: "Spider-Man: No Way Home",
    category: "Akció",
    duration: "148 perc",
    rating: 8.3,
    poster: "https://image.tmdb.org/t/p/original/rjbNpRMoVvqHmhmksbokcyCr7wn.jpg",
    description: "Spider-Man visszatér, hogy szembenézzen a multiverzum fenyegetéseivel.",
    showtimes: ["14:30", "18:00", "21:30"]
  },
  {
    id: 6,
    title: "Zootopia",
    category: "Vígjáték",
    duration: "108 perc",
    rating: 8.0,
    poster: "https://image.tmdb.org/t/p/original/hlK0e0wAQ3VLuJcsfIYPvb4JVud.jpg",
    description: "Egy nyúl és egy róka kalandjai egy hatalmas állatvárosban.",
    showtimes: ["11:45", "14:15", "17:00"]
  }
];

// Állapot tárolása localStorage-ban
function getCurrentUser() {
    // Canonical user key: currentUser
    const userStr = localStorage.getItem('currentUser');
    if (userStr) {
        try { return JSON.parse(userStr); } catch { /* ignore */ }
    }

    // Compatibility: ha korábban más kulcsot használtál
    const alt = localStorage.getItem('cinemax_user');
    if (alt) {
        try { return JSON.parse(alt); } catch { /* ignore */ }
    }

    return null;
}

function setCurrentUser(user) {
    if (user) {
        localStorage.setItem('currentUser', JSON.stringify(user));
        // Compatibility
        localStorage.setItem('cinemax_user', JSON.stringify(user));
    } else {
        localStorage.removeItem('currentUser');
        localStorage.removeItem('cinemax_user');
    }
}

function getFavorites() {
    const favStr = localStorage.getItem('favorites');
    return favStr ? JSON.parse(favStr) : [];
}

function setFavorites(favorites) {
    localStorage.setItem('favorites', JSON.stringify(favorites));
}

function getUserBookings() {
    const bookingsStr = localStorage.getItem('userBookings');
    return bookingsStr ? JSON.parse(bookingsStr) : [];
}

function setUserBookings(bookings) {
    localStorage.setItem('userBookings', JSON.stringify(bookings));
}

function getOccupiedSeats() {
    const seatsStr = localStorage.getItem('occupiedSeats');
    return seatsStr ? JSON.parse(seatsStr) : {};
}

function setOccupiedSeats(seats) {
    localStorage.setItem('occupiedSeats', JSON.stringify(seats));
}

// Toast üzenetek
function showToast(message, isError = false) {
    const toast = document.getElementById('liveToast');
    if (!toast) return;
    
    const toastEl = new bootstrap.Toast(toast);
    const toastMessage = document.getElementById('toastMessage');
    if (toastMessage) {
        toastMessage.textContent = message;
    }
    
    if (isError) {
        toast.classList.add('error');
    } else {
        toast.classList.remove('error');
    }
    
    toastEl.show();
}

// Felhasználói felület frissítése
function updateUserInterface() {
    const loginBtn = document.getElementById('loginBtn');
    const userBtn = document.getElementById('userBtn');
    const bookingsNav = document.getElementById('bookingsNav'); // <-- ÚJ
    const currentUser = getCurrentUser();

    // Login / Profile gombok
    if (loginBtn && userBtn) {
        if (currentUser) {
            loginBtn.style.display = 'none';
            userBtn.style.display = 'inline-block';
            const userName = document.getElementById('userName');
            if (userName) {
                const n = (currentUser.name || currentUser.username || currentUser.email || '').trim();
                userName.textContent = n ? n.split(' ')[0] : '';
            }
        } else {
            loginBtn.style.display = 'inline-block';
            userBtn.style.display = 'none';
        }
    }

    // Foglalások menü (csak bejelentkezve)
    if (bookingsNav) {
        bookingsNav.style.display = currentUser ? 'list-item' : 'none';
    }
}


// Kijelentkezés
function logout() {
    // minden user kulcs törlése
    setCurrentUser(null);

    // egyéb auth kulcsok takarítása (ha valahol használtad)
    try {
        localStorage.removeItem('cinemax_token');
        localStorage.removeItem('authToken');
        localStorage.removeItem('token');
        localStorage.removeItem('access_token');
        localStorage.removeItem('loggedInUser');
    } catch {}

    // UI azonnal friss
    updateUserInterface();

    // cross-tab + back-button frissítés jelzése
    try { localStorage.setItem('cmx_logout_broadcast', String(Date.now())); } catch {}

    showToast('Sikeresen kijelentkeztél!');
    // rövid delay a toast miatt
    setTimeout(() => {
        window.location.href = 'index.html';
    }, 400);
}


// Oldal betöltésekor
document.addEventListener('DOMContentLoaded', function() {
    updateUserInterface();
});

// FONTOS: vissza gomb (BFCache) / tab váltás / másik tab logout -> UI frissüljön
window.addEventListener('pageshow', () => updateUserInterface());
document.addEventListener('visibilitychange', () => {
    if (document.visibilityState === 'visible') updateUserInterface();
});
window.addEventListener('storage', (e) => {
    if (e.key === 'currentUser' || e.key === 'cmx_logout_broadcast' || e.key === 'cinemax_user') {
        updateUserInterface();
    }
});