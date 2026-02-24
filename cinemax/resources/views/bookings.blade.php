<!DOCTYPE html>
<html lang="hu">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Foglalásaim - Cinemax</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Manrope:wght@400;500;600;700&display=swap" rel="stylesheet">

  <!-- Bootstrap + Icons -->
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.1/font/bootstrap-icons.min.css">

  <link rel="stylesheet" href="css/common.css" />
  <link rel="stylesheet" href="css/bookings.css" />
</head>
<body>

<!-- Navbar (egységes) -->
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
        <li class="nav-item"><a class="nav-link" href="movies">Filmek</a></li>
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

<main class="container" style="padding-top: 96px; padding-bottom: 28px;">
  <div class="text-center mb-4">
    <h1 class="section-title">Foglalásaim</h1>
    <p class="text-muted">Ülésenként külön jegy készül (külön QR-rel).</p>
  </div>

  <div id="bookingsList" class="d-flex flex-column gap-3"></div>

  <div class="text-center mt-4" id="emptyState" style="display:none;">
    <div class="p-4 rounded-4" style="background: rgba(255,255,255,0.04); border: 1px solid rgba(255,255,255,0.08);">
      <div class="fw-bold fs-5">Még nincs foglalásod</div>
      <div class="text-muted mt-1">Menj a Filmek oldalra és foglalj egy ülést 🙂</div>
      <a class="btn btn-gold mt-3" href="movies">Ugrás a filmekhez</a>
    </div>
  </div>
</main>

<!-- Toast (a common.js-hez) -->
<div class="position-fixed bottom-0 end-0 p-3" style="z-index: 11">
  <div id="liveToast" class="toast" role="alert">
    <div class="toast-body" id="toastMessage"></div>
  </div>
</div>

<!-- QR lib -->
<script src="https://cdn.jsdelivr.net/npm/qrcodejs@1.0.0/qrcode.min.js"></script>

<script src="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/js/bootstrap.bundle.min.js"></script>
<script src="js/common.js"></script>
<script src="js/bookings.js"></script>
</body>
</html>
