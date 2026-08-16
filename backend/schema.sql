-- ============================================
--  SUDHA WELLNESS — MYSQL SCHEMA
--  Database: u734872060_Sudhaweb
--  Import this in hPanel → Databases → phpMyAdmin
--  (Import tab → choose this file → Go)
-- ============================================

SET NAMES utf8mb4;
SET time_zone = '+00:00';

-- --------------------------------------------------
-- USERS
-- --------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` VARCHAR(64) NOT NULL,
  `first_name` VARCHAR(100) NOT NULL,
  `last_name` VARCHAR(100) DEFAULT '',
  `email` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `city` VARCHAR(100) DEFAULT '',
  `goal` VARCHAR(500) DEFAULT NULL,
  `whatsapp_consent` TINYINT(1) NOT NULL DEFAULT 1,
  `member_type` ENUM('FREE','VIP') NOT NULL DEFAULT 'FREE',
  `is_admin` TINYINT(1) NOT NULL DEFAULT 0,
  `temp_password_issued_at` DATETIME DEFAULT NULL,
  `joined_at` DATETIME NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_users_email` (`email`),
  KEY `idx_users_phone` (`phone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- SESSIONS (auth tokens stored as SHA-256 hash)
-- --------------------------------------------------
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `token` CHAR(64) NOT NULL,
  `user_id` VARCHAR(64) NOT NULL,
  `expires_at` DATETIME NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_sessions_token` (`token`),
  KEY `idx_sessions_user` (`user_id`),
  KEY `idx_sessions_expires` (`expires_at`),
  CONSTRAINT `fk_sessions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- REGISTRATIONS
-- --------------------------------------------------
CREATE TABLE IF NOT EXISTS `registrations` (
  `id` VARCHAR(64) NOT NULL,
  `user_id` VARCHAR(64) DEFAULT NULL,
  `name` VARCHAR(150) NOT NULL,
  `email` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) NOT NULL,
  `goal` VARCHAR(500) DEFAULT NULL,
  `reg_type` ENUM('FREE','VIP') NOT NULL DEFAULT 'FREE',
  `amount` DECIMAL(10,2) NOT NULL DEFAULT 0,
  `payment_id` VARCHAR(255) DEFAULT NULL,
  `payment_method` VARCHAR(50) DEFAULT NULL,
  `payment_status` ENUM('PENDING','SUCCESS','FAILED') DEFAULT NULL,
  `utr_id` VARCHAR(100) DEFAULT NULL,
  `zoom_link` TEXT DEFAULT NULL,
  `login_email` VARCHAR(255) DEFAULT NULL,
  `login_password` TEXT DEFAULT NULL COMMENT 'AES-256-GCM encrypted',
  `registered_at` DATETIME NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_reg_email` (`email`),
  KEY `idx_reg_phone` (`phone`),
  KEY `idx_reg_user` (`user_id`),
  CONSTRAINT `fk_reg_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- PAYMENTS
-- --------------------------------------------------
CREATE TABLE IF NOT EXISTS `payments` (
  `id` VARCHAR(255) NOT NULL,
  `registration_id` VARCHAR(64) DEFAULT NULL,
  `user_id` VARCHAR(64) DEFAULT NULL,
  `method` VARCHAR(50) NOT NULL,
  `amount_paise` INT UNSIGNED NOT NULL,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'INR',
  `status` VARCHAR(50) NOT NULL DEFAULT 'PENDING',
  `name` VARCHAR(150) DEFAULT NULL,
  `email` VARCHAR(255) DEFAULT NULL,
  `phone` VARCHAR(20) DEFAULT NULL,
  `phonepe_merchant_txn_id` VARCHAR(100) DEFAULT NULL,
  `phonepe_txn_id` VARCHAR(100) DEFAULT NULL,
  `raw_response` TEXT DEFAULT NULL,
  `verified_at` DATETIME DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pay_reg` (`registration_id`),
  KEY `idx_pay_user` (`user_id`),
  KEY `idx_pay_status` (`status`),
  KEY `idx_pay_phonepe_txn` (`phonepe_merchant_txn_id`),
  CONSTRAINT `fk_pay_reg` FOREIGN KEY (`registration_id`) REFERENCES `registrations` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_pay_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- WHATSAPP LOGS
-- --------------------------------------------------
CREATE TABLE IF NOT EXISTS `whatsapp_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `phone` VARCHAR(20) NOT NULL,
  `name` VARCHAR(150) DEFAULT NULL,
  `message` TEXT DEFAULT NULL,
  `provider` VARCHAR(20) DEFAULT 'meta',
  `message_id` VARCHAR(255) DEFAULT NULL,
  `success` TINYINT(1) NOT NULL DEFAULT 0,
  `error` VARCHAR(500) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_wa_phone` (`phone`),
  KEY `idx_wa_success` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------
-- EMAIL LOGS
-- --------------------------------------------------
CREATE TABLE IF NOT EXISTS `email_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `to_email` VARCHAR(255) NOT NULL,
  `subject` VARCHAR(500) DEFAULT '',
  `provider` VARCHAR(20) DEFAULT 'smtp',
  `message_id` VARCHAR(255) DEFAULT NULL,
  `success` TINYINT(1) NOT NULL DEFAULT 0,
  `error` VARCHAR(500) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_email_to` (`to_email`),
  KEY `idx_email_success` (`success`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
