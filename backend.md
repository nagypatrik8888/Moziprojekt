## 1) Mi van most az adatbázisban (cinema szempontból)

**Filmek**

* `films` (film alapadatok)
* `genres` + `film_genres` (több műfaj támogatott)
* `languages` (nyelv)
* `film_metadata` (kulcs-érték extra adatok)

**Vetítés / terem / szék**

* `screening` (film_id, start_time, room_id) **→ nincs dátum**
* `rooms`
* `seats` (room_id, row_num, column_num)

**Jegyek / foglalás**

* `prices` (type + price) → ez lesz a **ticketType** megfeleltetése
* `ticket_orders` (user_id, ticket_id, quantity, total_price, screening_id, seat_id + timestamps)
* `ticket_order_seats` (ticket_order_id, seat_id, screening_id) → több szék/foglalás támogatása

**Felhasználók**

* `users` (firstname, lastname, email, password, phone, role, is_active, deleted_at)

**Ami webshop jellegű és a frontendhez nem kell**

* `orders`, `products`, `order_product`
* `admin_users` (kivéve ha admin felület is lesz, de frontendben nem szerepel)

---

## 2) Új backend terv – DB-hez igazítva (REST endpointok)

### 2.1 Kategóriák (műfajok)

**GET `/api/v1/genres`**

* Vissza: `genres` lista

**GET `/api/v1/films?genreId=...&page=...`**

* Szűrés műfajra: `film_genres` join

> Frontend “kategória gombjai” = `genres`.

---

### 2.2 Film lista + film kártya adatok

**GET `/api/v1/films`**
Query:

* `genreId` (optional)
* `q` (optional, cím keresés)
* `page`, `pageSize`
* `activeOnly` (optional, default true → `films.is_active=1 AND is_deleted=0`)

Vissza (kártya):

* `id, title, release_date, rating, description (rövidítve), genre(s), language, posterUrl?`

**GET `/api/v1/films/{id}`**

* teljes filmadat

✅ DB ok: film alapadatok megvannak
⚠️ **Hiány / eltérés a frontendhez:** a frontendben “kép” van, de a `films` táblában nincs `poster_url`. Ezt **csak** `film_metadata`-ből lehetne adni (pl. `meta_key='poster_url'`), vagy hiányzik egy oszlop.

---

### 2.3 Vetítések (nap + időpont választás)

Frontend: **napot és időpontot** választ.

DB: `screening.start_time` csak **idő**, nincs **dátum**.

**GET `/api/v1/films/{filmId}/screenings`**
Query:

* `date` (optional) – frontendhez kellene
* `from`, `to` (optional)

Vissza:

* `screeningId, start_time, room_id, date`

⚠️ **KRITIKUS HIÁNY:** a `screening` táblából **nem lehet napot (dátumot) választani**, mert nincs `screening_date` / `start_datetime`.
**Ez a frontend flow jelenlegi DB-vel nem implementálható rendesen.**

**Javasolt DB módosítás (minimál):**

* `ALTER TABLE screening ADD COLUMN screening_date DATE NOT NULL;`

  * vagy még jobb: `start_datetime DATETIME NOT NULL` (és akkor `start_time` felesleges)

---

### 2.4 Székek megjelenítése + foglaltság

**GET `/api/v1/screenings/{screeningId}/seats`**
Vissza:

* terem adatok: `rooms`
* székek: `seats` (row_num, column_num)
* státusz: foglalt-e

Foglaltság lekérdezés:

* `ticket_order_seats` WHERE `screening_id = ?`
* (vagy `ticket_orders.seat_id` ha csak 1 ülés, de nálatok van multi-seat tábla → azt érdemes használni)

✅ DB ok: terem + szék kiosztás megoldható
⚠️ **Eltérés:** frontend “székek számozása” → DB-ben `row_num` + `column_num` van, nincs “A10” label. Backend generálhatja: pl. row 1 = A, col 10 = “A10”.

---

### 2.5 Foglalás véglegesítése

Frontend: ticketType + seat választás, véglegesítés.

DB-ben:

* ticket type/ár = `prices` (type, price)
* rendelés/foglalás = `ticket_orders`
* székek = `ticket_order_seats`

**POST `/api/v1/bookings`** (auth kell)
Body:

```json
{
  "screeningId": 123,
  "ticketType": "student",
  "seatIds": [11,12]
}
```

Backend logika DB-hez:

1. `prices`-ből kikeresni `ticket_id` by `type`
2. ellenőrizni, hogy a seatIds mind a screening tereméhez tartozik (`screening.room_id` + `seats.room_id`)
3. ütközés: van-e már `ticket_order_seats` ugyanerre a screeningre és seatre → ha igen: 409
4. insert `ticket_orders`:

   * `user_id`, `ticket_id`, `quantity = seatIds.length`, `total_price = quantity * prices.price`, `screening_id`
   * `seat_id` mező: **redundáns** multi-seat mellett (lásd hiányok/eltérések)
