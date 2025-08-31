-- SK8 DEVELOPMENT - Street Credit Database Table
-- Run this SQL query to create the Street Credit table

CREATE TABLE IF NOT EXISTS `sk8_street_credit` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `identifier` varchar(255) NOT NULL,
    `points` int(11) NOT NULL DEFAULT 0,
    `level` int(11) NOT NULL DEFAULT 1,
    `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;