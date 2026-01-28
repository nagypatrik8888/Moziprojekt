// Közös adatok és segédfüggvények
const movies = [
    {
        id: 1,
        title: 'Gladiator II',
        category: 'Akció',
        rating: 8.5,
        duration: '148 perc',
        description: 'Lucius folytatja Maximus küzdelmét a római arénában.',
        poster: 'https://images.unsplash.com/photo-1533613220915-609f661a6fe1?w=400&h=600&fit=crop',
        showtimes: ['14:00', '17:30', '20:45']
    },
    {
        id: 2,
        title: 'Dune: Part Two',
        category: 'Sci-Fi',
        rating: 9.2,
        duration: '166 perc',
        description: 'Paul Atreides legendás utazása folytatódik.',
        poster: 'https://images.unsplash.com/photo-1534447677768-be436bb09401?w=400&h=600&fit=crop',
        showtimes: ['13:00', '17:00', '20:30']
    },
    {
        id: 3,
        title: 'Deadpool & Wolverine',
        category: 'Vígjáték',
        rating: 9.0,
        duration: '127 perc',
        description: 'Wade Wilson és Logan legendás találkozása.',
        poster: 'https://images.unsplash.com/photo-1611604548018-d56bbd85d681?w=400&h=600&fit=crop',
        showtimes: ['13:30', '16:45', '20:00']
    },
    {
        id: 4,
        title: 'The First Omen',
        category: 'Horror',
        rating: 7.9,
        duration: '119 perc',
        description: 'Egy fiatal apáca felfedezi a sötét összeesküvést.',
        poster: 'https://images.unsplash.com/photo-1603457979-b5ddeb5dc2d8?w=400&h=600&fit=crop',
        showtimes: ['19:00', '21:45', '23:30']
    },
    {
        id: 5,
        title: 'Furiosa',
        category: 'Akció',
        rating: 8.8,
        duration: '148 perc',
        description: 'Mad Max univerzumában játszódó eredettörténet.',
        poster: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=600&fit=crop',
        showtimes: ['15:00', '18:00', '21:00']
    },
    {
        id: 6,
        title: 'Challengers',
        category: 'Vígjáték',
        rating: 7.8,
        duration: '131 perc',
        description: 'Egy tenisz-szerelmi háromszög története.',
        poster: 'https://images.unsplash.com/photo-1622547748225-3fc4abd2cca0?w=400&h=600&fit=crop',
        showtimes: ['14:30', '17:45', '20:30']
    }
];

// Állapot tárolása localStorage-ban
function getCurrentUser() {
    const userStr = localStorage.getItem('currentUser');
    return userStr ? JSON.parse(userStr) : null;
}

function setCurrentUser(user) {
    if (user) {
        localStorage.setItem('currentUser', JSON.stringify(user));
    } else {
        localStorage.removeItem('currentUser');
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
            if (userName) userName.textContent = currentUser.name.split(' ')[0];
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
    setCurrentUser(null);
    updateUserInterface(); // <-- EZ A LÉNYEG: azonnal eltűnik a Foglalások is
    showToast('Sikeresen kijelentkeztél!');
    setTimeout(() => {
        window.location.href = 'index.html';
    }, 1000);
}


// Oldal betöltésekor
document.addEventListener('DOMContentLoaded', function() {
    updateUserInterface();
});