5. insert `ticket_order_seats` sorok a seatIds-ra

✅ DB ok: multi-seat foglalás támogatott
⚠️ **Eltérés / furcsaság:** `ticket_orders.seat_id` mező ütközik a multi-seat modellel. Dönteni kell:

* vagy csak “első seat” kerül ide (legacy), és az igazság a `ticket_order_seats`
* vagy a `seat_id`-t el kéne hagyni (de most adott a séma)

---

### 2.6 Profil – foglalásaim

**GET `/api/v1/me/bookings`** (auth kell)

Összejoinolva:

* `ticket_orders` + `prices` + `screening` + `films` (+ `ticket_order_seats` + `seats`)
  Vissza:
* film adatok + vetítés időpont (⚠️ dátum hiány) + jegytípus + székek

✅ DB ok: listázható
⚠️ **KRITIKUS:** vetítésnél csak idő lesz, nap nincs.

---

### 2.7 Kedvencek

Frontend: filmkártyán “kedvencekhez adás” gomb.

DB-ben **nincs** ilyen tábla.

⚠️ **HIÁNYZÓ DB STRUKTÚRA:**

* `favorites` tábla (user-film kapcsolat)

Minimál javaslat:

```sql
CREATE TABLE favorites (
  user_id INT NOT NULL,
  film_id INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, film_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (film_id) REFERENCES films(id)
);
```

Endpointok:

* `GET /api/v1/me/favorites`
* `POST /api/v1/me/favorites { filmId }`
* `DELETE /api/v1/me/favorites/{filmId}`

---

### 2.8 Auth (reg/login)

DB: `users` megvan, de:

⚠️ **BIZTONSÁGI/IMPLEMENTÁCIÓS ELTÉRÉS:**

* `password char(64)` + `salt char(16)` → ez tipikusan saját hash (pl. sha256) és nem modern `password_hash()`.
* vizsgában oké, de backendben egyértelműsíteni kell, hogy:

  * `password = sha256(salt + rawPassword)` (vagy fordítva)
  * vagy migrálni bcrypt/argon2-re (de sémát nem bántva nehéz)

Endpointok:

* `POST /api/v1/auth/register`
* `POST /api/v1/auth/login`
* `GET /api/v1/me`

---

## 3) Hiányok / eltérések listája (frontend vs DB)

### A) Kritikus (frontend nem hozható ki rendesen)

1. **Vetítés nap (date) hiányzik**

* Frontend: nap + időpont választás
* DB: `screening.start_time` csak idő, **nincs date/datetime**
* **Megoldás:** `screening_date DATE` vagy `start_datetime DATETIME`

### B) Frontend funkcióhoz hiányzó tábla

2. **Kedvencek**

* Nincs `favorites` / `user_favorites`
* **Megoldás:** `favorites(user_id, film_id, created_at)`

### C) Adatmező eltérés / nincs explicit

3. **Film kép/poster**

* Frontend kártyán van kép
* `films`-ben nincs `poster_url`
* **Megoldás:** `film_metadata`-ban tárolni `poster_url` meta_key-vel, vagy oszlop hozzáadása

4. **Szék megjelenítési “label”**

* DB: `row_num`, `column_num`
* Frontend: számozás/azonosító
* **Megoldás:** backend generálja pl. `A1`, `B7`

5. **TicketType enum megfeleltetés**

* Frontend: felnőtt/diák/gyerek/nyugdíjas/fogyatékos
* DB: `prices.type` szabad szöveg
* **Megoldás:** rögzített értékek (konvenció), vagy `GET /ticket-types` mapping

### D) Modell furcsaság

6. `ticket_orders.seat_id` vs `ticket_order_seats`

* dupla tárolás
* **Megoldás:** a backendben deklarálni, hogy multi-seat esetén a `ticket_order_seats` az igazság, a `seat_id` opcionális/legacy.

---

## 4) “Új terv” összefoglaló táblázat (DB → API mapping)

* **Filmek**: `films` (+ `film_metadata` poster) → `GET /films`, `GET /films/{id}`
* **Kategóriák**: `genres` (+ `film_genres`) → `GET /genres`, `GET /films?genreId=`
* **Vetítések**: `screening` → `GET /films/{id}/screenings` (**date hiány**)
* **Termek**: `rooms` → screeninghez join
* **Székek**: `seats` + foglaltság `ticket_order_seats` → `GET /screenings/{id}/seats`
* **Foglalás**: `ticket_orders` + `ticket_order_seats` + `prices` → `POST /bookings`, `GET /me/bookings`
* **Auth**: `users` → `POST /auth/register`, `POST /auth/login`, `GET /me`
* **Kedvencek**: **hiányzó** `favorites` → `GET/POST/DELETE /me/favorites`