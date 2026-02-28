<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cinemax - Élmények, amik megmaradnak</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.1/font/bootstrap-icons.min.css">
    <!-- Közös CSS -->
    <link rel="stylesheet" href="css/common.css">
    <!-- Oldal specifikus CSS -->
    <link rel="stylesheet" href="css/home.css">
</head>
<body>

<!-- Navbar -->
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
                <li class="nav-item">
                    <a class="nav-link active" href="/">Főoldal</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="movies">Filmek</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="about">Rólunk</a>
                </li>
                <li class="nav-item ms-3">
                    @if(auth()->check())
                       <a href="profile" class="btn btn-gold" id="userBtn">
                        <i class="bi bi-person-circle"></i> <span id="userName">{{auth()->check() ? auth()->user()->name:null}}</span>
                    </a>
                    @else
                        <a href="login" class="btn btn-outline-gold" id="loginBtn">
                            <i class="bi bi-person"></i> Bejelentkezés
                        </a>
                    @endif
                </li>
            
          <li class="nav-item" id="navAdminItem" style="display:none;"><a class="nav-link text-white-50 fw-bold" href="admin">ADMIN</a></li>
</ul>
        </div>
    </div>
</nav>

<!-- Hero Section -->
<section class="hero-section">
    <div class="hero-content text-center">
        <div class="hero-icon">🎬</div>
        <h1 class="hero-title">CINEMAX</h1>
        <p class="hero-subtitle">Élmények, amik megmaradnak</p>

        <!-- CSAK EGY GOMB -->
        <div class="mt-4">
            <a href="movies" class="btn btn-gold btn-lg">
                🎥 Filmek megtekintése
            </a>
        </div>
    </div>
</section>

<!-- ÉRDEKESSÉG SZEKCIÓ -->
<section class="py-5" style="background:#0f172a;">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-10 text-center">
                <h2 class="section-title mb-4"> Tudtad?</h2>
                <p class="text-muted fs-5">
                    Az első nyilvános filmvetítést 1895-ben tartották Párizsban,  
                    és kevesebb mint <strong>50 másodpercig</strong> tartott.
                </p>
                <p class="text-muted fs-5">
                    Ma egy átlagos mozifilm több mint <strong>120 perc</strong> –  
                    de az élmény ugyanaz maradt: kikapcsol, beszippant, emlékezetes.
                </p>
                <p class="mt-4 fst-italic text-secondary">
                    „A mozi nem csak film. Élmény.” 🍿
                </p>
            </div>
        </div>
    </div>
</section>

<!-- Toast -->
<div class="position-fixed bottom-0 end-0 p-3" style="z-index: 11">
    <div id="liveToast" class="toast" role="alert">
        <div class="toast-body" id="toastMessage"></div>
    </div>
</div>
@include('shared.layout.scripts')


</body>
</html>
