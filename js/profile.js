// Profile oldal funkciók
document.addEventListener('DOMContentLoaded', function() {
    const currentUser = getCurrentUser();
    
    if (!currentUser) {
        showToast('Kérlek először jelentkezz be!', true);
        setTimeout(() => {
            window.location.href = 'login.html';
        }, 1500);
        return;
    }
    
    loadProfile();
});

function loadProfile() {
    const currentUser = getCurrentUser();
    if (!currentUser) return;
    
    document.getElementById('profileName').textContent = currentUser.name;
    document.getElementById('profileEmail').textContent = currentUser.email;
    document.getElementById('profilePhone').textContent = currentUser.phone || '-';
    document.getElementById('totalBookings').textContent = currentUser.bookings || 0;
    document.getElementById('totalPoints').textContent = currentUser.points || 0;
}