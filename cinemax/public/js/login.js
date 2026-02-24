async function login(email, password) {
    const formData = new FormData();
    formData.append("email", email);
    formData.append("password", password);

    const response = await fetch("http://localhost:8888/login", {
        method: "POST",
        body: formData
    });

    if (!response.ok) {
        alert("Hibás bejelentkezés!");
        return;
    }

    const data = await response.json();
    localStorage.setItem("authToken", data.token);
    window.location.href = "/";
}

document.addEventListener("DOMContentLoaded", () => {
    const form = document.querySelector("form");
    if (!form) return;

    form.addEventListener("submit", (e) => {
        e.preventDefault();
        const email = form.querySelector("[name='email']").value;
        const password = form.querySelector("[name='password']").value;
        login(email, password);
    });
});
