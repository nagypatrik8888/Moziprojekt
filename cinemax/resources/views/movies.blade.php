<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Filmek - Cinemax</title>

    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.1/font/bootstrap-icons.min.css">
    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/movies.css">
</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark fixed-top">
    <div class="container-fluid">
        <a class="navbar-brand" href="/">
            <i class="bi bi-film"></i> CINEMAX
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item"><a class="nav-link" href="/">Főoldal</a></li>
                <li class="nav-item"><a class="nav-link active" href="movies">Filmek</a></li>
                <li class="nav-item"><a class="nav-link" href="about">Rólunk</a></li>
                <li class="nav-item ms-3">
                    <a href="login" class="btn btn-outline-gold" id="loginBtn">
                        <i class="bi bi-person"></i> Bejelentkezés
                    </a>
                    <a href="profile" class="btn btn-gold" id="userBtn" style="display:none;">
                        <i class="bi bi-person-circle"></i> <span id="userName"></span>
                    </a>
                </li>
            
          <li class="nav-item" id="navAdminItem" style="display:none;"><a class="nav-link text-white-50 fw-bold" href="admin">ADMIN</a></li>
</ul>
        </div>
    </div>
</nav>

<div class="movies-container">
    <div class="container py-5">
        <h1 class="section-title text-center mb-4">Filmjeink</h1>
        <p class="text-center text-muted mb-5">Válassz a legújabb filmek közül</p>

        <div class="d-flex flex-wrap justify-content-center gap-2 mb-5">
            <button class="filter-btn active" onclick="filterMovies('Összes')">Összes</button>
            <button class="filter-btn" onclick="filterMovies('Akció')">Akció</button>
            <button class="filter-btn" onclick="filterMovies('Vígjáték')">Vígjáték</button>
            <button class="filter-btn" onclick="filterMovies('Horror')">Horror</button>
            <button class="filter-btn" onclick="filterMovies('Sci-Fi')">Sci-Fi</button>
        </div>

        <div class="row g-4" id="allMovies"></div>
    </div>
</div>

