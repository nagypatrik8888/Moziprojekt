document.addEventListener("DOMContentLoaded", loadMovies);

async function loadMovies() {
    try {
        const data = await apiRequest("/api/movies");
        if (data && data.movies) {
            renderMovies(data.movies);
        }
    } catch (error) {
        console.error(error);
    }
}

function renderMovies(movies) {
    const container = document.getElementById("allMovies");
    if (!container) return;

    container.innerHTML = "";

    movies.forEach(movie => {
        const div = document.createElement("div");
        div.innerHTML = `
            <h3>${movie.title}</h3>
            <p>Műfaj: ${movie.genre_name}</p>
            <p>Értékelés: ${movie.rating}</p>
            <a href="movies?id=${movie.movie_id}">Részletek</a>
        `;
        container.appendChild(div);
    });
}
