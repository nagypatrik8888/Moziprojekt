<!DOCTYPE html>
<html lang="hu">
<head>
    <meta charset="UTF-8">
    <title>Bejelentkezés / Regisztráció - Cinemax</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap/5.3.2/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.11.1/font/bootstrap-icons.min.css" rel="stylesheet">

    <link rel="stylesheet" href="css/common.css">
    <link rel="stylesheet" href="css/login.css">
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark fixed-top">
    <div class="container-fluid">
        <a class="navbar-brand" href="/">
            <i class="bi bi-film"></i> CINEMAX
        </a>
    </div>
</nav>

<div class="login-container">

    <!-- LOGIN -->
    <div class="login-card" id="loginCard">
        <div class="text-center">
            <i class="bi bi-person-circle login-icon"></i>
            <h1 class="login-title">Bejelentkezés</h1>
        </div>

        <form id="loginForm">
            @csrf
            <div class="mb-3">
                <label>Email cím</label>
                <input type="email" id="loginEmail" class="form-control" required>
            </div>

            <div class="mb-3">
                <label>Jelszó</label>
                <input type="password" id="loginPassword" class="form-control" required>
            </div>

            <button class="btn btn-gold w-100">Bejelentkezés</button>
        </form>

        <p class="text-center mt-3 mb-0">
            Még nincs fiókod?
            <a href="#" onclick="showRegister()" class="text-warning">Regisztrálj!</a>
        </p>
    </div>

    <!-- REGISTER -->
    <div class="login-card" id="registerCard" style="display:none;">
        <div class="text-center">
            <i class="bi bi-person-plus login-icon"></i>
            <h1 class="login-title">Regisztráció</h1>
        </div>

        <form id="registerForm">
            <div class="mb-3">
                <label>Teljes név</label>
                <input type="text" id="regName" class="form-control" required>
            </div>

            <div class="mb-3">
                <label>Email cím</label>
                <input type="email" id="regEmail" class="form-control" required>
            </div>

            <div class="mb-3">
                <label>Jelszó</label>
                <input type="password" id="regPassword" class="form-control" required>

                <div class="password-strength mt-2">
                    <div class="strength-bar">
                        <div class="strength-fill" id="regStrengthFill"></div>
                    </div>
                    <small id="regStrengthText">Jelszó erőssége</small>
                </div>
            </div>

            <div class="mb-3">
                <label>Jelszó megerősítése</label>
                <input type="password" id="regPassword2" class="form-control" required>
            </div>

            <button class="btn btn-gold w-100">Regisztráció</button>
        </form>

        <p class="text-center mt-3 mb-0">
            Már van fiókod?
            <a href="#" onclick="showLogin()" class="text-warning">Bejelentkezés</a>
        </p>
    </div>

</div>

<div class="position-fixed bottom-0 end-0 p-3">
    <div id="liveToast" class="toast">
        <div class="toast-body" id="toastMessage"></div>
    </div>
</div>
@include('shared.layout.scripts')

</body>
</html>
