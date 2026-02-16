-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: localhost:8889
-- Létrehozás ideje: 2026. Feb 16. 18:58
-- Kiszolgáló verziója: 8.0.40
-- PHP verzió: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `webshop`
--

DELIMITER $$
--
-- Eljárások
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_film` (IN `p_title` VARCHAR(200), IN `p_duration` INT, IN `p_release` DATE, IN `p_description` TEXT, IN `p_genre_id` INT, IN `p_language` VARCHAR(100), IN `p_rating` INT)   BEGIN
  INSERT INTO films (title, duration_min, release_date, description, genre_id, language, rating, created_at, updated_at)
  VALUES (p_title, p_duration, p_release, p_description, p_genre_id, p_language, p_rating, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_genre` (IN `p_name` VARCHAR(100), IN `p_description` TEXT)   BEGIN
INSERT INTO genres(name, description, updated_at, created_at)
VALUES(p_name, p_description, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_order` (IN `p_user_id` INT, IN `p_total` DECIMAL(10,0))   BEGIN
-- Validáció: user létezik-e?
IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id) THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'User not found';
END IF;
-- Validáció: total pozitív?
IF p_total <= 0 THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Total must be positive';
END IF;
INSERT INTO orders (user_id, total, created_at, updated_at)
VALUES (p_user_id, p_total, NOW(), NOW());
SELECT LAST_INSERT_ID() AS order_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_order_product` (IN `p_order_id` INT, IN `p_product_id` INT, IN `p_quantity` INT)   BEGIN
  INSERT INTO order_product (order_id, product_id, quantity, updated_at, created_at)
  VALUES (p_order_id, p_product_id, p_quantity, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_order_with_products` (IN `p_user_id` INT, IN `p_products` JSON)   BEGIN
    DECLARE v_order_id INT DEFAULT 0;
    DECLARE v_total DECIMAL(10,2) DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Error creating order';
    END;

    START TRANSACTION;

    INSERT INTO orders (user_id, total, created_at, updated_at)
    VALUES (p_user_id, 0, NOW(), NOW());

    SET v_order_id = LAST_INSERT_ID();

    -- (itt majd később jöhet a JSON feldolgozás)

    UPDATE orders
    SET total = v_total
    WHERE id = v_order_id;

    COMMIT;

    SELECT v_order_id AS order_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_price` (IN `p_type` VARCHAR(50), IN `p_price` INT)   BEGIN
  INSERT INTO prices (type, price, created_at, updated_at)
  VALUES (p_type, p_price, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_product` (IN `p_name` VARCHAR(100), IN `p_price` DECIMAL(10,0))   BEGIN
  INSERT INTO products (name, price, created_at, updated_at)
  VALUES (p_name, p_price, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_room` (IN `p_screen_size` VARCHAR(100), IN `p_sound_system` VARCHAR(100))   BEGIN
INSERT INTO rooms(screen_size, sound_system, created_at, updated_at)
VALUES(p_screen_size, p_sound_system, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_screening` (IN `p_film_id` INT, IN `p_start` DATETIME)   BEGIN
  INSERT INTO screening (film_id, start_time, created_at, updated_at)
  VALUES (p_film_id, p_start, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_seat` (IN `p_column_num` INT, IN `p_row_num` INT, IN `p_room_id` INT)   BEGIN
INSERT INTO seats(column_num, row_num, room_id, created_at, updated_at)
VALUES(p_column_num, p_row_num, p_room_id, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_ticket` (IN `p_screening_id` INT, IN `p_user_id` INT, IN `p_price` DECIMAL(10,0))   BEGIN
  INSERT INTO tickets (screening_id, user_id, price, created_at, updated_at)
  VALUES (p_screening_id, p_user_id, p_price, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_ticket_order` (IN `p_user_id` INT, IN `p_ticket_id` INT, IN `p_quantity` INT, IN `p_screening_id` INT)   BEGIN
DECLARE v_price DECIMAL(10,2);
DECLARE v_total DECIMAL(10,2);
-- Ár lekérése
SELECT price INTO v_price
FROM prices
WHERE id = p_price_id;
IF v_price IS NULL THEN
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Price not found';
END IF;
SET v_total = v_price * p_quantity;
INSERT INTO ticket_orders(user_id, ticket_id, quantity, total_price, created_at, updated_at, screening_id)
VALUES(p_user_id, p_price_id, p_quantity, v_total, NOW(), NOW(), p_screening_id);
SELECT LAST_INSERT_ID() AS ticket_order_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_user` (IN `p_firstname` VARCHAR(50), IN `p_lastname` VARCHAR(50), IN `p_email` VARCHAR(100), IN `p_phone` TEXT, IN `p_password` VARCHAR(255), IN `p_role` VARCHAR(10))   BEGIN
  DECLARE v_salt CHAR(16);
  DECLARE v_hash CHAR(64);

  SET v_salt = SUBSTRING(REPLACE(UUID(),
'-'
,
''), 1, 16);

  SET v_hash = SHA2(CONCAT(p_password, v_salt), 256);

  INSERT INTO users (firstname, lastname, email, phone, password, salt, updated_at, created_at, role)
  VALUES (p_firstname, p_lastname, p_email, p_phone, v_hash, v_salt, NOW(), NOW(), p_role);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_film` (IN `p_id` INT)   BEGIN
UPDATE films
SET
is_deleted = TRUE,
updated_at = NOW()
WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_genre` (IN `p_id` INT)   BEGIN
DELETE FROM genres WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_order` (IN `p_id` INT)   BEGIN
  DELETE FROM orders WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_order_product` (IN `p_id` INT)   BEGIN
  DELETE FROM order_product WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_price` (IN `p_id` INT)   BEGIN
  DELETE FROM prices WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_product` (IN `p_id` INT)   BEGIN
  DELETE FROM products WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_room` (IN `p_id` INT)   BEGIN
DELETE FROM rooms WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_screening` (IN `p_id` INT)   BEGIN
  DELETE FROM screening WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_seat` (IN `p_id` INT)   BEGIN
DELETE FROM seats
WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_ticket` (IN `p_id` INT)   BEGIN
  DELETE FROM ticket_orders WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_user` (IN `p_id` INT)   BEGIN
	INSERT INTO deleted_users (user_id, firstname, lastname, email, phone, password, salt, deleted_at)
    SELECT id, firstname, lastname, email, phone, password, salt, NOW()
    FROM users
    WHERE id = p_id;

    DELETE FROM users
    WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_by_user` (IN `p_id` INT)   BEGIN
-- Orders
SELECT 'order' AS type, o.
*
FROM orders o
WHERE o.user_id = p_id
UNION ALL
-- Ticket orders
SELECT 'ticket_order' AS type, t.
*
FROM ticket_orders t
WHERE t.user_id = p_id
ORDER BY created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_prices` ()   BEGIN
    SELECT id, type, price, updated_at
    FROM prices
    ORDER BY id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_seat` (IN `p_id` INT)   BEGIN
SELECT *
FROM seats
ORDER BY row_num, column_num;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_seats` ()   BEGIN
    SELECT 
        id,
        room_id,
        row_num,
        column_num
    FROM seats
    ORDER BY room_id, row_num, column_num;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_daily_revenue` (IN `p_date` DATE)   BEGIN
    SELECT 
        (SELECT IFNULL(SUM(price), 0) 
         FROM ticket_orders 
         WHERE DATE(purchased_at) = p_date) 
        + 
        (SELECT IFNULL(SUM(total), 0) 
         FROM orders 
         WHERE DATE(created_at) = p_date)
        AS total_revenue;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_film` (IN `p_id` INT)   BEGIN
  SELECT * FROM films WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_film_all` ()   BEGIN
SELECT *
FROM films
WHERE is_deleted = FALSE
ORDER BY release_date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_order` (IN `p_id` INT)   BEGIN
  SELECT * FROM orders WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_order_all` ()   BEGIN
  SELECT * FROM orders ORDER BY id DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_order_by_user` (IN `p_id` INT)   BEGIN
SELECT *
FROM orders
WHERE orders.user_id = users.id AND id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_order_product` (IN `p_id` INT)   BEGIN
  SELECT * FROM order_product WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_order_product_all` ()   BEGIN
  SELECT * FROM order_product;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_price` (IN `p_id` INT)   BEGIN
  SELECT * FROM prices WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_price_all` ()   BEGIN
  SELECT * FROM prices ORDER BY id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_product` (IN `p_id` INT)   BEGIN
  SELECT * FROM products WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_product_all` ()   BEGIN
  SELECT * FROM products ORDER BY name;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_reserved_seats_by_screening` (IN `p_screening_id` INT)   BEGIN
SELECT DISTINCT s.id, s.row_num, s.column_num
FROM seats s
INNER JOIN ticket_orders t ON s.id = t.seat_id -- Ha van seat_id
WHERE t.screening_id = p_screening_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_room` (IN `p_id` INT)   BEGIN
SELECT * 
FROM rooms
WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_screening` (IN `p_id` INT)   BEGIN
  SELECT * FROM screening WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_screening_all` ()   BEGIN
  SELECT * FROM screening ORDER BY start_time;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_seat` (IN `p_id` INT)   BEGIN
SELECT *
FROM seats
WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_ticket` (IN `p_id` INT)   BEGIN
  SELECT * FROM tickets WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_ticket_all` ()   BEGIN
  SELECT * FROM tickets ORDER BY purchased_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_ticket_orders_by_user` (IN `p_id` INT)   BEGIN
SELECT *
FROM ticket_orders
WHERE ticket_orders.user_id = users.id AND id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_ticket_prices` ()   BEGIN
    SELECT id, type, price
    FROM prices
    ORDER BY id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user` (IN `p_id` INT)   BEGIN
  SELECT id, firstname, lastname, email, phone, password, created_at, updated_at
  FROM users, created_users WHERE id = p_id AND created_users.user_id = users.id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_all` ()   BEGIN
  SELECT id, firstname, lastname, email, phone, password, created_at, updated_at
  FROM users ORDER BY firstname, lastname;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_bookings` (IN `p_user_id` INT)   BEGIN
    SELECT 
        t.id AS ticket_id,
        f.title AS film_title,
        s.start_time,
        t.price,
        t.purchased_at
    FROM tickets t
    JOIN screening s ON s.id = t.screening_id
    JOIN films f ON f.id = s.film_id
    WHERE t.user_id = p_user_id
    ORDER BY t.purchased_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_film` (IN `p_id` INT, IN `p_title` VARCHAR(200), IN `p_duration` INT, IN `p_release` DATE, IN `p_rating` INT, IN `p_genre` INT, IN `p_description` TEXT, IN `p_language` VARCHAR(100))   BEGIN
  UPDATE films
  SET title = p_title,
      duration_min = p_duration,
      release_date = p_release,
      description = p_description,
      language = p_language,
      rating = p_rating,
      genre = p_genre,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_genre` (IN `p_id` VARCHAR(100), IN `p_name` TEXT, IN `p_description` INT)   BEGIN
UPDATE genres
SET name = p_name,
    description = p_description,
    updated_at = NOW()
WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_order` (IN `p_id` INT, IN `p_total` DECIMAL(10,0))   BEGIN
  UPDATE orders
  SET total = p_total,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_order_product` (IN `p_id` INT, IN `p_quantity` INT)   BEGIN
  UPDATE order_product
  SET quantity = p_quantity,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_price` (IN `p_id` INT, IN `p_type` VARCHAR(50), IN `p_price` INT)   BEGIN
  UPDATE prices
  SET type = p_type,
      price = p_price,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_product` (IN `p_id` INT, IN `p_name` VARCHAR(100), IN `p_price` DECIMAL(10,0))   BEGIN
  UPDATE products
  SET name = p_name,
      price = p_price,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_room` (IN `p_id` INT, IN `p_screeen_size` VARCHAR(100), IN `p_sound_system` VARCHAR(100))   BEGIN
UPDATE rooms
SET screen_size = p_screen_size,
sound_system = p_souns_system,
updated_at = NOW()
WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_screening` (IN `p_id` INT, IN `p_film_id` INT, IN `p_start` DATETIME)   BEGIN
  UPDATE screening
  SET film_id = p_film_id,
      start_time = p_start,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_seat` (IN `p_column_num` INT, IN `p_row_num` INT, IN `p_room_id` INT)   BEGIN
UPDATE seats
SET column_num = p_column_num,
row_num = p_row_num,
room_id = p_room_id,
updated_at = NOW();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_user` (IN `p_id` INT, IN `p_firstname` VARCHAR(100), IN `p_lastname` VARCHAR(100), IN `p_email` VARCHAR(150), IN `p_phone` TEXT, IN `p_password` CHAR(64), IN `p_role` VARCHAR(10))   BEGIN
  DECLARE v_salt CHAR(16);
  DECLARE v_hash CHAR(64);

  SET v_salt = SUBSTRING(MD5(RAND()), 1, 16);

  SET v_hash = SHA2(CONCAT(p_password, v_salt), 256);

  UPDATE users
  SET firstname = p_firstname,
      lastname = p_lastname,
      email = p_email,
      phone = p_phone,
      password = v_hash,
      salt = v_salt,
      role = p_role,
      updated_at = NOW()
  WHERE id = p_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `admin_users`
--

CREATE TABLE `admin_users` (
  `id` int NOT NULL,
  `username` varchar(100) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `phone` text COLLATE utf8mb3_hungarian_ci NOT NULL,
  `password` char(64) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `salt` char(16) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `admin_users`
--

INSERT INTO `admin_users` (`id`, `username`, `email`, `phone`, `password`, `salt`, `created_at`, `updated_at`) VALUES
(1, 'admin1', 'admin1@gmail.com', '01234567899', 'd90c649533af4d106a6879fa04bb6e7401818d51bd5dbe6526c8d7327e5a72fe', 'af0c0abbb31ab401', NULL, NULL);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `films`
--

CREATE TABLE `films` (
  `id` int NOT NULL,
  `title` varchar(200) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `duration_min` int NOT NULL,
  `release_date` date NOT NULL,
  `description` text COLLATE utf8mb3_hungarian_ci NOT NULL,
  `genre_id` int NOT NULL,
  `language` varchar(50) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `rating` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_deleted` tinyint(1) DEFAULT '0',
  `language_id` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `film_genres`
--

CREATE TABLE `film_genres` (
  `film_id` int NOT NULL,
  `genre_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `film_metadata`
--

CREATE TABLE `film_metadata` (
  `film_id` int NOT NULL,
  `meta_key` varchar(50) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `meta_value` varchar(255) COLLATE utf8mb4_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `genres`
--

CREATE TABLE `genres` (
  `id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `description` text COLLATE utf8mb3_hungarian_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `languages`
--

CREATE TABLE `languages` (
  `id` int NOT NULL,
  `code` varchar(10) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `name` varchar(50) COLLATE utf8mb4_hungarian_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `orders`
--

CREATE TABLE `orders` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `total` decimal(10,2) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `is_active` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `order_product`
--

CREATE TABLE `order_product` (
  `id` int NOT NULL,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `prices`
--

CREATE TABLE `prices` (
  `id` int NOT NULL,
  `type` varchar(50) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `products`
--

CREATE TABLE `products` (
  `id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `price` decimal(10,2) DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `products`
--

INSERT INTO `products` (`id`, `name`, `price`, `updated_at`, `created_at`) VALUES
(1, 'small popcorn(0,5l)', 1600.00, NULL, NULL),
(2, 'medium popcorn(2,3l)', 1800.00, NULL, NULL),
(3, 'large popcorn(4,8l)', 2000.00, NULL, NULL),
(4, 'small drink(0,5l)', 1300.00, NULL, NULL),
(5, 'medium drink(0,75l)', 1500.00, NULL, NULL),
(6, 'large drink(1l)', 1700.00, NULL, NULL),
(7, 'medium nachos', 2200.00, NULL, NULL),
(8, 'large nachos', 2400.00, NULL, NULL),
(9, 'water(0,5l)', 900.00, NULL, NULL);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `rooms`
--

CREATE TABLE `rooms` (
  `id` int NOT NULL,
  `screen_size` varchar(20) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `sound_system` text COLLATE utf8mb3_hungarian_ci NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `screening`
--

CREATE TABLE `screening` (
  `id` int NOT NULL,
  `film_id` int NOT NULL,
  `start_time` datetime(6) NOT NULL,
  `room_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `seats`
--

CREATE TABLE `seats` (
  `id` int NOT NULL,
  `room_id` int NOT NULL,
  `row_num` int NOT NULL,
  `column_num` int NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `ticket_orders`
--

CREATE TABLE `ticket_orders` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `ticket_id` int NOT NULL,
  `quantity` int NOT NULL,
  `total_price` decimal(10,2) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `screening_id` int NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `seat_id` int DEFAULT NULL
) ;

--
-- Eseményindítók `ticket_orders`
--
DELIMITER $$
CREATE TRIGGER `ticket_orders_total_price_check` BEFORE INSERT ON `ticket_orders` FOR EACH ROW BEGIN
    IF NEW.total_price < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'total_price cannot be negative';
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `ticket_orders_total_price_check_update` BEFORE UPDATE ON `ticket_orders` FOR EACH ROW BEGIN
    IF NEW.total_price < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'total_price cannot be negative';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `ticket_order_seats`
--

CREATE TABLE `ticket_order_seats` (
  `ticket_order_id` int NOT NULL,
  `seat_id` int NOT NULL,
  `screening_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `firstname` varchar(100) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `lastname` varchar(100) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `password` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_hungarian_ci NOT NULL,
  `phone` mediumtext COLLATE utf8mb4_hungarian_ci NOT NULL,
  `salt` char(16) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `updated_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `role` varchar(10) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `admin_users`
--
ALTER TABLE `admin_users`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `films`
--
ALTER TABLE `films`
  ADD PRIMARY KEY (`id`),
  ADD KEY `genre` (`genre_id`),
  ADD KEY `idx_films_release_date` (`release_date`),
  ADD KEY `idx_films_is_deleted` (`is_deleted`),
  ADD KEY `idx_films_language_id` (`language_id`),
  ADD KEY `idx_films_release_year` (`release_date`);

--
-- A tábla indexei `film_genres`
--
ALTER TABLE `film_genres`
  ADD PRIMARY KEY (`film_id`,`genre_id`),
  ADD KEY `genre_id` (`genre_id`);

--
-- A tábla indexei `film_metadata`
--
ALTER TABLE `film_metadata`
  ADD PRIMARY KEY (`film_id`,`meta_key`);

--
-- A tábla indexei `genres`
--
ALTER TABLE `genres`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `languages`
--
ALTER TABLE `languages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- A tábla indexei `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_orders_user_id` (`user_id`),
  ADD KEY `idx_orders_created_at` (`created_at`);

--
-- A tábla indexei `order_product`
--
ALTER TABLE `order_product`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order` (`order_id`),
  ADD KEY `product` (`product_id`);

--
-- A tábla indexei `prices`
--
ALTER TABLE `prices`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `rooms`
--
ALTER TABLE `rooms`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `screening`
--
ALTER TABLE `screening`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_screening_room` (`room_id`),
  ADD KEY `idx_screening_film_room` (`film_id`,`room_id`),
  ADD KEY `idx_screening_start_time` (`start_time`);

--
-- A tábla indexei `seats`
--
ALTER TABLE `seats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_seats_room` (`room_id`);

--
-- A tábla indexei `ticket_orders`
--
ALTER TABLE `ticket_orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `ticket` (`ticket_id`),
  ADD KEY `idx_ticket_orders_screening` (`screening_id`),
  ADD KEY `idx_ticket_orders_user` (`user_id`),
  ADD KEY `idx_ticket_orders_seat_id` (`seat_id`);

--
-- A tábla indexei `ticket_order_seats`
--
ALTER TABLE `ticket_order_seats`
  ADD PRIMARY KEY (`ticket_order_id`,`seat_id`,`screening_id`),
  ADD KEY `seat_id` (`seat_id`),
  ADD KEY `screening_id` (`screening_id`);

--
-- A tábla indexei `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_users_email` (`email`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT a táblához `films`
--
ALTER TABLE `films`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT a táblához `genres`
--
ALTER TABLE `genres`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `languages`
--
ALTER TABLE `languages`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT a táblához `order_product`
--
ALTER TABLE `order_product`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT a táblához `prices`
--
ALTER TABLE `prices`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT a táblához `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT a táblához `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `screening`
--
ALTER TABLE `screening`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT a táblához `seats`
--
ALTER TABLE `seats`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=251;

--
-- AUTO_INCREMENT a táblához `ticket_orders`
--
ALTER TABLE `ticket_orders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `films`
--
ALTER TABLE `films`
  ADD CONSTRAINT `fk_films_language` FOREIGN KEY (`language_id`) REFERENCES `languages` (`id`),
  ADD CONSTRAINT `genre` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `film_genres`
--
ALTER TABLE `film_genres`
  ADD CONSTRAINT `film_genres_ibfk_1` FOREIGN KEY (`film_id`) REFERENCES `films` (`id`),
  ADD CONSTRAINT `film_genres_ibfk_2` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`id`);

--
-- Megkötések a táblához `film_metadata`
--
ALTER TABLE `film_metadata`
  ADD CONSTRAINT `film_metadata_ibfk_1` FOREIGN KEY (`film_id`) REFERENCES `films` (`id`);

--
-- Megkötések a táblához `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `fk_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`);

--
-- Megkötések a táblához `order_product`
--
ALTER TABLE `order_product`
  ADD CONSTRAINT `order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `screening`
--
ALTER TABLE `screening`
  ADD CONSTRAINT `fk_screening_film` FOREIGN KEY (`film_id`) REFERENCES `films` (`id`),
  ADD CONSTRAINT `fk_screening_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`),
  ADD CONSTRAINT `rooms` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `seats`
--
ALTER TABLE `seats`
  ADD CONSTRAINT `fk_seats_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`),
  ADD CONSTRAINT `room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `ticket_orders`
--
ALTER TABLE `ticket_orders`
  ADD CONSTRAINT `fk_ticket_orders_seat` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`id`),
  ADD CONSTRAINT `fk_ticket_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `ticket` FOREIGN KEY (`ticket_id`) REFERENCES `prices` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `ticket_order_seats`
--
ALTER TABLE `ticket_order_seats`
  ADD CONSTRAINT `ticket_order_seats_ibfk_1` FOREIGN KEY (`ticket_order_id`) REFERENCES `ticket_orders` (`id`),
  ADD CONSTRAINT `ticket_order_seats_ibfk_2` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`id`),
  ADD CONSTRAINT `ticket_order_seats_ibfk_3` FOREIGN KEY (`screening_id`) REFERENCES `screening` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
