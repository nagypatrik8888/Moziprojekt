/* ============================================================
   CINEMAX - HOME.JS
   Főoldalon kiemelt filmek betöltése az API-ból
============================================================ */

document.addEventListener('DOMContentLoaded', async function () {
    await loadFeaturedMovies();
});

async function loadFeaturedMovies() {
    const featuredGrid = document.getElementById('featuredMovies');
    if (!featuredGrid) return;

    featuredGrid.innerHTML = `
        <div class="col-12 text-center py-5">
            <div class="spinner-border text-warning" role="status"></div>
            <p class="mt-2 text-muted">Filmek betöltése...</p>
        </div>
    `;

    try {
        const data = await apiGetMovies();
        window.moviesCache = data.movies || [];

        const favorites = getFavorites();
        const featured = window.moviesCache.slice(0, 3);

        if (featured.length === 0) {
            featuredGrid.innerHTML = '<div class="col-12 text-center py-5 text-muted">Nincsenek elérhető filmek.</div>';
            return;
        }

        featuredGrid.innerHTML = featured.map(movie => `
            <div class="col-md-4">
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
                        <a href="movies.html?movie=${movie.movie_id}" class="btn btn-gold w-100 mt-2">
                            <i class="bi bi-ticket-perforated"></i> Jegyvásárlás
                        </a>
                    </div>
                </div>
            </div>
        `).join('');
    } catch (err) {
        featuredGrid.innerHTML = `
            <div class="col-12 text-center py-5">
                <i class="bi bi-exclamation-triangle text-warning" style="font-size:2rem;"></i>
                <p class="mt-2 text-muted">Nem sikerült betölteni a filmeket. Ellenőrizd, hogy fut-e a backend szerver.</p>
            </div>
        `;
        console.error('Filmek betöltési hiba:', err);
    }
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
