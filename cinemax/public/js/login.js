async function login(email, password,_token) {
    const response = await fetch("http://localhost:8888/login", {
        method: "POST",
        headers: {
            "Content-type": 'application/json',
            'Accept': 'application/json'
        },
        body: JSON.stringify({email:email,password:password,_token:_token})
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
        const email = form.querySelector("#loginEmail").value;
        const password = form.querySelector("#loginPassword").value;
        const _token = form.querySelector("[name='_token']").value;
        login(email, password,_token);
    });
});
