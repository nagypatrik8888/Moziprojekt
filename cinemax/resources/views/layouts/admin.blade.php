<!DOCTYPE html>
<html lang="hu">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Admin - Cinemax</title>

  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Bebas+Neue&family=Manrope:wght@400;500;600;700&display=swap" rel="stylesheet">

  <!-- Bootstrap + Icons -->
  <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.1/font/bootstrap-icons.min.css">

  <link rel="stylesheet" href="/css/common.css" />
  <link rel="stylesheet" href="/css/admin.css" />
</head>
<body>

  <!-- NAV -->
  <nav class="navbar navbar-expand-lg navbar-dark bg-cmx-nav sticky-top">
    <div class="container-fluid px-3">
      <a class="navbar-brand d-flex align-items-center gap-2 cmx-brand" href="/">
        <span class="border border-warning rounded-2 d-inline-flex align-items-center justify-content-center" style="width:28px;height:28px;">▦</span>
        <span>CINEMAX</span>
      </a>

      <button class="navbar-toggler border-warning" type="button" data-bs-toggle="collapse" data-bs-target="#navMain">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="navMain">
        <ul class="navbar-nav mx-auto gap-lg-3">
          <li class="nav-item"><a class="nav-link text-white-50 fw-bold" href="/">FŐOLDAL</a></li>
          <li class="nav-item"><a class="nav-link text-white-50 fw-bold" href="/movies">FILMEK</a></li>
          <li class="nav-item"><a class="nav-link text-white-50 fw-bold" href="/bookings">FOGLALÁSOK</a></li>
          <li class="nav-item" id="navAdminItem"><a class="nav-link text-white fw-bold" href="/admin">ADMIN</a></li>
        </ul>

        <div class="d-flex gap-2 align-items-center">
          <button class="btn btn-cmx-outline px-3 py-2" data-cmx-logout title="Kijelentkezés">
            <i class="bi bi-box-arrow-right"></i>
          </button>
          <a class="btn cmx-pill px-3 py-2 d-inline-flex align-items-center gap-2" id="navUserLink" href="/login">
            <i class="bi bi-person-circle"></i>
            <span id="navUsername">BEJELENTKEZÉS</span>
          </a>
        </div>
      </div>
    </div>
  </nav>

  <main class="container py-4">
            @yield('content')
  </main>

@include('shared.layout.scripts')
<script src="/js/admin.js"></script>


</body>
</html>
