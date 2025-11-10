-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Nov 10, 2025 at 09:53 AM
-- Server version: 8.0.40
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `office_management`
--

-- --------------------------------------------------------

--
-- Table structure for table `categories`
--

CREATE TABLE `categories` (
  `category_id` int NOT NULL,
  `NAME` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `categories`
--

INSERT INTO `categories` (`category_id`, `NAME`) VALUES
(1, 'Writing '),
(2, 'Fasteners & Clips'),
(3, 'Paper & Notebooks'),
(4, 'Folders & Organizers'),
(5, 'Adhesives & Tapes'),
(6, 'Correction & Marking'),
(7, 'Cutting Tools');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_transactions`
--

CREATE TABLE `inventory_transactions` (
  `id` int NOT NULL,
  `order_id` int DEFAULT NULL,
  `transaction_type` varchar(50) NOT NULL,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `inventory_transactions`
--

INSERT INTO `inventory_transactions` (`id`, `order_id`, `transaction_type`, `created_at`) VALUES
(1, 1, 'sale', '2025-11-10 16:46:42');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_transaction_items`
--

CREATE TABLE `inventory_transaction_items` (
  `id` int NOT NULL,
  `transaction_id` int NOT NULL,
  `product_id` int NOT NULL,
  `variant_id` int DEFAULT NULL,
  `quantity_changed` int NOT NULL,
  `stock_after` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `inventory_transaction_items`
--

INSERT INTO `inventory_transaction_items` (`id`, `transaction_id`, `product_id`, `variant_id`, `quantity_changed`, `stock_after`) VALUES
(1, 1, 1, 31, -1, 19);

-- --------------------------------------------------------

--
-- Table structure for table `options`
--

CREATE TABLE `options` (
  `option_id` int NOT NULL,
  `option_type_id` int DEFAULT NULL,
  `category_id` int NOT NULL,
  `value` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `options`
--

INSERT INTO `options` (`option_id`, `option_type_id`, `category_id`, `value`) VALUES
(13, 1, 1, 'Black'),
(14, 1, 1, 'Blue'),
(15, 1, 1, 'Brown'),
(16, 1, 1, 'Green'),
(17, 1, 1, 'Red'),
(18, 1, 1, 'Yellow'),
(19, 2, 2, 'Small'),
(20, 2, 2, 'Medium'),
(21, 2, 2, 'Large'),
(22, 2, 2, 'Short'),
(23, 2, 2, 'Long'),
(24, 2, 2, 'None');

-- --------------------------------------------------------

--
-- Table structure for table `option_types`
--

CREATE TABLE `option_types` (
  `option_type_id` int NOT NULL,
  `name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `option_types`
--

INSERT INTO `option_types` (`option_type_id`, `name`) VALUES
(1, 'Color'),
(2, 'Size');

-- --------------------------------------------------------

--
-- Table structure for table `orders`
--

CREATE TABLE `orders` (
  `order_id` int NOT NULL,
  `employee_name` varchar(255) NOT NULL,
  `department` varchar(100) DEFAULT '',
  `status` varchar(50) DEFAULT 'pending',
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `orders`
--

INSERT INTO `orders` (`order_id`, `employee_name`, `department`, `status`, `created_at`) VALUES
(1, 'sad', 'HR', 'pending', '2025-11-10 16:46:42');

-- --------------------------------------------------------

--
-- Table structure for table `order_items`
--

CREATE TABLE `order_items` (
  `id` int NOT NULL,
  `order_id` int NOT NULL,
  `product_id` int NOT NULL,
  `variant_id` int DEFAULT NULL,
  `quantity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `order_items`
--

INSERT INTO `order_items` (`id`, `order_id`, `product_id`, `variant_id`, `quantity`) VALUES
(1, 1, 1, 31, 1);

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `product_id` int NOT NULL,
  `name` varchar(100) NOT NULL,
  `image` varchar(255) DEFAULT NULL,
  `category_id` int DEFAULT NULL,
  `quantity` int DEFAULT '0',
  `Date` timestamp NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`product_id`, `name`, `image`, `category_id`, `quantity`, `Date`) VALUES
(1, 'Ballpen', 'ballpen.png', 1, 49, '2025-11-09 09:55:10'),
(2, 'Binder Clip', 'item1.png', 2, 20, '2025-11-09 09:55:10'),
(3, 'Clearbook', 'item2.png', 4, 0, '2025-11-09 09:55:10'),
(4, 'Clear Folder', 'clearFolder.png', 4, 20, '2025-11-09 09:55:10'),
(5, 'Correction Tape', 'item3.png', 6, 10, '2025-11-09 09:55:10'),
(6, 'Envelope', 'item4.png', 4, 10, '2025-11-09 09:55:10'),
(7, 'Expanded Envelope', 'item5.png', 4, 20, '2025-11-09 09:55:10'),
(8, 'Fastener', 'item6.png', 2, 10, '2025-11-09 09:55:10'),
(9, 'Folder', 'folder.png', 4, 20, '2025-11-09 09:55:10'),
(10, 'Glue Stick', 'item7.png', 5, 20, '2025-11-09 09:55:10'),
(11, 'Highlighter', 'item22.png', 1, 20, '2025-11-09 09:55:10'),
(12, 'Masking Tape', 'item8.png', 5, 20, '2025-11-09 09:55:10'),
(13, 'Memo Pad', 'item9.png', 3, 20, '2025-11-09 09:55:10'),
(14, 'Packaging Tape', 'item10.png', 5, 20, '2025-11-09 09:55:10'),
(15, 'Paper Clip', 'item11.png', 2, 20, '2025-11-09 09:55:10'),
(16, 'Pentel Pen', 'item12.png', 1, 20, '2025-11-09 09:55:10'),
(17, 'Scissors', 'item13.png', 7, 20, '2025-11-09 09:55:10'),
(18, 'Scotch Tape', 'item14.png', 5, 20, '2025-11-09 09:55:10'),
(19, 'Sign Here', 'item15.png', 6, 20, '2025-11-09 09:55:10'),
(20, 'Sign Pen', 'item16.png', 1, 20, '2025-11-09 09:55:10'),
(21, 'Staple', 'item17.png', 2, 200, '2025-11-09 09:55:10'),
(22, 'Stapler', 'item18.png', 2, 20, '2025-11-09 09:55:10'),
(23, 'Steno Notebook', 'item19.png', 3, 20, '2025-11-09 09:55:10'),
(24, 'Sticky Note', 'item20.png', 3, 20, '0000-00-00 00:00:00'),
(25, 'Tape Dispenser', 'item21.png', 5, 10, '0000-00-00 00:00:00');

-- --------------------------------------------------------

--
-- Table structure for table `product_options`
--

CREATE TABLE `product_options` (
  `product_id` int NOT NULL,
  `option_id` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_options`
--

INSERT INTO `product_options` (`product_id`, `option_id`) VALUES
(1, 13),
(2, 13),
(3, 13),
(4, 13),
(5, 13),
(6, 13),
(7, 13),
(8, 13),
(9, 13),
(11, 13),
(13, 13),
(15, 13),
(16, 13),
(17, 13),
(18, 13),
(19, 13),
(20, 13),
(22, 13),
(23, 13),
(24, 13),
(1, 14),
(2, 14),
(3, 14),
(4, 14),
(5, 14),
(6, 14),
(7, 14),
(8, 14),
(9, 14),
(11, 14),
(13, 14),
(15, 14),
(16, 14),
(17, 14),
(18, 14),
(19, 14),
(20, 14),
(22, 14),
(23, 14),
(24, 14),
(1, 15),
(2, 15),
(3, 15),
(4, 15),
(5, 15),
(6, 15),
(7, 15),
(8, 15),
(9, 15),
(11, 15),
(13, 15),
(15, 15),
(16, 15),
(17, 15),
(18, 15),
(19, 15),
(20, 15),
(22, 15),
(23, 15),
(24, 15),
(1, 16),
(2, 16),
(3, 16),
(4, 16),
(5, 16),
(6, 16),
(7, 16),
(8, 16),
(9, 16),
(11, 16),
(13, 16),
(15, 16),
(16, 16),
(17, 16),
(18, 16),
(19, 16),
(20, 16),
(22, 16),
(23, 16),
(24, 16),
(1, 17),
(2, 17),
(3, 17),
(4, 17),
(5, 17),
(6, 17),
(7, 17),
(8, 17),
(9, 17),
(11, 17),
(13, 17),
(15, 17),
(16, 17),
(17, 17),
(18, 17),
(19, 17),
(20, 17),
(22, 17),
(23, 17),
(24, 17),
(1, 18),
(2, 18),
(3, 18),
(4, 18),
(5, 18),
(6, 18),
(7, 18),
(8, 18),
(9, 18),
(11, 18),
(13, 18),
(15, 18),
(16, 18),
(17, 18),
(18, 18),
(19, 18),
(20, 18),
(22, 18),
(23, 18),
(24, 18),
(3, 19),
(4, 19),
(6, 19),
(7, 19),
(9, 19),
(10, 19),
(12, 19),
(13, 19),
(14, 19),
(17, 19),
(21, 19),
(22, 19),
(23, 19),
(24, 19),
(25, 19),
(3, 20),
(4, 20),
(6, 20),
(7, 20),
(9, 20),
(10, 20),
(12, 20),
(13, 20),
(14, 20),
(17, 20),
(21, 20),
(22, 20),
(23, 20),
(24, 20),
(25, 20),
(3, 21),
(4, 21),
(6, 21),
(7, 21),
(9, 21),
(10, 21),
(12, 21),
(13, 21),
(14, 21),
(17, 21),
(21, 21),
(22, 21),
(23, 21),
(24, 21),
(25, 21),
(3, 22),
(4, 22),
(6, 22),
(7, 22),
(9, 22),
(10, 22),
(12, 22),
(13, 22),
(14, 22),
(17, 22),
(21, 22),
(22, 22),
(23, 22),
(24, 22),
(25, 22),
(3, 23),
(4, 23),
(6, 23),
(7, 23),
(9, 23),
(10, 23),
(12, 23),
(13, 23),
(14, 23),
(17, 23),
(21, 23),
(22, 23),
(23, 23),
(24, 23),
(25, 23),
(3, 24),
(6, 24),
(7, 24),
(9, 24),
(13, 24),
(17, 24),
(24, 24);

-- --------------------------------------------------------

--
-- Table structure for table `product_variants`
--

CREATE TABLE `product_variants` (
  `variant_id` int NOT NULL,
  `product_id` int NOT NULL,
  `color_option_id` int DEFAULT NULL,
  `size_option_id` int DEFAULT NULL,
  `stock` int DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `product_variants`
--

INSERT INTO `product_variants` (`variant_id`, `product_id`, `color_option_id`, `size_option_id`, `stock`, `created_at`) VALUES
(1, 1, 13, NULL, 50, '2025-11-09 15:37:00'),
(28, 1, 13, NULL, 20, '2025-11-09 15:41:36'),
(29, 1, NULL, NULL, 10, '2025-11-09 15:41:36'),
(30, 1, 15, NULL, 5, '2025-11-09 15:41:36'),
(31, 1, 16, NULL, 19, '2025-11-09 15:41:36'),
(32, 1, 17, NULL, 30, '2025-11-09 15:41:36'),
(33, 1, 18, NULL, 5, '2025-11-09 15:41:36'),
(34, 2, 13, NULL, 50, '2025-11-09 15:41:36'),
(35, 2, 18, NULL, 2, '2025-11-09 15:41:36'),
(36, 2, 14, NULL, 1, '2025-11-09 15:41:36'),
(37, 2, 15, NULL, 2, '2025-11-09 15:41:36'),
(38, 3, 13, 19, 22, '2025-11-09 15:41:36'),
(39, 3, 14, 21, 5, '2025-11-09 15:41:36'),
(40, 3, 15, 23, 0, '2025-11-09 15:41:36'),
(41, 4, 19, 15, 20, '2025-11-09 15:41:36'),
(42, 3, 15, 23, 20, '2025-11-09 15:41:36'),
(43, 5, 17, NULL, 20, '2025-11-09 15:41:36'),
(44, 6, 15, 22, 20, '2025-11-09 15:41:36'),
(45, 6, 17, 23, 20, '2025-11-09 15:41:36'),
(46, 6, 14, 22, 20, '2025-11-09 15:41:36'),
(47, 7, 15, 23, 20, '2025-11-09 15:41:36'),
(48, 8, 17, NULL, 20, '2025-11-09 15:41:36'),
(49, 8, 14, NULL, 10, '2025-11-09 15:41:36'),
(50, 9, 14, 23, 5, '2025-11-09 15:41:36'),
(51, 9, 16, 23, 10, '2025-11-09 15:41:36'),
(52, 10, NULL, 19, 5, '2025-11-09 15:41:36');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `categories`
--
ALTER TABLE `categories`
  ADD PRIMARY KEY (`category_id`);

--
-- Indexes for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `inventory_transaction_items`
--
ALTER TABLE `inventory_transaction_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `transaction_id` (`transaction_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `options`
--
ALTER TABLE `options`
  ADD PRIMARY KEY (`option_id`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `fk_option_optiontype` (`option_type_id`);

--
-- Indexes for table `option_types`
--
ALTER TABLE `option_types`
  ADD PRIMARY KEY (`option_type_id`);

--
-- Indexes for table `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`order_id`);

--
-- Indexes for table `order_items`
--
ALTER TABLE `order_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `order_id` (`order_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `variant_id` (`variant_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`product_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `product_options`
--
ALTER TABLE `product_options`
  ADD PRIMARY KEY (`product_id`,`option_id`),
  ADD KEY `option_id` (`option_id`);

--
-- Indexes for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD PRIMARY KEY (`variant_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `color_option_id` (`color_option_id`),
  ADD KEY `size_option_id` (`size_option_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `categories`
--
ALTER TABLE `categories`
  MODIFY `category_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `inventory_transactions`
--
ALTER TABLE `inventory_transactions`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `inventory_transaction_items`
--
ALTER TABLE `inventory_transaction_items`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `options`
--
ALTER TABLE `options`
  MODIFY `option_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT for table `option_types`
--
ALTER TABLE `option_types`
  MODIFY `option_type_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `orders`
--
ALTER TABLE `orders`
  MODIFY `order_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `order_items`
--
ALTER TABLE `order_items`
  MODIFY `id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `product_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT for table `product_variants`
--
ALTER TABLE `product_variants`
  MODIFY `variant_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=53;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `inventory_transaction_items`
--
ALTER TABLE `inventory_transaction_items`
  ADD CONSTRAINT `inventory_transaction_items_ibfk_1` FOREIGN KEY (`transaction_id`) REFERENCES `inventory_transactions` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `options`
--
ALTER TABLE `options`
  ADD CONSTRAINT `fk_option_optiontype` FOREIGN KEY (`option_type_id`) REFERENCES `option_types` (`option_type_id`),
  ADD CONSTRAINT `fk_option_type` FOREIGN KEY (`option_type_id`) REFERENCES `option_types` (`option_type_id`),
  ADD CONSTRAINT `options_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`);

--
-- Constraints for table `order_items`
--
ALTER TABLE `order_items`
  ADD CONSTRAINT `fk_order_items_order` FOREIGN KEY (`order_id`) REFERENCES `orders` (`order_id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `categories` (`category_id`);

--
-- Constraints for table `product_options`
--
ALTER TABLE `product_options`
  ADD CONSTRAINT `product_options_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `product_options_ibfk_2` FOREIGN KEY (`option_id`) REFERENCES `options` (`option_id`);

--
-- Constraints for table `product_variants`
--
ALTER TABLE `product_variants`
  ADD CONSTRAINT `product_variants_ibfk_1` FOREIGN KEY (`product_id`) REFERENCES `products` (`product_id`),
  ADD CONSTRAINT `product_variants_ibfk_2` FOREIGN KEY (`color_option_id`) REFERENCES `options` (`option_id`),
  ADD CONSTRAINT `product_variants_ibfk_3` FOREIGN KEY (`size_option_id`) REFERENCES `options` (`option_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
