-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Servidor: db:3306
-- Tiempo de generación: 11-09-2026 a las 20:02:27
-- Versión del servidor: 8.4.11
-- Versión de PHP: 8.3.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `farmayopin_db`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `carritos`
--

CREATE TABLE `carritos` (
  `id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `producto_id` int NOT NULL,
  `cantidad` int NOT NULL DEFAULT '1'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compras`
--

CREATE TABLE `compras` (
  `id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `total` decimal(10,2) NOT NULL DEFAULT '0.00',
  `fecha` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `compras`
--

INSERT INTO `compras` (`id`, `usuario_id`, `total`, `fecha`) VALUES
(1, 3, 2400.00, '2026-09-09 22:27:38'),
(2, 3, 420.00, '2026-09-10 23:42:44'),
(3, 3, 1704.00, '2026-09-10 23:50:21');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compra_items`
--

CREATE TABLE `compra_items` (
  `id` int NOT NULL,
  `compra_id` int NOT NULL,
  `producto_id` int NOT NULL,
  `cantidad` int NOT NULL DEFAULT '1',
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `compra_items`
--

INSERT INTO `compra_items` (`id`, `compra_id`, `producto_id`, `cantidad`, `precio_unitario`, `subtotal`) VALUES
(1, 1, 4, 4, 390.00, 1560.00),
(2, 1, 5, 2, 420.00, 840.00),
(3, 2, 5, 1, 420.00, 420.00),
(4, 3, 5, 4, 420.00, 1680.00),
(5, 3, 6, 2, 12.00, 24.00);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `medios_pago`
--

CREATE TABLE `medios_pago` (
  `id` int NOT NULL,
  `usuario_id` int NOT NULL,
  `tipo` varchar(20) NOT NULL DEFAULT 'credito',
  `marca` varchar(20) NOT NULL DEFAULT 'Visa',
  `numero_tarjeta` varchar(4) NOT NULL,
  `titular` varchar(100) NOT NULL,
  `vencimiento` varchar(7) NOT NULL,
  `fecha_creacion` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id` int NOT NULL,
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `detalle` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `foto` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stock` int NOT NULL DEFAULT '0',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `nombre`, `precio`, `detalle`, `foto`, `stock`, `creado_en`) VALUES
(1, 'Paracetamol 500mg', 180.00, 'Caja de 20 comprimidos', NULL, 50, '2026-09-07 23:32:49'),
(2, 'Ibuprofeno 400mg', 220.00, 'Caja de 10 capsulas blandas', NULL, 30, '2026-09-07 23:32:49'),
(3, 'Dermaglos Crema', 650.00, 'Hidratacion profunda 100g', NULL, 20, '2026-09-07 23:32:49'),
(4, 'Vitamina C 1g', 390.00, '10 tabletas efervescentes de calidad', NULL, 16, '2026-09-07 23:32:49'),
(5, 'su madre', 420.00, 'la mejor madre', 'prod_20260907_234547_29c1c3c2.jpg', 62, '2026-09-07 23:45:47'),
(6, 'lolll', 16.00, 'jasjjasaaaaa', 'prod_20260909_223111_f49e1b81.jpg', 20, '2026-09-09 22:31:11'),
(7, 'lol3', 58.00, 'jaja', 'prod_20260910_235128_fdfe905f.jpg', 131, '2026-09-10 23:51:28');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int NOT NULL,
  `nombre` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(150) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rol` enum('admin','cliente') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'cliente',
  `creado_en` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `email`, `password`, `rol`, `creado_en`) VALUES
(1, 'kevin chafe', 'kevinsacamedeaquiplis@gmail.com', '$2y$10$EpLZSeeMKs334tznMP8nE.Tm1COFJfFYFjC0mYBc24LyACwNwkrXG', 'cliente', '2026-09-06 21:12:52'),
(2, 'facundo salad berry', 'alexismenchaca2005@gmail.com', '$2y$10$7DLPBV68TNehPla4rcPmPeH/Z9.YnE6XHZ5lZObrMSCNEMwI6YoWy', 'cliente', '2026-09-06 21:50:37'),
(3, 'alexis', 'alexis@gmail.com', '$2y$10$a9zTSg4HFdnHdKt/DsFT9O9gnFSnu6SNXyI80uEZOjs/CCIU9NN56', 'cliente', '2026-09-06 23:02:59'),
(4, 'kevin', 'kevin@gmail.com', '$2y$10$TMbqKmdoMMZUqymCrUkndud9cLeCEVFzmqQJRlIfOm12V0LoL/ybS', 'cliente', '2026-09-06 23:14:24'),
(6, 'Administrador', 'admin@farmayopin.com', '$2y$10$u9XGzSaZcvlHPbfGnCNBte4csaG1EvQTqLOOw2zea6dwMcHj3.Sd6', 'admin', '2026-09-07 23:43:33');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `carritos`
--
ALTER TABLE `carritos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_carrito` (`usuario_id`,`producto_id`),
  ADD KEY `idx_carrito_producto` (`producto_id`);

--
-- Indices de la tabla `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_compras_usuario` (`usuario_id`);

--
-- Indices de la tabla `compra_items`
--
ALTER TABLE `compra_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_items_producto` (`producto_id`),
  ADD KEY `fk_items_compra` (`compra_id`);

--
-- Indices de la tabla `medios_pago`
--
ALTER TABLE `medios_pago`
  ADD PRIMARY KEY (`id`),
  ADD KEY `fk_medios_pago_usuario` (`usuario_id`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_usuarios_email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `carritos`
--
ALTER TABLE `carritos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `compras`
--
ALTER TABLE `compras`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `compra_items`
--
ALTER TABLE `compra_items`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `medios_pago`
--
ALTER TABLE `medios_pago`
  MODIFY `id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `carritos`
--
ALTER TABLE `carritos`
  ADD CONSTRAINT `fk_carrito_producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_carrito_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `fk_compras_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `compra_items`
--
ALTER TABLE `compra_items`
  ADD CONSTRAINT `fk_items_compra` FOREIGN KEY (`compra_id`) REFERENCES `compras` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_items_producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `medios_pago`
--
ALTER TABLE `medios_pago`
  ADD CONSTRAINT `fk_medios_pago_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
