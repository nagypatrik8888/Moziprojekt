document.addEventListener("DOMContentLoaded", loadOrders);

async function loadOrders() {
    try {
        const data = await apiRequest("/api/profile/ticket_orders");

        const container = document.getElementById("ordersContainer");
        if (!container || !data.ticket_orders) return;

        container.innerHTML = "";

        data.ticket_orders.forEach(order => {
            const div = document.createElement("div");
            div.innerHTML = `
                <p>Order ID: ${order.ticket_order_id}</p>
                <p>Összeg: ${order.total_price} Ft</p>
            `;
            container.appendChild(div);
        });

    } catch (error) {
        console.error(error);
    }
}
