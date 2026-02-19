# Webshop (mozi jegy + büfé) – MySQL adatbázis

Ez a repository egy **MySQL 8.0** adatbázis dumpot tartalmaz (`phpMyAdmin 5.2.1`), amely egy mozijegy-foglalás és büfé termék rendelés alapfunkcióit modellezi.

A dump létrehozása: **2026-02-18**  
Szerver: **MySQL 8.0.40**  
Környezet: phpMyAdmin SQL export

---

## Fő funkciók

- Filmek kezelése (CRUD + soft delete)
- Műfajok (genres) kezelése
- Nyelvek (languages) listája
- Vetítések (screening) kezelése (film + terem + dátum + kezdés)
- Termek (rooms) és ülőhelyek (seats)
- Jegyvásárlások (ticket_orders) ülés foglalással
- Büfé termékek (products) és rendelések (orders) + kapcsolótábla (order_product)
- Tárolt eljárások (stored procedures) a tipikus műveletekhez
- Trigger védelem a ticket_orders total_price mezőre

---

## Séma áttekintés

### Táblák

- `users` – felhasználók (role, aktív/inaktív, saltolt SHA2 hash jelszó)
- `films` – filmek (műfaj, nyelv, értékelés, soft delete mezők)
- `genres` – műfajok
- `languages` – nyelvek (unique `code`)
- `rooms` – termek
- `seats` – ülőhelyek (teremhez kötve)
- `screening` – vetítések (film + terem + dátum + kezdés)
- `prices` – jegyár típusok (adult/student/child/…)
- `ticket_orders` – jegyvásárlások (user + ticket price + screening + seat)
- `ticket_order_seats` – többüléses modellezéshez előkészített tábla (composite PK)
- `products` – büfé termékek
- `orders` – büfé rendelés (összeggel)
- `order_product` – rendelés–termék kapcsolótábla (mennyiséggel)

---

## Kapcsolatok (FK-k)

- `films.genre_id` → `genres.id`
- `films.language_id` → `languages.id` *(opcionális, nullable)*
- `orders.user_id` → `users.id`
- `order_product.order_id` → `orders.id`
- `order_product.product_id` → `products.id`
- `screening.film_id` → `films.id`
- `screening.room_id` → `rooms.id`
- `seats.room_id` → `rooms.id`
- `ticket_orders.user_id` → `users.id`
- `ticket_orders.ticket_id` → `prices.id`
- `ticket_orders.seat_id` → `seats.id` *(nullable)*
- `ticket_order_seats.ticket_order_id` → `ticket_orders.id`
- `ticket_order_seats.seat_id` → `seats.id`
- `ticket_order_seats.screening_id` → `screening.id`

---