<!-- BOOKING MODAL -->
<div class="modal fade" id="bookingModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
        <div class="modal-content bg-dark text-white" style="border:1px solid rgba(255,255,255,0.1); border-radius: 18px; backdrop-filter: blur(20px);">
            <div class="modal-header border-0">
                <div>
                    <h5 class="modal-title fw-bold mb-1" id="bookingMovieTitle">Foglalás</h5>
                    <div class="text-muted small" id="bookingMovieMeta"></div>
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
            </div>

            <div class="modal-body">
                <div class="row g-4">
                    <!-- LEFT -->
                    <div class="col-lg-4">
                        <div class="p-3 rounded-4" style="background: rgba(255,255,255,0.04); border:1px solid rgba(255,255,255,0.06);">
                            <div class="mb-3">
                                <label class="form-label">Válassz napot</label>
                                <input type="date" class="form-control" id="bookingDate">
                                <div class="d-flex flex-wrap gap-2 mt-2" id="quickDays"></div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Válassz időpontot</label>
                                <div class="d-flex flex-wrap gap-2" id="bookingTimes"></div>
                            </div>

                            <div class="mb-3">
                                <label class="form-label">Jegytípusok</label>

                                <div class="ticket-row">
                                    <div class="ticket-left">
                                        <div class="fw-bold">Felnőtt</div>
                                        <div class="small text-muted">2 490 Ft</div>
                                    </div>
                                    <div class="ticket-right">
                                        <button type="button" class="btn btn-outline-gold btn-sm ticket-minus" data-type="adult">−</button>
                                        <span class="ticket-count" id="ticket-adult">0</span>
                                        <button type="button" class="btn btn-outline-gold btn-sm ticket-plus" data-type="adult">+</button>
                                    </div>
                                </div>

                                <div class="ticket-row">
                                    <div class="ticket-left">
                                        <div class="fw-bold">Diák</div>
                                        <div class="small text-muted">1 990 Ft</div>
                                    </div>
                                    <div class="ticket-right">
                                        <button type="button" class="btn btn-outline-gold btn-sm ticket-minus" data-type="student">−</button>
                                        <span class="ticket-count" id="ticket-student">0</span>
                                        <button type="button" class="btn btn-outline-gold btn-sm ticket-plus" data-type="student">+</button>
                                    </div>
                                </div>

                                <div class="ticket-row">
                                    <div class="ticket-left">
                                        <div class="fw-bold">Gyerek</div>
                                        <div class="small text-muted">1 690 Ft</div>
                                    </div>
                                    <div class="ticket-right">
                                        <button type="button" class="btn btn-outline-gold btn-sm ticket-minus" data-type="child">−</button>
                                        <span class="ticket-count" id="ticket-child">0</span>
                                        <button type="button" class="btn btn-outline-gold btn-sm ticket-plus" data-type="child">+</button>
                                    </div>
                                </div>

                                <div class="ticket-row">
                                    <div class="ticket-left">
                                        <div class="fw-bold">Nyugdíjas</div>
                                        <div class="small text-muted">1 790 Ft</div>
                                    </div>
                                    <div class="ticket-right">
                                        <button type="button" class="btn btn-outline-gold btn-sm ticket-minus" data-type="senior">−</button>
                                        <span class="ticket-count" id="ticket-senior">0</span>
                                        <button type="button" class="btn btn-outline-gold btn-sm ticket-plus" data-type="senior">+</button>
                                    </div>
                                </div>

                                <div class="ticket-row">
                                    <div class="ticket-left">
                                        <div class="fw-bold">Fogyatékos</div>
                                        <div class="small text-muted">1 490 Ft</div>
                                    </div>
                                    <div class="ticket-right">
                                        <button type="button" class="btn btn-outline-gold btn-sm ticket-minus" data-type="disabled">−</button>
                                        <span class="ticket-count" id="ticket-disabled">0</span>
                                        <button type="button" class="btn btn-outline-gold btn-sm ticket-plus" data-type="disabled">+</button>
                                    </div>
                                </div>
                            </div>

                            <hr style="border-color: rgba(255,255,255,0.08);">

                            <div class="d-flex justify-content-between align-items-center">
                                <div>
                                    <div class="small text-muted">Jegyek összesen</div>
                                    <div class="fw-bold" id="ticketCount">0 db</div>
                                    <div class="small text-muted mt-1" id="ticketBreakdown"></div>
                                </div>
                                <div class="text-end">
                                    <div class="small text-muted">Összeg</div>
                                    <div class="fw-bold text-warning" id="totalPrice">0 Ft</div>
                                </div>
                            </div>

                            <button class="btn btn-gold w-100 mt-3" id="confirmBookingBtn" disabled>
                                <i class="bi bi-ticket-perforated"></i> Foglalás véglegesítése
                            </button>

                            <div class="mt-3 small text-muted" id="bookingHint"></div>
                        </div>
                    </div>

                    <!-- RIGHT -->
                    <div class="col-lg-8">
                        <div class="p-3 rounded-4" style="background: rgba(255,255,255,0.04); border:1px solid rgba(255,255,255,0.06);">
                            <div class="screen-label mb-3">
                                <div class="screen-pill">VÁSZON</div>
                            </div>

                            <div id="seatsArea" class="text-center"></div>

                            <div class="d-flex flex-wrap justify-content-center gap-3 mt-3 small">
                                <div class="legend-item"><span class="seat-dot seat-free"></span> Szabad</div>
                                <div class="legend-item"><span class="seat-dot seat-selected"></span> Kiválasztva</div>
                                <div class="legend-item"><span class="seat-dot seat-occupied"></span> Foglalt</div>
                            </div>

                            <div class="text-center small text-muted mt-3" id="selectedSeatsText"></div>
                        </div>
                    </div>
                </div>
            </div>

            <div class="modal-footer border-0">
                <button type="button" class="btn btn-outline-gold" data-bs-dismiss="modal">Mégse</button>
            </div>
        </div>
    </div>
</div>
@include('shared.layout.scripts')
<!-- Toast -->
<div class="position-fixed bottom-0 end-0 p-3" style="z-index: 11">
    <div id="liveToast" class="toast" role="alert">
        <div class="toast-body" id="toastMessage"></div>
    </div>
</div>

</body>
</html>
