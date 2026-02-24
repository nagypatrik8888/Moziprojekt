async function createBooking(screening_id, seat_id, price_id) {
    const formData = new FormData();
    formData.append("screening_id", screening_id);
    formData.append("seats[0][seat_id]", seat_id);
    formData.append("seats[0][price_id]", price_id);

    try {
        const data = await apiRequest("/api/ticket_orders", "POST", formData);

        if (data.ticket_order_id) {
            alert("Sikeres foglalás!");
            window.location.href = "profile";
        }
    } catch (error) {
        console.error(error);
    }
}
