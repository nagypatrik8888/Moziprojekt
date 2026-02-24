// ===== CARD SWITCH =====
function showRegister() {
    loginCard.style.display = 'none';
    registerCard.style.display = 'block';
}

function showLogin() {
    registerCard.style.display = 'none';
    loginCard.style.display = 'block';
}

// ===== PASSWORD STRENGTH =====
function passwordStrength(pwd) {
    let s = 0;
    if (pwd.length >= 8) s++;
    if (/[A-Z]/.test(pwd)) s++;
    if (/[0-9]/.test(pwd)) s++;
    if (/[^A-Za-z0-9]/.test(pwd)) s++;
    return s;
}

loginPassword.addEventListener('input', () => {
    const s = passwordStrength(loginPassword.value);
    strengthFill.className = 'strength-fill';

    if (!loginPassword.value) {
        strengthFill.style.width = '0%';
        strengthText.textContent = 'Jelszó erőssége';
        return;
    }

    if (s <= 1) {
        strengthFill.style.width = '33%';
        strengthFill.classList.add('strength-weak');
        strengthText.textContent = 'Gyenge';
    } else if (s === 2) {
        strengthFill.style.width = '66%';
        strengthFill.classList.add('strength-medium');
        strengthText.textContent = 'Közepes';
    } else {
        strengthFill.style.width = '100%';
        strengthFill.classList.add('strength-strong');
        strengthText.textContent = 'Erős';
    }
});

// ===== REGISTER STRENGTH =====
regPassword.addEventListener('input', () => {
    const s = passwordStrength(regPassword.value);
    regStrengthFill.className = 'strength-fill';

    if (!regPassword.value) {
        regStrengthFill.style.width = '0%';
        regStrengthText.textContent = 'Jelszó erőssége';
        return;
    }

    if (s <= 1) {
        regStrengthFill.style.width = '33%';
        regStrengthFill.classList.add('strength-weak');
        regStrengthText.textContent = 'Gyenge';
    } else if (s === 2) {
        regStrengthFill.style.width = '66%';
        regStrengthFill.classList.add('strength-medium');
        regStrengthText.textContent = 'Közepes';
    } else {
        regStrengthFill.style.width = '100%';
        regStrengthFill.classList.add('strength-strong');
        regStrengthText.textContent = 'Erős';
    }
});

// ===== REGISTER =====
registerForm.addEventListener('submit', e => {
    e.preventDefault();

    if (regPassword.value !== regPassword2.value) {
        showToast('A jelszavak nem egyeznek!', true);
        return;
    }

    if (passwordStrength(regPassword.value) < 2) {
        showToast('Túl gyenge jelszó!', true);
        return;
    }

    const users = JSON.parse(localStorage.getItem('users') || '[]');

    if (users.some(u => u.email === regEmail.value)) {
        showToast('Ez az email már létezik!', true);
        return;
    }

    const user = {
        id: Date.now(),
        name: regName.value,
        email: regEmail.value,
        bookings: 0,
        points: 0
    };

    users.push({ ...user, password: regPassword.value });
    localStorage.setItem('users', JSON.stringify(users));

    setCurrentUser(user);
    showToast('Sikeres regisztráció!');

    setTimeout(() => location.href = 'index.html', 1000);
});

// ===== LOGIN =====
loginForm.addEventListener('submit', e => {
    e.preventDefault();


    // ADMIN LOGIN (nem kell regisztráció):
    // Email: admin@cinema.hu
    // Jelszó: admin123 (elfogadja: "admin 123" is)
    const adminEmail = (loginEmail.value || '').trim().toLowerCase();
    const adminPwdNorm = (loginPassword.value || '').trim().toLowerCase().replace(/\s+/g, '');
    if (adminEmail === 'admin@cinema.hu' && adminPwdNorm === 'admin123') {
        const adminUser = {
            id: 'admin',
            name: 'Admin',
            email: 'admin@cinema.hu',
            bookings: 0,
            points: 0,
            isAdmin: true
        };
        setCurrentUser(adminUser);
        showToast('Sikeres admin bejelentkezés!');
        setTimeout(() => location.href = 'admin.html', 400);
        return;
    }
    const users = JSON.parse(localStorage.getItem('users') || '[]');
    const found = users.find(
        u => u.email === loginEmail.value && u.password === loginPassword.value
    );

    if (!found) {
        showToast('Hibás email vagy jelszó!', true);
        return;
    }

    
    // Admin flag (demo)
    if ((found.email || "").toLowerCase().trim() === "admin@cinema.hu") {
        found.isAdmin = true;
    }
setCurrentUser(found);
    showToast('Sikeres bejelentkezés!');
    setTimeout(() => location.href = 'index.html', 800);
});
