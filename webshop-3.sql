-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Gép: localhost:8889
-- Létrehozás ideje: 2025. Dec 01. 10:42
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_film` (IN `p_title` VARCHAR(200), IN `p_duration_minutes` INT, IN `p_release_date` DATE)   BEGIN
    INSERT INTO films (title, duration_min, release_date)
    VALUES (p_title, p_duration_minutes, p_release_date);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_order_product` (IN `p_order_id` INT, IN `p_product_id` INT, IN `p_quantity` INT)   BEGIN
    INSERT INTO order_product (order_id, product_id, quantity)
    VALUES (p_order_id, p_product_id, p_quantity);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_screening` (IN `p_film_id` INT, IN `p_start_time` TIME, IN `p_price` DECIMAL(10,0))   BEGIN
    INSERT INTO screening (film_id, start_time, price)
    VALUES (p_film_id, p_start_time, p_price);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buy_ticket` (IN `p_screening_id` INT, IN `p_user_id` INT, IN `p_price` DECIMAL(10,0))   BEGIN
    INSERT INTO tickets (screening_id, user_id, price, purchased_at)
    VALUES (p_screening_id, p_user_id, p_price, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `create_order` (IN `p_user_id` INT, IN `p_total` DECIMAL(10,0))   BEGIN
    INSERT INTO orders (user_id, total)
    VALUES (p_user_id, p_total);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_film` (IN `p_id` INT)   BEGIN
    DELETE FROM movies
    WHERE id = p_id;
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `register_user` (IN `p_firstname` VARCHAR(100), IN `p_lastname` VARCHAR(100), IN `p_email` VARCHAR(150), IN `p_password` VARCHAR(255), IN `p_phone` TEXT)   BEGIN
    INSERT INTO users (firstname, lastname, email, password, phone, created_at)
    VALUES (p_firstname, p_lastname, p_email, p_password, p_phone, NOW());
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_film` (IN `p_id` INT, IN `p_new_title` VARCHAR(200), IN `p_new_duration` INT, IN `p_new_release_date` DATE)   BEGIN
    UPDATE movies
    SET title = p_new_title,
        duration_min = p_new_duration,
        release_date = p_new_release_date
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
  `release_date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `films`
--

INSERT INTO `films` (`id`, `title`, `duration_min`, `release_date`) VALUES
(1, 'Gladiator II', 105, '2024-05-10'),
(2, 'Dune: Part Two', 130, '2023-11-01'),
(3, 'Deadpool & Wolverine', 110, '2025-03-15'),
(4, 'The First Omen', 125, '2024-07-20'),
(5, 'Furiosa', 140, '2025-06-01'),
(6, 'Challengers', 115, '2024-09-10');

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
-- Tábla szerkezet ehhez a táblához `prices`
--

CREATE TABLE `prices` (
  `id` int NOT NULL,
  `type` varchar(50) COLLATE utf8mb3_hungarian_ci NOT NULL,
  `price` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `prices`
--

INSERT INTO `prices` (`id`, `type`, `price`) VALUES
(1, 'Felnőtt', 4000),
(2, 'Diák/Nyugdíjas', 3600),
(3, 'Gyerek', 2000);

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
-- Tábla szerkezet ehhez a táblához `room`
--

CREATE TABLE `room` (
  `id` int NOT NULL,
  `room_id` int NOT NULL,
  `row_num` int NOT NULL,
  `column_num` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `room`
--

INSERT INTO `room` (`id`, `room_id`, `row_num`, `column_num`) VALUES
(1, 1, 1, 1),
(2, 1, 1, 2),
(3, 1, 1, 3),
(4, 1, 1, 4),
(5, 1, 1, 1),
(6, 1, 1, 6),
(7, 1, 1, 7),
(8, 1, 1, 8),
(9, 1, 1, 9),
(10, 1, 1, 10),
(11, 1, 2, 1),
(12, 1, 2, 2),
(13, 1, 2, 3),
(14, 1, 2, 4),
(15, 1, 2, 5),
(16, 1, 2, 6),
(17, 1, 2, 7),
(18, 1, 2, 8),
(19, 1, 2, 9),
(20, 1, 2, 10),
(21, 1, 3, 1),
(22, 1, 3, 2),
(23, 1, 3, 3),
(24, 1, 3, 4),
(25, 1, 3, 5),
(26, 1, 3, 6),
(27, 1, 3, 7),
(28, 1, 3, 8),
(29, 1, 3, 9),
(30, 1, 3, 10),
(31, 1, 4, 1),
(32, 1, 4, 2),
(33, 1, 4, 3),
(34, 1, 4, 4),
(35, 1, 4, 5),
(36, 1, 4, 6),
(37, 1, 4, 7),
(38, 1, 4, 8),
(39, 1, 4, 9),
(40, 1, 4, 10),
(41, 1, 5, 1),
(42, 1, 5, 2),
(43, 1, 5, 3),
(44, 1, 5, 4),
(45, 1, 5, 5),
(46, 1, 5, 6),
(47, 1, 5, 7),
(48, 1, 5, 8),
(49, 1, 5, 9),
(50, 1, 5, 10),
(51, 2, 1, 1),
(52, 2, 1, 2),
(53, 2, 1, 3),
(54, 2, 1, 4),
(55, 2, 1, 1),
(56, 2, 1, 6),
(57, 2, 1, 7),
(58, 2, 1, 8),
(59, 2, 1, 9),
(60, 2, 1, 10),
(61, 2, 2, 1),
(62, 2, 2, 2),
(63, 2, 2, 3),
(64, 2, 2, 4),
(65, 2, 2, 5),
(66, 2, 2, 6),
(67, 2, 2, 7),
(68, 2, 2, 8),
(69, 2, 2, 9),
(70, 2, 2, 10),
(71, 2, 3, 1),
(72, 2, 3, 2),
(73, 2, 3, 3),
(74, 2, 3, 4),
(75, 2, 3, 5),
(76, 2, 3, 6),
(77, 2, 3, 7),
(78, 2, 3, 8),
(79, 2, 3, 9),
(80, 2, 3, 10),
(81, 2, 4, 1),
(82, 2, 4, 2),
(83, 2, 4, 3),
(84, 2, 4, 4),
(85, 2, 4, 5),
(86, 2, 4, 6),
(87, 2, 4, 7),
(88, 2, 4, 8),
(89, 2, 4, 9),
(90, 2, 4, 10),
(91, 2, 5, 1),
(92, 2, 5, 2),
(93, 2, 5, 3),
(94, 2, 5, 4),
(95, 2, 5, 5),
(96, 2, 5, 6),
(97, 2, 5, 7),
(98, 2, 5, 8),
(99, 2, 5, 9),
(100, 2, 5, 10),
(101, 3, 1, 1),
(102, 3, 1, 2),
(103, 3, 1, 3),
(104, 3, 1, 4),
(105, 3, 1, 1),
(106, 3, 1, 6),
(107, 3, 1, 7),
(108, 3, 1, 8),
(109, 3, 1, 9),
(110, 3, 1, 10),
(111, 3, 2, 1),
(112, 3, 2, 2),
(113, 3, 2, 3),
(114, 3, 2, 4),
(115, 3, 2, 5),
(116, 3, 2, 6),
(117, 3, 2, 7),
(118, 3, 2, 8),
(119, 3, 2, 9),
(120, 3, 2, 10),
(121, 3, 3, 1),
(122, 3, 3, 2),
(123, 3, 3, 3),
(124, 3, 3, 4),
(125, 3, 3, 5),
(126, 3, 3, 6),
(127, 3, 3, 7),
(128, 3, 3, 8),
(129, 3, 3, 9),
(130, 3, 3, 10),
(131, 3, 4, 1),
(132, 3, 4, 2),
(133, 3, 4, 3),
(134, 3, 4, 4),
(135, 3, 4, 5),
(136, 3, 4, 6),
(137, 3, 4, 7),
(138, 3, 4, 8),
(139, 3, 4, 9),
(140, 3, 4, 10),
(141, 3, 5, 1),
(142, 3, 5, 2),
(143, 3, 5, 3),
(144, 3, 5, 4),
(145, 3, 5, 5),
(146, 3, 5, 6),
(147, 3, 5, 7),
(148, 3, 5, 8),
(149, 3, 5, 9),
(150, 3, 5, 10),
(151, 4, 1, 1),
(152, 4, 1, 2),
(153, 4, 1, 3),
(154, 4, 1, 4),
(155, 4, 1, 1),
(156, 4, 1, 6),
(157, 4, 1, 7),
(158, 4, 1, 8),
(159, 4, 1, 9),
(160, 4, 1, 10),
(161, 4, 2, 1),
(162, 4, 2, 2),
(163, 4, 2, 3),
(164, 4, 2, 4),
(165, 4, 2, 5),
(166, 4, 2, 6),
(167, 4, 2, 7),
(168, 4, 2, 8),
(169, 4, 2, 9),
(170, 4, 2, 10),
(171, 4, 3, 1),
(172, 4, 3, 2),
(173, 4, 3, 3),
(174, 4, 3, 4),
(175, 4, 3, 5),
(176, 4, 3, 6),
(177, 4, 3, 7),
(178, 4, 3, 8),
(179, 4, 3, 9),
(180, 4, 3, 10),
(181, 4, 4, 1),
(182, 4, 4, 2),
(183, 4, 4, 3),
(184, 4, 4, 4),
(185, 4, 4, 5),
(186, 4, 4, 6),
(187, 4, 4, 7),
(188, 4, 4, 8),
(189, 4, 4, 9),
(190, 4, 4, 10),
(191, 4, 5, 1),
(192, 4, 5, 2),
(193, 4, 5, 3),
(194, 4, 5, 4),
(195, 4, 5, 5),
(196, 4, 5, 6),
(197, 4, 5, 7),
(198, 4, 5, 8),
(199, 4, 5, 9),
(200, 4, 5, 10),
(201, 5, 1, 1),
(202, 5, 1, 2),
(203, 5, 1, 3),
(204, 5, 1, 4),
(205, 5, 1, 1),
(206, 5, 1, 6),
(207, 5, 1, 7),
(208, 5, 1, 8),
(209, 5, 1, 9),
(210, 5, 1, 10),
(211, 5, 2, 1),
(212, 5, 2, 2),
(213, 5, 2, 3),
(214, 5, 2, 4),
(215, 5, 2, 5),
(216, 5, 2, 6),
(217, 5, 2, 7),
(218, 5, 2, 8),
(219, 5, 2, 9),
(220, 5, 2, 10),
(221, 5, 3, 1),
(222, 5, 3, 2),
(223, 5, 3, 3),
(224, 5, 3, 4),
(225, 5, 3, 5),
(226, 5, 3, 6),
(227, 5, 3, 7),
(228, 5, 3, 8),
(229, 5, 3, 9),
(230, 5, 3, 10),
(231, 5, 4, 1),
(232, 5, 4, 2),
(233, 5, 4, 3),
(234, 5, 4, 4),
(235, 5, 4, 5),
(236, 5, 4, 6),
(237, 5, 4, 7),
(238, 5, 4, 8),
(239, 5, 4, 9),
(240, 5, 4, 10),
(241, 5, 5, 1),
(242, 5, 5, 2),
(243, 5, 5, 3),
(244, 5, 5, 4),
(245, 5, 5, 5),
(246, 5, 5, 6),
(247, 5, 5, 7),
(248, 5, 5, 8),
(249, 5, 5, 9),
(250, 5, 5, 10);

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `screening`
--

CREATE TABLE `screening` (
  `id` int NOT NULL,
  `film_id` int NOT NULL,
  `start_time` time(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_hungarian_ci;

--
-- A tábla adatainak kiíratása `screening`
--

INSERT INTO `screening` (`id`, `film_id`, `start_time`) VALUES
(1, 1, '16:00:00.000000'),
(2, 1, '10:00:00.000000'),
(3, 2, '16:00:00.000000'),
(4, 2, '13:00:00.000000'),
(5, 3, '16:00:00.000000'),
(6, 3, '20:00:00.000000'),
(7, 3, '10:00:00.000000'),
(8, 3, '13:00:00.000000'),
(9, 4, '10:00:00.000000'),
(10, 4, '20:00:00.000000'),
(11, 4, '13:00:00.000000'),
(12, 5, '16:00:00.000000'),
(13, 5, '13:00:00.000000'),
(14, 5, '10:00:00.000000'),
(15, 6, '20:00:00.000000'),
(16, 6, '13:00:00.000000'),
(17, 7, '10:00:00.000000'),
(18, 7, '13:00:00.000000');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `tickets`
--

CREATE TABLE `tickets` (
  `id` int NOT NULL,
  `screening_id` int NOT NULL,
  `user_id` int NOT NULL,
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
  `phone` text COLLATE utf8mb3_hungarian_ci NOT NULL,
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
-- A tábla indexei `room`
--
ALTER TABLE `room`
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
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT a táblához `orders`
--
ALTER TABLE `orders`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT a táblához `order_product`
--
ALTER TABLE `order_product`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT a táblához `prices`
--
ALTER TABLE `prices`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT a táblához `products`
--
ALTER TABLE `products`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT a táblához `room`
--
ALTER TABLE `room`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=251;

--
-- AUTO_INCREMENT a táblához `screening`
--
ALTER TABLE `screening`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT a táblához `tickets`
--
ALTER TABLE `tickets`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT a táblához `users`
--
ALTER TABLE `users`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
