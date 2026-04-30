/* ============================================================
   CINEMAX - LOGIN.JS
   Bejelentkezés és regisztráció - Laravel Fortify backend API
============================================================ */

// ===== DOM ELEMEK =====
const loginCard = document.getElementById('loginCard');
const registerCard = document.getElementById('registerCard');
const loginForm = document.getElementById('loginForm');
const registerForm = document.getElementById('registerForm');
const loginEmail = document.getElementById('loginEmail');
const loginPassword = document.getElementById('loginPassword');
const strengthFill = document.getElementById('strengthFill');
const strengthText = document.getElementById('strengthText');
const regName = document.getElementById('regName');
const regEmail = document.getElementById('regEmail');
const regPassword = document.getElementById('regPassword');
const regPassword2 = document.getElementById('regPassword2');
const regStrengthFill = document.getElementById('regStrengthFill');
const regStrengthText = document.getElementById('regStrengthText');

// ===== KÁRTYAVÁLTÁS =====
function showRegister() {
    if (loginCard) loginCard.style.display = 'none';
    if (registerCard) registerCard.style.display = 'block';
}

function showLogin() {
    if (registerCard) registerCard.style.display = 'none';
    if (loginCard) loginCard.style.display = 'block';
}

// ===== JELSZÓ ERŐSSÉGE =====
function passwordStrength(pwd) {
    let s = 0;
    if (pwd.length >= 8) s++;
    if (/[A-Z]/.test(pwd)) s++;
    if (/[0-9]/.test(pwd)) s++;
    if (/[^A-Za-z0-9]/.test(pwd)) s++;
    return s;
}

function updateStrengthUI(pwd, fill, text) {
    fill.className = 'strength-fill';
    if (!pwd) {
        fill.style.width = '0%';
        text.textContent = 'Jelszó erőssége';
        return;
    }
    const s = passwordStrength(pwd);
    if (s <= 1) {
        fill.style.width = '33%';
        fill.classList.add('strength-weak');
        text.textContent = 'Gyenge';
    } else if (s === 2) {
        fill.style.width = '66%';
        fill.classList.add('strength-medium');
        text.textContent = 'Közepes';
    } else {
        fill.style.width = '100%';
        fill.classList.add('strength-strong');
        text.textContent = 'Erős';
    }
}

// A bejelentkezés formon nem mutatunk erősség csíkot — csak a regisztrációnál.
if (regPassword && regStrengthFill) {
    regPassword.addEventListener('input', () => updateStrengthUI(regPassword.value, regStrengthFill, regStrengthText));
}

// ===== REGISZTRÁCIÓ =====
if (registerForm) {
    registerForm.addEventListener('submit', async e => {
        e.preventDefault();

        if (regPassword.value !== regPassword2.value) {
            showToast('A jelszavak nem egyeznek!', true);
            return;
        }
        if (passwordStrength(regPassword.value) < 2) {
            showToast('Túl gyenge jelszó! (nagybetű, szám, speciális karakter)', true);
            return;
        }

        const submitBtn = registerForm.querySelector('button[type="submit"]');
        if (submitBtn) { submitBtn.disabled = true; submitBtn.textContent = 'Regisztrálás...'; }

        try {
            const res = await apiRegister(
                regName.value,
                regEmail.value,
                regPassword.value,
                regPassword2.value
            );

            if (res.ok || res.status === 201 || res.redirected) {
                // Sikeres regisztráció után a Laravel automatikusan beléptet
                // Lekérjük a bejelentkezett user adatait
                const userRes = await apiGet('/api/user');
                if (userRes.ok) {
                    const userData = await userRes.json();
                    setCurrentUser(userData);
                }
                showToast('Sikeres regisztráció! 🎉');
                setTimeout(() => window.location.href = '/', 800);
            } else {
                const data = await res.json().catch(() => ({}));
                const msg = extractErrorMessage(data) || 'Regisztrációs hiba.';
                showToast(msg, true);
            }
        } catch (err) {
            showToast('Nem sikerült kapcsolódni a szerverhez.', true);
            console.error(err);
        } finally {
            if (submitBtn) { submitBtn.disabled = false; submitBtn.textContent = 'Regisztráció'; }
        }
    });
}

// ===== BEJELENTKEZÉS =====
if (loginForm) {
    loginForm.addEventListener('submit', async e => {
        e.preventDefault();

        const submitBtn = loginForm.querySelector('button[type="submit"]');
        if (submitBtn) { submitBtn.disabled = true; submitBtn.textContent = 'Bejelentkezés...'; }

        try {
            const res = await apiLogin(loginEmail.value, loginPassword.value);

            if (res.ok || res.status === 204 || res.redirected) {
                // Lekérjük a bejelentkezett user adatait
                const userRes = await apiGet('/api/user');
                if (userRes.ok) {
                    const userData = await userRes.json();
                    setCurrentUser(userData);
                    showToast('Sikeres bejelentkezés! 👋');
                    setTimeout(() => window.location.href = '/', 600);
                } else {
                    // Lehet hogy visszairányított - próbáljuk meg az index-et
                    showToast('Sikeres bejelentkezés!');
                    setTimeout(() => window.location.href = '/', 600);
                }
            } else {
                const data = await res.json().catch(() => ({}));
                const msg = extractErrorMessage(data) || 'Hibás email vagy jelszó.';
                showToast(msg, true);
            }
        } catch (err) {
            showToast('Nem sikerült kapcsolódni a szerverhez.', true);
            console.error(err);
        } finally {
            if (submitBtn) { submitBtn.disabled = false; submitBtn.textContent = 'Bejelentkezés'; }
        }
    });
}

// ===== HIBAÜZENET KINYERÉSE =====
function extractErrorMessage(data) {
    if (!data) return null;
    if (typeof data.message === 'string') return data.message;
    if (data.errors) {
        const firstKey = Object.keys(data.errors)[0];
        if (firstKey && Array.isArray(data.errors[firstKey])) {
            return data.errors[firstKey][0];
        }
    }
    return null;
}
