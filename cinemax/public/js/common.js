const API_BASE = "http://localhost:8888";

async function apiRequest(endpoint, method = "GET", body = null) {
    const token = localStorage.getItem("authToken");

    const options = {
        method,
        headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ' + token
        }
    };

    if (body) {
        options.body = body;
    }

    const response = await fetch(API_BASE + endpoint, options);

    if (response.status === 401) {
        localStorage.removeItem("authToken");
        window.location.href = "login";
        return;
    }

    if (!response.ok) {
        throw new Error("API error");
    }

    return response.json();
}

function logout() {
    localStorage.removeItem("authToken");
    window.location.href = "login";
}
