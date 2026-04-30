-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: localhost:8889
-- Létrehozás ideje: 2026. Feb 20. 18:05
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_film` (IN `p_title` VARCHAR(200), IN `p_duration` INT, IN `p_release` DATE, IN `p_description` TEXT, IN `p_poster_url` VARCHAR(255), IN `p_genre_id` INT, IN `p_language` VARCHAR(50), IN `p_rating` INT)   BEGIN
  INSERT INTO films (
    title, duration_min, release_date, description,
    poster_url, genre_id, language, rating,
    created_at, updated_at
  )
  VALUES (
    p_title, p_duration, p_release, p_description,
    p_poster_url, p_genre_id, p_language, p_rating,
    NOW(), NOW()
  );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_genre` (IN `p_name` VARCHAR(100), IN `p_description` TEXT)   BEGIN
INSERT INTO genres(name, description, updated_at, created_at)
VALUES(p_name, p_description, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_order` (IN `p_user_id` INT, IN `p_total` DECIMAL(10,2))   BEGIN
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
  END IF;

  IF p_total <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Total must be positive';
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_price` (IN `p_type` VARCHAR(50), IN `p_price` DECIMAL(10,2))   BEGIN
  INSERT INTO prices (type, price, created_at, updated_at)
  VALUES (p_type, p_price, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_product` (IN `p_name` VARCHAR(100), IN `p_price` DECIMAL(10,2))   BEGIN
  INSERT INTO products (name, price, created_at, updated_at)
  VALUES (p_name, p_price, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_room` (IN `p_screen_size` VARCHAR(100), IN `p_sound_system` VARCHAR(100))   BEGIN
INSERT INTO rooms(screen_size, sound_system, created_at, updated_at)
VALUES(p_screen_size, p_sound_system, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_screening` (IN `p_film_id` INT, IN `p_room_id` INT, IN `p_start` TIME, IN `p_screening_date` DATE)   BEGIN
  IF NOT EXISTS (SELECT 1 FROM films WHERE id = p_film_id AND is_deleted = 0) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Film not found or deleted';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM rooms WHERE id = p_room_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Room not found';
  END IF;

  INSERT INTO screening (film_id, room_id, start_time, screening_date, created_at, updated_at)
  VALUES (p_film_id, p_room_id, p_start, p_screening_date, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_seat` (IN `p_column_num` INT, IN `p_row_num` INT, IN `p_room_id` INT)   BEGIN
INSERT INTO seats(column_num, row_num, room_id, created_at, updated_at)
VALUES(p_column_num, p_row_num, p_room_id, NOW(), NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_ticket_order` (IN `p_user_id` INT, IN `p_price_id` INT, IN `p_quantity` INT, IN `p_screening_id` INT, IN `p_seat_id` INT)   BEGIN
  DECLARE v_price DECIMAL(10,2);
  DECLARE v_total DECIMAL(10,2);
  DECLARE v_room_id INT;
  DECLARE v_seat_room_id INT;

  IF p_quantity <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Quantity must be positive';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id AND is_active = 1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
  END IF;

  SELECT price INTO v_price
  FROM prices
  WHERE id = p_price_id;

  IF v_price IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price not found';
  END IF;

  SELECT room_id INTO v_room_id
  FROM screening
  WHERE id = p_screening_id;

  IF v_room_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Screening not found (or missing room_id)';
  END IF;

  SELECT room_id INTO v_seat_room_id
  FROM seats
  WHERE id = p_seat_id;

  IF v_seat_room_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seat not found';
  END IF;

  IF v_seat_room_id <> v_room_id THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seat does not belong to the screening room';
  END IF;

  -- opcionális: foglaltság ellenőrzés (1 ülés/1 screening)
  IF EXISTS (
    SELECT 1 FROM ticket_orders
    WHERE screening_id = p_screening_id AND seat_id = p_seat_id
  ) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seat already reserved for this screening';
  END IF;

  SET v_total = v_price * p_quantity;

  INSERT INTO ticket_orders(user_id, ticket_id, quantity, total_price, created_at, updated_at, screening_id, seat_id)
  VALUES(p_user_id, p_price_id, p_quantity, v_total, NOW(), NOW(), p_screening_id, p_seat_id);

  SELECT LAST_INSERT_ID() AS ticket_order_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_ticket_order_v2` (IN `p_user_id` INT, IN `p_price_id` INT, IN `p_screening_id` INT, IN `p_seat_ids` JSON)   BEGIN
  DECLARE v_price DECIMAL(10,2);
  DECLARE v_total DECIMAL(10,2);
  DECLARE v_room_id INT;
  DECLARE v_cnt INT;
  DECLARE v_order_id INT;

  DECLARE i INT DEFAULT 0;
  DECLARE v_seat_id INT;
  DECLARE v_seat_room_id INT;

  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error creating ticket order';
  END;

  IF p_seat_ids IS NULL OR JSON_TYPE(p_seat_ids) <> 'ARRAY' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'seat_ids must be a JSON array';
  END IF;

  SET v_cnt = JSON_LENGTH(p_seat_ids);
  IF v_cnt IS NULL OR v_cnt <= 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'At least 1 seat must be provided';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_user_id AND is_active = 1) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found or inactive';
  END IF;

  SELECT price INTO v_price
  FROM prices
  WHERE id = p_price_id;

  IF v_price IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Price not found';
  END IF;

  SELECT room_id INTO v_room_id
  FROM screening
  WHERE id = p_screening_id;

  IF v_room_id IS NULL THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Screening not found (or missing room_id)';
  END IF;

  START TRANSACTION;

  SET v_total = v_price * v_cnt;

  INSERT INTO ticket_orders(user_id, ticket_id, quantity, total_price, created_at, updated_at, screening_id)
  VALUES(p_user_id, p_price_id, v_cnt, v_total, NOW(), NOW(), p_screening_id);

  SET v_order_id = LAST_INSERT_ID();

  WHILE i < v_cnt DO
    SET v_seat_id = JSON_UNQUOTE(JSON_EXTRACT(p_seat_ids, CONCAT('$[', i, ']')));

    SELECT room_id INTO v_seat_room_id
    FROM seats
    WHERE id = v_seat_id;

    IF v_seat_room_id IS NULL THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Seat not found';
    END IF;

    IF v_seat_room_id <> v_room_id THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'One of the seats does not belong to the screening room';
    END IF;

    INSERT INTO ticket_order_seats(ticket_order_id, seat_id, screening_id)
    VALUES (v_order_id, v_seat_id, p_screening_id);

    SET i = i + 1;
  END WHILE;

  COMMIT;

  SELECT v_order_id AS ticket_order_id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_user` (IN `p_id` INT)   BEGIN
  IF NOT EXISTS (SELECT 1 FROM users WHERE id = p_id) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User not found';
  END IF;

  UPDATE users
  SET is_active = 0,
      deleted_at = NOW(),
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_by_user` (IN `p_user_id` INT)   BEGIN
  -- 1) orders
  SELECT *
  FROM orders
  WHERE user_id = p_user_id
  ORDER BY created_at DESC;

  -- 2) ticket_orders
  SELECT *
  FROM ticket_orders
  WHERE user_id = p_user_id
  ORDER BY created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_prices` ()   BEGIN
    SELECT id, type, price, updated_at
    FROM prices
    ORDER BY id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_seat` (IN `p_room_id` INT)   BEGIN
  SELECT *
  FROM seats
  WHERE room_id = p_room_id
  ORDER BY row_num, column_num;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_daily_revenue` (IN `p_date` DATE)   BEGIN
  SELECT 
    (SELECT IFNULL(SUM(total_price), 0)
     FROM ticket_orders
     WHERE DATE(created_at) = p_date)
    +
    (SELECT IFNULL(SUM(total), 0)
     FROM orders
     WHERE DATE(created_at) = p_date)
    AS total_revenue;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_film` (IN `p_id` INT)   BEGIN
  SELECT f.*,
         g.name AS genre_name
  FROM films f
  JOIN genres g ON g.id = f.genre_id
  WHERE f.id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_film_all` ()   BEGIN
  SELECT f.*,
         g.name AS genre_name
  FROM films f
  JOIN genres g ON g.id = f.genre_id
  WHERE f.is_deleted = 0
  ORDER BY f.release_date DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_order` (IN `p_id` INT)   BEGIN
  SELECT * FROM orders WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_order_all` ()   BEGIN
  SELECT * FROM orders ORDER BY id DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_order_by_user` (IN `p_user_id` INT)   BEGIN
  SELECT *
  FROM orders
  WHERE user_id = p_user_id
  ORDER BY created_at DESC;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_ticket_prices` ()   BEGIN
    SELECT id, type, price
    FROM prices
    ORDER BY id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_all` ()   BEGIN
  SELECT id, firstname, lastname, email, phone, password, created_at, updated_at
  FROM users ORDER BY firstname, lastname;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_user_bookings` (IN `p_user_id` INT)   BEGIN
  SELECT
    to2.id              AS ticket_order_id,
    f.title             AS film_title,
    s.screening_date,
    s.start_time,
    to2.quantity,
    to2.total_price,
    to2.created_at      AS purchased_at,
    se.row_num,
    se.column_num
  FROM ticket_orders to2
  JOIN screening s ON s.id = to2.screening_id
  JOIN films f ON f.id = s.film_id
  LEFT JOIN seats se ON se.id = to2.seat_id
  WHERE to2.user_id = p_user_id
  ORDER BY to2.created_at DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_film` (IN `p_id` INT, IN `p_title` VARCHAR(200), IN `p_duration` INT, IN `p_release` DATE, IN `p_description` TEXT, IN `p_poster_url` VARCHAR(255), IN `p_genre_id` INT, IN `p_language` VARCHAR(100), IN `p_rating` INT)   BEGIN
  UPDATE films
  SET title = p_title,
      duration_min = p_duration,
      release_date = p_release,
      description = p_description,
      poster_url = p_poster_url,
      genre_id = p_genre_id,
      language = p_language,
      rating = p_rating,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_genre` (IN `p_id` INT, IN `p_name` VARCHAR(100), IN `p_description` TEXT)   BEGIN
  UPDATE genres
  SET name = p_name,
      description = p_description,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_order` (IN `p_id` INT, IN `p_total` DECIMAL(10,2))   BEGIN
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_price` (IN `p_id` INT, IN `p_type` VARCHAR(50), IN `p_price` DECIMAL(10,2))   BEGIN
  UPDATE prices
  SET type = p_type,
      price = p_price,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_product` (IN `p_id` INT, IN `p_name` VARCHAR(100), IN `p_price` DECIMAL(10,2))   BEGIN
  UPDATE products
  SET name = p_name,
      price = p_price,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_room` (IN `p_id` INT, IN `p_screen_size` VARCHAR(100), IN `p_sound_system` VARCHAR(100))   BEGIN
  UPDATE rooms
  SET screen_size = p_screen_size,
      sound_system = p_sound_system,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_screening` (IN `p_id` INT, IN `p_film_id` INT, IN `p_start` TIME, IN `p_screening_date` DATE)   BEGIN
  UPDATE screening
  SET film_id = p_film_id,
      start_time = p_start,
      screening_date = p_screening_date,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_seat` (IN `p_id` INT, IN `p_column_num` INT, IN `p_row_num` INT, IN `p_room_id` INT)   BEGIN
  UPDATE seats
  SET column_num = p_column_num,
      row_num = p_row_num,
      room_id = p_room_id,
      updated_at = NOW()
  WHERE id = p_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_user` (IN `p_id` INT, IN `p_firstname` VARCHAR(100), IN `p_lastname` VARCHAR(100), IN `p_email` VARCHAR(150), IN `p_phone` TEXT, IN `p_password` VARCHAR(255), IN `p_role` VARCHAR(10))   BEGIN
  DECLARE v_salt CHAR(16);
  DECLARE v_hash CHAR(64);

  SET v_salt = SUBSTRING(REPLACE(UUID(), '-', ''), 1, 16);
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
-- Tábla szerkezet ehhez a táblához `films`
--

CREATE TABLE `films` (
  `id` int NOT NULL,
  `title` varchar(200) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `duration_min` int NOT NULL,
  `release_date` date NOT NULL,
  `description` text COLLATE utf8mb3_hungarian_ci NOT NULL,
  `poster_url` varchar(255) COLLATE utf8mb3_hungarian_ci DEFAULT NULL,
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

--
-- A tábla adatainak kiíratása `films`
--

INSERT INTO `films` (`id`, `title`, `duration_min`, `release_date`, `description`, `poster_url`, `genre_id`, `language`, `rating`, `created_at`, `updated_at`, `is_deleted`, `language_id`, `is_active`, `deleted_at`) VALUES
(12, 'Avatar (2009)', 162, '2024-01-01', 'A James Cameron által rendezett epikus sci-fi kaland Pandora világában.', 'https://image.tmdb.org/t/p/original/6EiRUJpuoeQPghrs3YNktfnqOVh.jpg', 5, 'Hungarian', 8, '2026-02-18 18:56:34', '2026-02-18 18:56:34', 0, NULL, 1, NULL),
(13, 'Avengers: Endgame', 181, '2024-01-01', 'A Bosszúállók utolsó csatája Thanos ellen.', 'https://image.tmdb.org/t/p/original/ulzhLuWrPK07P1YkdWQLZnQh1JL.jpg', 2, 'Hungarian', 8, '2026-02-18 18:56:34', '2026-02-18 18:56:34', 0, NULL, 1, NULL),
(14, 'Star Wars: The Force Awakens', 138, '2024-01-01', 'A Star Wars saga új fejezete, ahol új hősök csatlakoznak a harcba.', 'https://image.tmdb.org/t/p/original/wqnLdwVXoBjKibFRR5U3y0aDUhs.jpg', 5, 'Hungarian', 8, '2026-02-18 18:56:34', '2026-02-18 18:56:34', 0, NULL, 1, NULL),
(15, 'Jurassic World', 124, '2024-01-01', 'Dinoszauruszok újra életre kelnek egy élő tematikus parkban.', 'https://image.tmdb.org/t/p/original/rhr4y79GpxQF9IsfJItRXVaoGs4.jpg', 2, 'Hungarian', 7, '2026-02-18 18:56:34', '2026-02-18 18:56:34', 0, NULL, 1, NULL),
(16, 'Spider-Man: No Way Home', 148, '2024-01-01', 'Spider-Man visszatér, hogy szembenézzen a multiverzum fenyegetéseivel.', 'https://image.tmdb.org/t/p/original/rjbNpRMoVvqHmhmksbokcyCr7wn.jpg', 2, 'Hungarian', 8, '2026-02-18 18:56:34', '2026-02-18 18:56:34', 0, NULL, 1, NULL),
(17, 'Zootopia', 108, '2024-01-01', 'Egy nyúl és egy róka kalandjai egy hatalmas állatvárosban.', 'https://image.tmdb.org/t/p/original/hlK0e0wAQ3VLuJcsfIYPvb4JVud.jpg', 3, 'Hungarian', 8, '2026-02-18 18:56:34', '2026-02-18 18:56:34', 0, NULL, 1, NULL);

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

--
-- A tábla adatainak kiíratása `genres`
--

INSERT INTO `genres` (`id`, `name`, `description`, `created_at`, `updated_at`) VALUES
(2, 'Akció', 'Akció filmek', '2026-02-18 18:43:27', '2026-02-18 18:43:27'),
(3, 'Vígjáték', 'Vígjáték filmek', '2026-02-18 18:43:27', '2026-02-18 18:43:27'),
(4, 'Horror', 'Horror filmek', '2026-02-18 18:43:27', '2026-02-18 18:43:27'),
(5, 'Sci-Fi', 'Sci-Fi filmek', '2026-02-18 18:43:27', '2026-02-18 18:43:27');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `languages`
--

CREATE TABLE `languages` (
  `id` int NOT NULL,
  `code` varchar(10) COLLATE utf8mb4_hungarian_ci NOT NULL,
  `name` varchar(50) COLLATE utf8mb4_hungarian_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_hungarian_ci;

--
-- A tábla adatainak kiíratása `languages`
--

INSERT INTO `languages` (`id`, `code`, `name`) VALUES
(1, 'hu', 'Magyar'),
(2, 'en', 'English'),
(3, 'de', 'Deutsch'),
(4, 'fr', 'Français');

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

--
-- A tábla adatainak kiíratása `prices`
--

INSERT INTO `prices` (`id`, `type`, `price`, `created_at`, `updated_at`) VALUES
(5, 'adult', 2490.00, '2026-02-18 18:45:19', '2026-02-18 18:45:19'),
(6, 'student', 1990.00, '2026-02-18 18:45:19', '2026-02-18 18:45:19'),
(7, 'child', 1690.00, '2026-02-18 18:45:19', '2026-02-18 18:45:19'),
(8, 'senior', 1790.00, '2026-02-18 18:45:19', '2026-02-18 18:45:19'),
(9, 'disabled', 1490.00, '2026-02-18 18:45:19', '2026-02-18 18:45:19');

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

--
-- A tábla adatainak kiíratása `rooms`
--

INSERT INTO `rooms` (`id`, `screen_size`, `sound_system`, `created_at`, `updated_at`) VALUES
(1, 'Room 0', 'Dolby Atmos', '2026-02-18 19:32:32', '2026-02-18 19:32:32'),
(2, 'Room 1', 'Dolby Atmos', '2026-02-18 19:04:47', '2026-02-18 19:04:47'),
(3, 'Room 2', 'Dolby Atmos', '2026-02-18 19:04:47', '2026-02-18 19:04:47'),
(4, 'Room 3', 'Dolby Atmos', '2026-02-18 19:04:47', '2026-02-18 19:04:47'),
(5, 'Room 4', 'Dolby Atmos', '2026-02-18 19:04:47', '2026-02-18 19:04:47'),
(6, 'Room 5', 'Dolby Atmos', '2026-02-18 19:04:47', '2026-02-18 19:04:47'),
(7, 'Room 6', 'Dolby Atmos', '2026-02-18 19:04:47', '2026-02-18 19:04:47'),
(8, 'Room 7', 'Dolby Atmos', '2026-02-18 19:04:47', '2026-02-18 19:04:47'),
(9, 'Room 8', 'Dolby Atmos', '2026-02-18 19:04:47', '2026-02-18 19:04:47'),
(10, 'Room 9', 'Dolby Atmos', '2026-02-18 19:04:47', '2026-02-18 19:04:47'),
(11, 'Room 10', 'Dolby Atmos', '2026-02-18 19:04:47', '2026-02-18 19:04:47');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `screening`
--

CREATE TABLE `screening` (
  `id` int NOT NULL,
  `film_id` int NOT NULL,
  `start_time` time(6) NOT NULL,
  `room_id` int DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `screening_date` date DEFAULT NULL
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
-- A tábla indexei `films`
--
ALTER TABLE `films`
  ADD PRIMARY KEY (`id`),
  ADD KEY `genre` (`genre_id`),
  ADD KEY `idx_films_release_date` (`release_date`),
  ADD KEY `idx_films_is_deleted` (`is_deleted`),
  ADD KEY `idx_films_language_id` (`language_id`);

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
  ADD UNIQUE KEY `uq_screening_seat` (`screening_id`,`seat_id`),
  ADD KEY `seat_id` (`seat_id`);

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
-- AUTO_INCREMENT a táblához `films`
--
ALTER TABLE `films`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT a táblához `genres`
--
ALTER TABLE `genres`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT a táblához `languages`
--
ALTER TABLE `languages`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT a táblához `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT a táblához `rooms`
--
ALTER TABLE `rooms`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT a táblához `screening`
--
ALTER TABLE `screening`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT a táblához `seats`
--
ALTER TABLE `seats`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

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
  ADD CONSTRAINT `fk_screening_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`);

--
-- Megkötések a táblához `seats`
--
ALTER TABLE `seats`
  ADD CONSTRAINT `fk_seats_room` FOREIGN KEY (`room_id`) REFERENCES `rooms` (`id`);

--
-- Megkötések a táblához `ticket_orders`
--
ALTER TABLE `ticket_orders`
  ADD CONSTRAINT `fk_ticket_orders_seat` FOREIGN KEY (`seat_id`) REFERENCES `seats` (`id`),
  ADD CONSTRAINT `fk_ticket_orders_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  ADD CONSTRAINT `ticket` FOREIGN KEY (`ticket_id`) REFERENCES `prices` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

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
