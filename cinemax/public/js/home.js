// =============================================================
// CINEMAX – HOME.JS  (API-alapú)
// =============================================================

document.addEventListener('DOMContentLoaded', () => {
    // Filmek betöltése API-ból, majd renderelés
    loadMoviesFromAPI(loadFeaturedMovies);
});

function loadFeaturedMovies() {
    const featuredGrid = document.getElementById('featuredMovies');
    if (!featuredGrid) return;

    const favorites = getFavorites();

    if (!movies.length) {
        featuredGrid.innerHTML = `
            <div class="col-12 text-center py-5 text-muted">
                <i class="bi bi-exclamation-circle" style="font-size:3rem;"></i>
                <h4 class="mt-3">Nem sikerült betölteni a filmeket.</h4>
                <p>Ellenőrizd, hogy a backend szerver fut-e.</p>
            </div>`;
        return;
    }

    featuredGrid.innerHTML = movies.slice(0, 3).map(movie => `
        <div class="col-md-4">
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
                    <a href="movies?movie=${movie.id}" class="btn btn-gold w-100 mt-2">
                        <i class="bi bi-ticket-perforated"></i> Jegyvásárlás
                    </a>
                </div>
            </div>
        </div>
    `).join('');
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
    loadFeaturedMovies();
}
