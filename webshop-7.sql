-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: localhost:8889
-- Létrehozás ideje: 2026. Jan 28. 18:56
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
  INSERT INTO orders (user_id, total, created_at)
  VALUES (p_user_id, p_total, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_order_product` (IN `p_order_id` INT, IN `p_product_id` INT, IN `p_quantity` INT)   BEGIN
  INSERT INTO order_product (order_id, product_id, quantity, updated_at, created_at)
  VALUES (p_order_id, p_product_id, p_quantity, NOW(), NOW());
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_screening` (IN `p_film_id` INT, IN `p_start` TIME)   BEGIN
  INSERT INTO screening (film_id, start_time)
  VALUES (p_film_id, p_start);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_seat` (IN `p_column_num` INT, IN `p_row_num` INT, IN `p_room_id` INT)   BEGIN
INSERT INTO seats(column_num, row_num, room_id, created_at, updated_at)
VALUES(p_column_num, p_row_num, p_room_id, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_ticket` (IN `p_screening_id` INT, IN `p_user_id` INT, IN `p_price` DECIMAL(10,0))   BEGIN
  INSERT INTO tickets (screening_id, user_id, price)
  VALUES (p_screening_id, p_user_id, p_price);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_ticket_order` (IN `p_user_id` INT, IN `p_ticket_id` INT, IN `p_quantity` INT, IN `p_screening_id` INT)   BEGIN
INSERT INTO ticket_orders(user_id, ticket_id, quantity, total, created_at, screening_id)
VALUES(p_user_id, p_ticket_id, p_quantity, (prices.price * p_quantity), NOW(), p_screening_id);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_admin_user` (IN `p_username` VARCHAR(100), IN `p_email` VARCHAR(100), IN `p_phone` TEXT, IN `p_password` CHAR(64))   BEGIN
  DECLARE v_salt CHAR(16);
  DECLARE v_hash CHAR(64);

  SET v_salt = SUBSTRING(MD5(RAND()), 1, 16);

  SET v_hash = SHA2(CONCAT(p_password, v_salt), 256);

  INSERT INTO admin_users (username, email, phone, password, salt, created_at)
  VALUES (p_username, p_email, p_phone, v_hash, v_salt, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_user` (IN `p_firstname` VARCHAR(50), IN `p_lastname` VARCHAR(50), IN `p_email` VARCHAR(100), IN `p_phone` TEXT, IN `p_password` VARCHAR(255))   BEGIN
  DECLARE v_salt CHAR(16);
  DECLARE v_hash CHAR(64);

  SET v_salt = SUBSTRING(MD5(RAND()), 1, 16);

  SET v_hash = SHA2(CONCAT(p_password, v_salt), 256);

  INSERT INTO users (firstname, lastname, email, phone, password, salt, updated_at, created_at)
  VALUES (p_firstname, p_lastname, p_email, p_phone, v_hash, v_salt, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_admin` (IN `p_id` INT)   BEGIN
	INSERT INTO deleted_admins (user_id, username, email, phone, password, salt, deleted_at)
    SELECT id, username, email, phone, password, salt, NOW()
    FROM admin_users
    WHERE id = p_id;

    DELETE FROM admin_users
    WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_film` (IN `p_id` INT)   BEGIN
  DELETE FROM films WHERE id = p_id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_admin` (IN `p_id` INT)   BEGIN
SELECT *
FROM admin_users
WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_admin_all` (IN `p_id` INT)   BEGIN
SELECT *
FROM admin_users
ORDER BY username;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_by_user` (IN `p_id` INT)   BEGIN
SELECT *
FROM orders, ticket_orders
WHERE orders.user_id = users.id AND ticket_orders.user_id = users.id AND id = p_id;
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
  SELECT * FROM films ORDER BY release_date DESC;
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
    SELECT id, row_num, column_num
    FROM seats
    WHERE screening_id = p_screening_id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_admin` (IN `p_id` INT, IN `p_username` VARCHAR(100), IN `p_email` VARCHAR(100), IN `p_phone` TEXT, IN `p_password` CHAR(64))   BEGIN
  DECLARE v_salt CHAR(16);
  DECLARE v_hash CHAR(64);

  SET v_salt = SUBSTRING(MD5(RAND()), 1, 16);

  SET v_hash = SHA2(CONCAT(p_password, v_salt), 256);

  UPDATE admin_users
  SET username = p_username,
      email = p_email,
      phone = p_phone,
      password = v_hash,
      salt = v_salt,
      updated_at = NOW()
  WHERE id = p_id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_screening` (IN `p_id` INT, IN `p_film_id` INT, IN `p_start` TIME)   BEGIN
  UPDATE screening
  SET film_id = p_film_id,
      start_time = p_start
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_seat` (IN `p_column_num` INT, IN `p_row_num` INT, IN `p_room_id` INT)   BEGIN
UPDATE seats
SET column_num = p_column_num,
row_num = p_row_num,
room_id = p_room_id,
updated_at = NOW();
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_user` (IN `p_id` INT, IN `p_firstname` VARCHAR(100), IN `p_lastname` VARCHAR(100), IN `p_email` VARCHAR(150), IN `p_phone` TEXT, IN `p_password` CHAR(64))   BEGIN
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
-- Tábla szerkezet ehhez a táblához `deleted_admins`
--

CREATE TABLE `deleted_admins` (
  `user_id` int NOT NULL,
  `username` varchar(100) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_hungarian_ci NOT NULL,
  `phone` text COLLATE utf8mb3_hungarian_ci NOT NULL,
  `password` char(64) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `salt` char(16) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `deleted_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `deleted_users`
--

CREATE TABLE `deleted_users` (
  `id` int NOT NULL,
  `firstname` varchar(100) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `lastname` varchar(100) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `password` char(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_hungarian_ci NOT NULL,
  `phone` text COLLATE utf8mb3_hungarian_ci NOT NULL,
  `salt` char(16) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `deleted_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `deleted_users`
--

INSERT INTO `deleted_users` (`id`, `firstname`, `lastname`, `email`, `password`, `phone`, `salt`, `deleted_at`) VALUES
(1, 'user', 'user', 'user@gmail.com', 'ee7c46e962689c6393e3972f3c50b841306a2a513e3859d5ecb2b01c6f66cfa7', '01234567890', 'b76638bade5178b5', '2026-01-27 19:22:03');

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
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

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
-- Tábla szerkezet ehhez a táblához `orders`
--

CREATE TABLE `orders` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `total` decimal(10,0) NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `orders`
--

INSERT INTO `orders` (`id`, `user_id`, `total`, `created_at`, `updated_at`) VALUES
(2, 1, 3800, NULL, NULL);

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
  `price` int NOT NULL,
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
  `price` decimal(10,0) NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `products`
--

INSERT INTO `products` (`id`, `name`, `price`, `updated_at`, `created_at`) VALUES
(1, 'small popcorn(0,5l)', 1600, NULL, NULL),
(2, 'medium popcorn(2,3l)', 1800, NULL, NULL),
(3, 'large popcorn(4,8l)', 2000, NULL, NULL),
(4, 'small drink(0,5l)', 1300, NULL, NULL),
(5, 'medium drink(0,75l)', 1500, NULL, NULL),
(6, 'large drink(1l)', 1700, NULL, NULL),
(7, 'medium nachos', 2200, NULL, NULL),
(8, 'large nachos', 2400, NULL, NULL),
(9, 'water(0,5l)', 900, NULL, NULL);

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
  `start_time` time(6) NOT NULL,
  `rooms_id` int NOT NULL
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
  `total_price` int NOT NULL,
  `created_at` datetime DEFAULT NULL,
  `screening_id` int NOT NULL,
  `updated_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `users`
--

CREATE TABLE `users` (
  `id` int NOT NULL,
  `firstname` varchar(100) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `lastname` varchar(100) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `email` varchar(150) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `password` char(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_hungarian_ci NOT NULL,
  `phone` text COLLATE utf8mb3_hungarian_ci NOT NULL,
  `salt` char(16) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `updated_at` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `admin_users`
--
ALTER TABLE `admin_users`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `deleted_admins`
--
ALTER TABLE `deleted_admins`
  ADD PRIMARY KEY (`user_id`);

--
-- A tábla indexei `deleted_users`
--
ALTER TABLE `deleted_users`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `films`
--
ALTER TABLE `films`
  ADD PRIMARY KEY (`id`),
  ADD KEY `genre` (`genre_id`);

--
-- A tábla indexei `genres`
--
ALTER TABLE `genres`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id`);

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
  ADD KEY `rooms` (`rooms_id`);

--
-- A tábla indexei `seats`
--
ALTER TABLE `seats`
  ADD PRIMARY KEY (`id`),
  ADD KEY `room` (`room_id`);

--
-- A tábla indexei `ticket_orders`
--
ALTER TABLE `ticket_orders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user` (`user_id`),
  ADD KEY `ticket` (`ticket_id`);

--
-- A tábla indexei `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT a táblához `deleted_admins`
--
ALTER TABLE `deleted_admins`
  MODIFY `user_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `deleted_users`
--
ALTER TABLE `deleted_users`
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
  ADD CONSTRAINT `genre` FOREIGN KEY (`genre_id`) REFERENCES `genres` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `order_product`
--
ALTER TABLE `order_product`
  ADD CONSTRAINT `order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `product` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `rooms`
--
ALTER TABLE `rooms`
  ADD CONSTRAINT `seats` FOREIGN KEY (`id`) REFERENCES `seats` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `screening`
--
ALTER TABLE `screening`
  ADD CONSTRAINT `rooms` FOREIGN KEY (`rooms_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `seats`
--
ALTER TABLE `seats`
  ADD CONSTRAINT `room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `ticket_orders`
--
ALTER TABLE `ticket_orders`
  ADD CONSTRAINT `ticket` FOREIGN KEY (`ticket_id`) REFERENCES `prices` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  ADD CONSTRAINT `user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

--
-- Megkötések a táblához `users`
--
ALTER TABLE `users`
  ADD CONSTRAINT `ticket_orders` FOREIGN KEY (`id`) REFERENCES `ticket_orders` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
