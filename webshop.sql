-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: localhost:8889
-- Létrehozás ideje: 2025. Okt 10. 09:26
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
CREATE DATABASE IF NOT EXISTS `webshop` DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_hungarian_ci;
USE `webshop`;

DELIMITER $$
--
-- Eljárások
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_film` (IN `p_title` VARCHAR(200), IN `p_duration_minutes` INT, IN `p_release_date` DATE)   BEGIN
    INSERT INTO films (title, duration_minutes, release_date)
    VALUES (p_title, p_duration_minutes, p_release_date);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_order_product` (IN `p_order_id` INT, IN `p_product_id` INT, IN `p_quantity` INT)   BEGIN
    INSERT INTO order_products (order_id, product_id, quantity)
    VALUES (p_order_id, p_product_id, p_quantity);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_screening` (IN `p_film_id` INT, IN `p_start_time` DATETIME, IN `p_price` DECIMAL(8,2))   BEGIN
    INSERT INTO screenings (film_id, start_time, auditorium, price)
    VALUES (p_film_id, p_start_time, p_auditorium, p_price);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buy_ticket` (IN `p_screening_id` INT, IN `p_user_id` INT, IN `p_price` DECIMAL(8,2))   BEGIN
    INSERT INTO tickets (screening_id, user_id, price, purchased_at)
    VALUES (p_screening_id, p_user_id, p_price, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_order` (IN `p_user_id` INT, IN `p_total` DECIMAL(10,2))   BEGIN
    INSERT INTO orders (user_id, total)
    VALUES (p_user_id, p_total);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_daily_revenue` (IN `p_date` DATE)   BEGIN
    SELECT 
        (SELECT IFNULL(SUM(price), 0) 
         FROM tickets 
         WHERE DATE(purchased_at) = p_date) 
        + 
        (SELECT IFNULL(SUM(total), 0) 
         FROM orders 
         WHERE DATE(created_at) = p_date)
        AS total_revenue;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `register_user` (IN `p_firstname` VARCHAR(100), IN `p_lastname` VARCHAR(100), IN `p_email` VARCHAR(150), IN `p_password` VARCHAR(255), IN `p_phone` VARCHAR(20))   BEGIN
    INSERT INTO users (firstname, lastname, email, password, phone)
    VALUES (p_firstname, p_lastname, p_email, p_password, p_phone);
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
  `release_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `films`
--

INSERT INTO `films` (`id`, `title`, `duration_min`, `release_date`) VALUES
(1, 'A nagy kaland', 105, '2024-05-10'),
(2, 'Űrutazás', 130, '2023-11-01'),
(3, 'Rejtély a múltból', 110, '2025-03-15'),
(4, 'A tenger szíve', 125, '2024-07-20'),
(5, 'Szuperhős visszatér', 140, '2025-06-01'),
(6, 'Fények városa', 115, '2024-09-10'),
(7, 'A hegy titka', 128, '2025-02-22');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `orders`
--

CREATE TABLE `orders` (
  `id` int NOT NULL,
  `user_id` int NOT NULL,
  `total` decimal(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `order_product`
--

CREATE TABLE `order_product` (
  `id` int NOT NULL,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `quantity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `products`
--

CREATE TABLE `products` (
  `id` int NOT NULL,
  `name` varchar(100) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `price` decimal(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `products`
--

INSERT INTO `products` (`id`, `name`, `price`) VALUES
(1, 'small popcorn(0,5l)', 1600),
(2, 'medium popcorn(2,3l)', 1800),
(3, 'large popcorn(4,8l)', 2000),
(4, 'small drink(0,5l)', 1300),
(5, 'medium drink(0,75l)', 1500),
(6, 'large drink(1l)', 1700),
(7, 'medium nachos', 2200),
(8, 'large nachos', 2400),
(9, 'water(0,5l)', 900);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `screening`
--

CREATE TABLE `screening` (
  `id` int NOT NULL,
  `film_id` int NOT NULL,
  `start_time` time(6) NOT NULL,
  `price` decimal(10,0) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `screening`
--

INSERT INTO `screening` (`id`, `film_id`, `start_time`, `price`) VALUES
(1, 1, '16:00:00.000000', 3800),
(2, 1, '10:00:00.000000', 3800),
(3, 2, '16:00:00.000000', 4000),
(4, 2, '13:00:00.000000', 3800),
(5, 3, '16:00:00.000000', 4000),
(6, 3, '20:00:00.000000', 4000),
(7, 3, '10:00:00.000000', 3800),
(8, 3, '13:00:00.000000', 3800),
(9, 4, '10:00:00.000000', 3800),
(10, 4, '20:00:00.000000', 4000),
(11, 4, '13:00:00.000000', 3800),
(12, 5, '16:00:00.000000', 4000),
(13, 5, '13:00:00.000000', 3800),
(14, 5, '10:00:00.000000', 3800),
(15, 6, '20:00:00.000000', 4000),
(16, 6, '13:00:00.000000', 3800),
(17, 7, '10:00:00.000000', 3800),
(18, 7, '13:00:00.000000', 3800);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `tickets`
--

CREATE TABLE `tickets` (
  `id` int NOT NULL,
  `screening_id` int NOT NULL,
  `user_id` int NOT NULL,
  `seat` varchar(20) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `price` decimal(10,0) NOT NULL,
  `purchased_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
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
  `password` varchar(255) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `phone` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `films`
--
ALTER TABLE `films`
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
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `screening`
--
ALTER TABLE `screening`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `tickets`
--
ALTER TABLE `tickets`
  ADD PRIMARY KEY (`id`);

--
-- A tábla indexei `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `films`
--
ALTER TABLE `films`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT a táblához `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `order_product`
--
ALTER TABLE `order_product`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT a táblához `screening`
--
ALTER TABLE `screening`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- AUTO_INCREMENT a táblához `tickets`
--
ALTER TABLE `tickets`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
