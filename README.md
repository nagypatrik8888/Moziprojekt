# 🎬 CinemaCore – Mozi Jegyértékesítő Rendszer (Adatbázis)

Egy komplex MySQL adatbázis egy modern mozirendszerhez, amely kezeli a filmeket, vetítéseket, ülésfoglalásokat, jegyértékesítést és a büfé webshopot.  
A rendszer stored procedure-ökre és tranzakciókra épül, biztosítva az adatintegritást és az üzleti logika DB-szintű érvényesítését.

---

## 👥 Csapat

| Szerepkör | Név |
|---|---|
| Backend fejlesztő | Nagy Patrik |
| Adatbázis tervezés | Schiffni Máté |
| Frontend / integráció | Mozsgai Dávid |

---

## 🛠 Technológiák

**Adatbázis**
- MySQL 8.0+
- InnoDB engine
- UTF8MB4 karakterkészlet
- Foreign Key + Unique constraint védelem
- Stored Procedure alapú üzleti logika

**Eszközök**
- phpMyAdmin 5.2+
- MAMP (Apache + MySQL)
- Git / GitHub

---

## 📂 Adatbázis struktúra

├── films # Filmek
├── genres # Műfajok
├── languages # Nyelvek
│
├── rooms # Mozitermek
├── seats # Ülések termenként
├── screening # Vetítések (film + terem + idő)
│
├── prices # Jegytípusok (adult, student, stb.)
├── ticket_orders # Jegyrendelések
├── ticket_order_seats # Jegy–ülés kapcsolótábla
│
├── products # Büfé termékek
├── orders # Webshop rendelések
├── order_product # Rendelés–termék kapcsoló
│
└── users # Felhasználók
---

## 🗄 Főbb táblák

### 🎥 Film és vetítés
- `films` – film adatok, soft delete támogatással
- `genres` – műfajok
- `languages` – többnyelvű támogatás
- `screening` – vetítések dátummal és kezdési idővel

### 🪑 Termek és ülések
- `rooms` – mozitermek
- `seats` – ülések teremhez rendelve

### 🎟 Jegyek és foglalás
- `prices` – jegytípusok és árak
- `ticket_orders` – egy jegyvásárlás (több ülés)
- `ticket_order_seats` – konkrét lefoglalt ülések

✔ Egy szék **egy adott vetítésen csak egyszer foglalható**  
✔ `(screening_id, seat_id)` UNIQUE constraint védi

### 🛒 Büfé webshop
- `products` – büfé termékek
- `orders` – webshop rendelések
- `order_product` – N:M kapcsolat rendelések és termékek között

### 👤 Felhasználók
- `users` – felhasználók (role, is_active, soft delete)

---

## ⚙️ Stored Procedure-ek

Az adatbázis működésének alapját stored procedure-ök adják.

### Fontosabb eljárások
- `add_ticket_order_v2` – több székes jegyvásárlás tranzakcióval
- `get_reserved_seats_by_screening` – foglalt ülések lekérdezése
- `get_user_bookings` – felhasználó jegyei
- `get_daily_revenue` – napi bevétel
- CRUD eljárások minden fő entitáshoz

✔ Tranzakciókezelés  
✔ Hibakezelés `SIGNAL SQLSTATE '45000'` segítségével  
✔ Automatikus ár- és összegszámítás

---

## 🔐 Adatintegritás

- Foreign key védelem minden kapcsolaton
- UNIQUE constraint a dupla foglalás ellen
- Trigger védi a negatív `total_price` értékeket
- Soft delete:
  - `users`
  - `films`
  - `orders`

---

## 🚀 Telepítés (MAMP – Windows)

### 1. Előfeltételek
- MAMP telepítve
- MySQL 8.0+
- phpMyAdmin

### 2. Adatbázis létrehozása
1. Nyisd meg: `http://localhost:8888/phpMyAdmin`
2. Hozz létre egy `webshop` nevű adatbázist
3. Karakterkészlet: `utf8mb4_hungarian_ci`

### 3. Importálás
Importáld az SQL dumpot: database/webshop.sql


### 4. Alapértelmezett kapcsolat (MAMP)
Host: localhost
Port: 8889
User: root
Password: root
Database: webshop

---

## 📊 Példa lekérdezések

### Foglalt székek egy vetítésen
```sql
SELECT se.row_num, se.column_num
FROM ticket_order_seats tos
JOIN seats se ON se.id = tos.seat_id
WHERE tos.screening_id = 1;
---
### Felhasználó jegyei
CALL get_user_bookings(1);
---
### Napi bevétel
CALL get_daily_revenue('2026-02-23');
