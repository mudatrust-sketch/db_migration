-- =============================================================================
-- SAMSTRUST TECHNOLOGIES LIMITED (RC 9898142)
-- Complete Production MySQL Database Schema & Initial Seed Script
-- Compatible with MySQL 5.7+ / 8.0+ & MariaDB 10.4+ (phpMyAdmin Ready)
-- =============================================================================

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+01:00";
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE DATABASE IF NOT EXISTS `samstrus_DB`
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE `samstrus_DB`;

-- =============================================================================
-- 1. TABLE: `users`
-- Admin, Staff, Live Desk Operators, Field Engineers & Registered Clients
-- =============================================================================
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_code` VARCHAR(32) NOT NULL,
  `full_name` VARCHAR(150) NOT NULL,
  `email` VARCHAR(190) NOT NULL,
  `phone` VARCHAR(45) DEFAULT NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `job_title` VARCHAR(150) DEFAULT NULL,
  `department` VARCHAR(150) DEFAULT NULL,
  `organization` VARCHAR(190) DEFAULT 'Samstrust Technologies Limited',
  `location` VARCHAR(150) DEFAULT 'Head Office, Ikeja, Lagos',
  `system_scope` ENUM('Both (CMS & Portal)', 'CMS Only', 'Enterprise Portal Only') NOT NULL DEFAULT 'Both (CMS & Portal)',
  `cms_role` ENUM('super-admin', 'live-desk-agent', 'editor', 'sales-reviewer', 'none') NOT NULL DEFAULT 'none',
  `portal_role` ENUM('portal-admin', 'accounts-sales', 'coordinator', 'technician', 'customer', 'none') NOT NULL DEFAULT 'customer',
  `can_manage_live_desk` TINYINT(1) NOT NULL DEFAULT 0,
  `custom_permissions` JSON DEFAULT NULL,
  `status` ENUM('Active', 'Suspended', 'Pending Activation') NOT NULL DEFAULT 'Active',
  `must_change_password` TINYINT(1) NOT NULL DEFAULT 1,
  `two_factor_required` TINYINT(1) NOT NULL DEFAULT 0,
  `two_factor_secret` VARCHAR(128) DEFAULT NULL,
  `failed_login_attempts` INT UNSIGNED NOT NULL DEFAULT 0,
  `locked_until` DATETIME DEFAULT NULL,
  `last_login_at` DATETIME DEFAULT NULL,
  `created_by` VARCHAR(150) DEFAULT 'System Bootstrap',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_users_user_code` (`user_code`),
  UNIQUE KEY `uk_users_email` (`email`),
  KEY `idx_users_roles` (`cms_role`, `portal_role`, `status`),
  KEY `idx_users_live_desk` (`can_manage_live_desk`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 2. TABLE: `categories`
-- Product Catalog & Gallery Media Category Management
-- =============================================================================
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slug` VARCHAR(80) NOT NULL,
  `label` VARCHAR(150) NOT NULL,
  `category_type` ENUM('product', 'gallery', 'both') NOT NULL DEFAULT 'both',
  `description` TEXT DEFAULT NULL,
  `icon_name` VARCHAR(60) DEFAULT 'Cpu',
  `display_order` INT UNSIGNED NOT NULL DEFAULT 1,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_categories_slug` (`slug`),
  KEY `idx_categories_type_order` (`category_type`, `is_active`, `display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 3. TABLE: `brand_partners`
-- Principal OEM Manufacturers & Authorized Technical Partners
-- =============================================================================
DROP TABLE IF EXISTS `brand_partners`;
CREATE TABLE `brand_partners` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `brand_code` VARCHAR(50) NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `country` VARCHAR(100) NOT NULL,
  `specialty` VARCHAR(200) NOT NULL,
  `tier` ENUM(
    'Principal OEM',
    'Authorized Distributor',
    'Certified Technical Partner',
    'Master OEM Partner',
    'Certified Metrology Channel',
    'Technology Alliance'
  ) NOT NULL DEFAULT 'Authorized Distributor',
  `website` VARCHAR(255) DEFAULT NULL,
  `description` TEXT DEFAULT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_brand_partners_code` (`brand_code`),
  UNIQUE KEY `uk_brand_partners_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 4. TABLE: `products`
-- Industrial Process & Laboratory Equipment Catalog
-- =============================================================================
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_code` VARCHAR(64) NOT NULL,
  `sku_model` VARCHAR(100) NOT NULL,
  `name` VARCHAR(220) NOT NULL,
  `category_id` INT UNSIGNED NOT NULL,
  `category_slug` VARCHAR(80) NOT NULL,
  `subcategory` VARCHAR(150) DEFAULT NULL,
  `brand_id` INT UNSIGNED DEFAULT NULL,
  `brand_name` VARCHAR(150) NOT NULL,
  `badge` VARCHAR(80) DEFAULT NULL,
  `price_estimate` VARCHAR(100) DEFAULT NULL,
  `unit_price_usd` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `stock_status` ENUM('In Stock (Lagos)', 'Ship 5-7 Days', 'Made to Order') NOT NULL DEFAULT 'In Stock (Lagos)',
  `iso_calibratable` TINYINT(1) NOT NULL DEFAULT 1,
  `short_description` TEXT NOT NULL,
  `primary_image_url` VARCHAR(500) NOT NULL,
  `datasheet_url` VARCHAR(500) DEFAULT NULL,
  `specifications_json` JSON DEFAULT NULL,
  `applications_json` JSON DEFAULT NULL,
  `compliance_standards_json` JSON DEFAULT NULL,
  `is_featured` TINYINT(1) NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_products_code` (`product_code`),
  UNIQUE KEY `uk_products_sku_model` (`sku_model`),
  KEY `idx_products_category` (`category_id`),
  KEY `idx_products_category_slug` (`category_slug`),
  KEY `idx_products_brand` (`brand_id`),
  KEY `idx_products_active_stock` (`is_active`, `stock_status`),
  CONSTRAINT `fk_products_category`
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
    ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_products_brand`
    FOREIGN KEY (`brand_id`) REFERENCES `brand_partners` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 5. TABLE: `gallery_images`
-- Media Library & Product/Facility Gallery Assets (PNG, JPG, JPEG, TIFF, WebP)
-- =============================================================================
DROP TABLE IF EXISTS `gallery_images`;
CREATE TABLE `gallery_images` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `asset_code` VARCHAR(64) NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `file_name` VARCHAR(255) NOT NULL,
  `file_url` LONGTEXT NOT NULL,
  `file_format` VARCHAR(40) NOT NULL DEFAULT 'JPG',
  `file_size_bytes` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `formatted_size` VARCHAR(40) DEFAULT '0 KB',
  `category_id` INT UNSIGNED DEFAULT NULL,
  `product_id` INT UNSIGNED DEFAULT NULL,
  `uploaded_by_user_id` INT UNSIGNED DEFAULT NULL,
  `is_public` TINYINT(1) NOT NULL DEFAULT 1,
  `uploaded_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_gallery_asset_code` (`asset_code`),
  KEY `idx_gallery_category` (`category_id`),
  KEY `idx_gallery_product` (`product_id`),
  KEY `idx_gallery_uploader` (`uploaded_by_user_id`),
  CONSTRAINT `fk_gallery_category`
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_gallery_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_gallery_uploader`
    FOREIGN KEY (`uploaded_by_user_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 6. TABLE: `hero_slides`
-- Homepage Hero Slider & Campaign Scheduler
-- =============================================================================
DROP TABLE IF EXISTS `hero_slides`;
CREATE TABLE `hero_slides` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `slide_code` VARCHAR(50) NOT NULL,
  `display_order` INT UNSIGNED NOT NULL DEFAULT 1,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `tag` VARCHAR(150) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `subtext` TEXT NOT NULL,
  `cta_text` VARCHAR(120) NOT NULL,
  `destination_tab` VARCHAR(60) NOT NULL DEFAULT 'catalog',
  `image_url` VARCHAR(500) NOT NULL,
  `stat_label` VARCHAR(100) DEFAULT NULL,
  `stat_value` VARCHAR(100) DEFAULT NULL,
  `spec_badge` VARCHAR(120) DEFAULT NULL,
  `start_date` DATE DEFAULT NULL,
  `end_date` DATE DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_hero_slides_code` (`slide_code`),
  KEY `idx_hero_slides_order` (`is_active`, `display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 7. TABLE: `services`
-- Engineering, Turnkey Lab Setup, Calibration & Maintenance Services
-- =============================================================================
DROP TABLE IF EXISTS `services`;
CREATE TABLE `services` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `service_code` VARCHAR(64) NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `tagline` VARCHAR(220) NOT NULL,
  `icon_name` VARCHAR(60) NOT NULL DEFAULT 'ShieldCheck',
  `description` TEXT NOT NULL,
  `deliverables_json` JSON NOT NULL,
  `standards_json` JSON NOT NULL,
  `turnaround_time` VARCHAR(120) NOT NULL,
  `display_order` INT UNSIGNED NOT NULL DEFAULT 1,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_services_code` (`service_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 8. TABLE: `calibration_scopes`
-- Accredited ISO/IEC 17025:2017 Metrology Capabilities Matrix
-- =============================================================================
DROP TABLE IF EXISTS `calibration_scopes`;
CREATE TABLE `calibration_scopes` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `scope_code` VARCHAR(50) NOT NULL,
  `domain_name` VARCHAR(150) NOT NULL,
  `reference_standards` VARCHAR(255) NOT NULL,
  `measurement_range` VARCHAR(180) NOT NULL,
  `reference_apparatus` VARCHAR(255) NOT NULL,
  `cmc_uncertainty` VARCHAR(150) NOT NULL,
  `deliverables` VARCHAR(255) NOT NULL,
  `display_order` INT UNSIGNED NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_calibration_scopes_code` (`scope_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 9. TABLE: `faqs`
-- Frequently Asked Technical, Calibration & Commercial Questions
-- =============================================================================
DROP TABLE IF EXISTS `faqs`;
CREATE TABLE `faqs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `faq_code` VARCHAR(50) NOT NULL,
  `category` ENUM('Calibration', 'Procurement', 'Field Dispatch', 'Compliance & Quality', 'Billing & Terms') NOT NULL DEFAULT 'Calibration',
  `question` VARCHAR(350) NOT NULL,
  `answer` TEXT NOT NULL,
  `display_order` INT UNSIGNED NOT NULL DEFAULT 1,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_faqs_code` (`faq_code`),
  KEY `idx_faqs_category_order` (`category`, `display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 10. TABLE: `customer_facilities`
-- Enterprise Client Plant Sites, Laboratories & SLA Accounts
-- =============================================================================
DROP TABLE IF EXISTS `customer_facilities`;
CREATE TABLE `customer_facilities` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `facility_code` VARCHAR(50) NOT NULL,
  `company_name` VARCHAR(200) NOT NULL,
  `rc_number` VARCHAR(60) DEFAULT NULL,
  `industry_sector` VARCHAR(120) NOT NULL,
  `primary_contact_name` VARCHAR(150) NOT NULL,
  `primary_contact_email` VARCHAR(190) NOT NULL,
  `primary_contact_phone` VARCHAR(50) NOT NULL,
  `head_office_address` VARCHAR(255) NOT NULL,
  `state_location` VARCHAR(100) NOT NULL,
  `sla_tier` ENUM('Platinum', 'Gold', 'Silver', 'Standard') NOT NULL DEFAULT 'Gold',
  `account_manager_id` INT UNSIGNED DEFAULT NULL,
  `sites_json` JSON DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_facilities_code` (`facility_code`),
  KEY `idx_facilities_company` (`company_name`),
  KEY `idx_facilities_manager` (`account_manager_id`),
  CONSTRAINT `fk_facilities_manager`
    FOREIGN KEY (`account_manager_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 11. TABLE: `equipment_assets`
-- Installed Client Equipment Registry, QR Passports & Calibration Validity
-- =============================================================================
DROP TABLE IF EXISTS `equipment_assets`;
CREATE TABLE `equipment_assets` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `asset_code` VARCHAR(50) NOT NULL,
  `serial_number` VARCHAR(100) NOT NULL,
  `qr_passport_code` VARCHAR(120) NOT NULL,
  `product_id` INT UNSIGNED DEFAULT NULL,
  `facility_id` INT UNSIGNED NOT NULL,
  `equipment_name` VARCHAR(220) NOT NULL,
  `sku_model` VARCHAR(100) NOT NULL,
  `manufacturer` VARCHAR(150) NOT NULL,
  `category_name` VARCHAR(120) NOT NULL,
  `plant_site_location` VARCHAR(220) NOT NULL,
  `install_date` DATE DEFAULT NULL,
  `last_calibration_date` DATE DEFAULT NULL,
  `next_calibration_due` DATE NOT NULL,
  `calibration_status` ENUM('Valid', 'Due Within 30 Days', 'Expired / Overdue', 'Under Service') NOT NULL DEFAULT 'Valid',
  `active_certificate_number` VARCHAR(100) DEFAULT NULL,
  `sla_tier` ENUM('Platinum', 'Gold', 'Silver', 'Standard') NOT NULL DEFAULT 'Gold',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_equipment_serial` (`serial_number`),
  UNIQUE KEY `uk_equipment_qr` (`qr_passport_code`),
  KEY `idx_equipment_facility` (`facility_id`),
  KEY `idx_equipment_product` (`product_id`),
  KEY `idx_equipment_cal_status` (`calibration_status`, `next_calibration_due`),
  CONSTRAINT `fk_equipment_facility`
    FOREIGN KEY (`facility_id`) REFERENCES `customer_facilities` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_equipment_product`
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 12. TABLE: `service_tickets`
-- Field Service Dispatch, On-Site Calibration & Breakdown SLA Tickets
-- =============================================================================
DROP TABLE IF EXISTS `service_tickets`;
CREATE TABLE `service_tickets` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ticket_number` VARCHAR(64) NOT NULL,
  `facility_id` INT UNSIGNED NOT NULL,
  `asset_id` INT UNSIGNED DEFAULT NULL,
  `equipment_serial` VARCHAR(100) NOT NULL,
  `equipment_name` VARCHAR(220) NOT NULL,
  `service_type` ENUM('On-site ISO Calibration', 'Emergency Breakdown', 'Preventive Maintenance (PPM)', 'Installation & IQ/OQ') NOT NULL,
  `urgency_rating` ENUM('Critical Shutdown', 'Urgent', 'Routine') NOT NULL DEFAULT 'Routine',
  `priority_label` VARCHAR(60) NOT NULL DEFAULT 'Standard (48-Hr SLA)',
  `sla_tier` ENUM('Platinum', 'Gold', 'Silver', 'Standard') NOT NULL DEFAULT 'Gold',
  `status` ENUM('Open / Triage', 'Assigned', 'In Progress', 'Awaiting Parts', 'Completed', 'Closed') NOT NULL DEFAULT 'Open / Triage',
  `assigned_technician_id` INT UNSIGNED DEFAULT NULL,
  `assigned_technician_name` VARCHAR(150) DEFAULT NULL,
  `scheduled_datetime` DATETIME DEFAULT NULL,
  `sla_deadline` DATETIME DEFAULT NULL,
  `sla_status` ENUM('Within SLA', 'At Risk (< 2 Hrs)', 'SLA Breached') NOT NULL DEFAULT 'Within SLA',
  `issue_description` TEXT NOT NULL,
  `error_code_logs` TEXT DEFAULT NULL,
  `ambient_conditions_json` JSON DEFAULT NULL,
  `reference_standards_used` VARCHAR(255) DEFAULT NULL,
  `issued_certificate_number` VARCHAR(100) DEFAULT NULL,
  `customer_signoff_json` JSON DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_service_tickets_number` (`ticket_number`),
  KEY `idx_tickets_facility` (`facility_id`),
  KEY `idx_tickets_asset` (`asset_id`),
  KEY `idx_tickets_tech` (`assigned_technician_id`),
  KEY `idx_tickets_status_sla` (`status`, `sla_status`),
  CONSTRAINT `fk_tickets_facility`
    FOREIGN KEY (`facility_id`) REFERENCES `customer_facilities` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_tickets_asset`
    FOREIGN KEY (`asset_id`) REFERENCES `equipment_assets` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_tickets_technician`
    FOREIGN KEY (`assigned_technician_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 13. TABLE: `calibration_certificates`
-- Official ISO/IEC 17025:2017 Traceable Calibration Certificates
-- =============================================================================
DROP TABLE IF EXISTS `calibration_certificates`;
CREATE TABLE `calibration_certificates` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `certificate_number` VARCHAR(80) NOT NULL,
  `asset_id` INT UNSIGNED DEFAULT NULL,
  `ticket_id` INT UNSIGNED DEFAULT NULL,
  `serial_number` VARCHAR(100) NOT NULL,
  `equipment_name` VARCHAR(220) NOT NULL,
  `sku_model` VARCHAR(100) NOT NULL,
  `customer_company` VARCHAR(200) NOT NULL,
  `facility_location` VARCHAR(220) NOT NULL,
  `calibration_date` DATE NOT NULL,
  `next_due_date` DATE NOT NULL,
  `technician_id` INT UNSIGNED DEFAULT NULL,
  `technician_name` VARCHAR(150) NOT NULL,
  `approving_metrologist` VARCHAR(150) NOT NULL DEFAULT 'Engr. Samuel O. Trust',
  `environmental_temp` VARCHAR(60) NOT NULL,
  `environmental_humidity` VARCHAR(60) NOT NULL,
  `barometric_pressure` VARCHAR(60) NOT NULL,
  `reference_standard_used` VARCHAR(255) NOT NULL,
  `traceability_nmi` VARCHAR(255) NOT NULL,
  `uncertainty_budget_k2` VARCHAR(150) NOT NULL,
  `compliance_standard` VARCHAR(255) NOT NULL,
  `work_report_summary` TEXT NOT NULL,
  `readings_json` JSON NOT NULL,
  `status` ENUM('Issued', 'Superseded', 'Revoked') NOT NULL DEFAULT 'Issued',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_certificates_number` (`certificate_number`),
  KEY `idx_certificates_serial` (`serial_number`),
  KEY `idx_certificates_asset` (`asset_id`),
  KEY `idx_certificates_ticket` (`ticket_id`),
  CONSTRAINT `fk_certificates_asset`
    FOREIGN KEY (`asset_id`) REFERENCES `equipment_assets` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_certificates_ticket`
    FOREIGN KEY (`ticket_id`) REFERENCES `service_tickets` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_certificates_tech`
    FOREIGN KEY (`technician_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 14. TABLE: `rfq_inquiries`
-- Website Request-for-Quotation (RFQ) Submissions & Lead Pipeline
-- =============================================================================
DROP TABLE IF EXISTS `rfq_inquiries`;
CREATE TABLE `rfq_inquiries` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ref_code` VARCHAR(64) NOT NULL,
  `client_name` VARCHAR(150) NOT NULL,
  `client_company` VARCHAR(200) NOT NULL,
  `client_email` VARCHAR(190) NOT NULL,
  `client_phone` VARCHAR(50) NOT NULL,
  `delivery_state` VARCHAR(100) NOT NULL,
  `delivery_address` VARCHAR(255) NOT NULL,
  `status` ENUM('New', 'Assigned', 'Quoted', 'Closed') NOT NULL DEFAULT 'New',
  `assigned_engineer_id` INT UNSIGNED DEFAULT NULL,
  `assigned_engineer_name` VARCHAR(150) DEFAULT NULL,
  `internal_notes` TEXT DEFAULT NULL,
  `total_usd` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `items_count` INT UNSIGNED NOT NULL DEFAULT 1,
  `line_items_json` JSON NOT NULL,
  `services_requested_json` JSON NOT NULL,
  `documents_attached_json` JSON DEFAULT NULL,
  `source_channel` ENUM('Website RFQ Builder', 'Live Chat Conversion', 'WhatsApp Desk', 'Direct Sales') NOT NULL DEFAULT 'Website RFQ Builder',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_rfq_ref_code` (`ref_code`),
  KEY `idx_rfq_status` (`status`, `created_at`),
  KEY `idx_rfq_engineer` (`assigned_engineer_id`),
  CONSTRAINT `fk_rfq_assigned_engineer`
    FOREIGN KEY (`assigned_engineer_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 15. TABLE: `quotes_invoices`
-- Commercial Quotations, Pro-Forma Tax Invoices & Payment Verification
-- =============================================================================
DROP TABLE IF EXISTS `quotes_invoices`;
CREATE TABLE `quotes_invoices` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `quote_ref` VARCHAR(64) NOT NULL,
  `proforma_invoice_ref` VARCHAR(64) NOT NULL,
  `rfq_id` INT UNSIGNED DEFAULT NULL,
  `linked_rfq_ref` VARCHAR(64) DEFAULT NULL,
  `facility_id` INT UNSIGNED DEFAULT NULL,
  `customer_company` VARCHAR(200) NOT NULL,
  `contact_name` VARCHAR(150) NOT NULL,
  `contact_email` VARCHAR(190) NOT NULL,
  `delivery_state` VARCHAR(100) NOT NULL,
  `line_items_json` JSON NOT NULL,
  `subtotal_usd` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `discount_percent` DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  `vat_percent` DECIMAL(5,2) NOT NULL DEFAULT 7.50,
  `total_usd` DECIMAL(14,2) NOT NULL DEFAULT 0.00,
  `exchange_rate_ngn` DECIMAL(12,2) NOT NULL DEFAULT 1485.00,
  `quote_status` ENUM('Draft', 'Sent for Approval', 'Customer Approved', 'Rejected') NOT NULL DEFAULT 'Sent for Approval',
  `payment_status` ENUM('Unpaid', 'Awaiting Verification', 'Verified & Paid') NOT NULL DEFAULT 'Unpaid',
  `payment_method` VARCHAR(100) DEFAULT 'Corporate PO (Net-30)',
  `payment_reference` VARCHAR(120) DEFAULT NULL,
  `issued_date` DATE NOT NULL,
  `valid_until` DATE NOT NULL,
  `notes` TEXT DEFAULT NULL,
  `verified_by_user_id` INT UNSIGNED DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_quotes_quote_ref` (`quote_ref`),
  UNIQUE KEY `uk_quotes_proforma_ref` (`proforma_invoice_ref`),
  KEY `idx_quotes_rfq` (`rfq_id`),
  KEY `idx_quotes_facility` (`facility_id`),
  KEY `idx_quotes_payment_status` (`payment_status`),
  CONSTRAINT `fk_quotes_rfq`
    FOREIGN KEY (`rfq_id`) REFERENCES `rfq_inquiries` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_quotes_facility`
    FOREIGN KEY (`facility_id`) REFERENCES `customer_facilities` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_quotes_verifier`
    FOREIGN KEY (`verified_by_user_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 16. TABLE: `contact_messages`
-- Public Contact Form Inquiries, Calibration Bookings & Dispatch Requests
-- =============================================================================
DROP TABLE IF EXISTS `contact_messages`;
CREATE TABLE `contact_messages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `message_ref` VARCHAR(64) NOT NULL,
  `sender_name` VARCHAR(150) NOT NULL,
  `company_name` VARCHAR(200) DEFAULT NULL,
  `email` VARCHAR(190) NOT NULL,
  `phone` VARCHAR(50) DEFAULT NULL,
  `inquiry_type` ENUM(
    'Equipment Quotation',
    'ISO/IEC 17025 Calibration',
    'Turnkey Lab Setup',
    'Emergency Field Service',
    'General Technical Inquiry'
  ) NOT NULL DEFAULT 'General Technical Inquiry',
  `plant_location_state` VARCHAR(100) DEFAULT NULL,
  `subject` VARCHAR(255) NOT NULL,
  `message_body` TEXT NOT NULL,
  `status` ENUM('Unread', 'Read', 'Responded', 'Archived') NOT NULL DEFAULT 'Unread',
  `handled_by_user_id` INT UNSIGNED DEFAULT NULL,
  `ip_address` VARCHAR(64) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_contact_messages_ref` (`message_ref`),
  KEY `idx_contact_status` (`status`, `created_at`),
  CONSTRAINT `fk_contact_handler`
    FOREIGN KEY (`handled_by_user_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 17. TABLE: `live_support_settings`
-- Admin-Controlled WhatsApp Live Desk & On-Site Live Chat Configuration
-- =============================================================================
DROP TABLE IF EXISTS `live_support_settings`;
CREATE TABLE `live_support_settings` (
  `id` TINYINT UNSIGNED NOT NULL DEFAULT 1,
  `whatsapp_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `live_chat_enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `default_active_channel` ENUM('whatsapp', 'livechat') NOT NULL DEFAULT 'livechat',
  `whatsapp_number` VARCHAR(40) NOT NULL DEFAULT '2348029844356',
  `desk_title` VARCHAR(150) NOT NULL DEFAULT 'Samstrust Engineering Support Desk',
  `agent_name` VARCHAR(150) NOT NULL DEFAULT 'Engr. Nnamdi Okoye',
  `agent_title` VARCHAR(150) NOT NULL DEFAULT 'Duty Metrology & Application Engineer',
  `agent_status_text` VARCHAR(150) NOT NULL DEFAULT 'Online • Ikeja & Port Harcourt Lab Hubs',
  `welcome_message` TEXT NOT NULL,
  `auto_reply_message` TEXT NOT NULL,
  `offline_notice_message` TEXT NOT NULL,
  `widget_position` ENUM('bottom-right', 'bottom-left') NOT NULL DEFAULT 'bottom-right',
  `show_on_mobile` TINYINT(1) NOT NULL DEFAULT 1,
  `quick_prompts_json` JSON NOT NULL,
  `updated_by_user_id` INT UNSIGNED DEFAULT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `fk_live_support_updater`
    FOREIGN KEY (`updated_by_user_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 18. TABLE: `live_chat_sessions`
-- Visitor On-Site Live Web Chat Sessions & Triage Status
-- =============================================================================
DROP TABLE IF EXISTS `live_chat_sessions`;
CREATE TABLE `live_chat_sessions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `session_code` VARCHAR(64) NOT NULL,
  `visitor_name` VARCHAR(150) NOT NULL,
  `visitor_email` VARCHAR(190) NOT NULL,
  `visitor_company` VARCHAR(200) DEFAULT 'Industrial Client',
  `visitor_phone` VARCHAR(50) DEFAULT NULL,
  `status` ENUM('Active', 'Resolved') NOT NULL DEFAULT 'Active',
  `unread_by_admin` INT UNSIGNED NOT NULL DEFAULT 0,
  `assigned_agent_user_id` INT UNSIGNED DEFAULT NULL,
  `converted_rfq_id` INT UNSIGNED DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_live_chat_session_code` (`session_code`),
  KEY `idx_live_chat_status` (`status`, `unread_by_admin`),
  CONSTRAINT `fk_live_chat_agent`
    FOREIGN KEY (`assigned_agent_user_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `fk_live_chat_rfq`
    FOREIGN KEY (`converted_rfq_id`) REFERENCES `rfq_inquiries` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 19. TABLE: `live_chat_messages`
-- Individual Messages within On-Site Live Chat Sessions
-- =============================================================================
DROP TABLE IF EXISTS `live_chat_messages`;
CREATE TABLE `live_chat_messages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `session_id` INT UNSIGNED NOT NULL,
  `sender_type` ENUM('visitor', 'agent', 'system') NOT NULL DEFAULT 'visitor',
  `sender_name` VARCHAR(150) NOT NULL,
  `message_text` TEXT NOT NULL,
  `sent_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_chat_messages_session` (`session_id`, `sent_at`),
  CONSTRAINT `fk_chat_messages_session`
    FOREIGN KEY (`session_id`) REFERENCES `live_chat_sessions` (`id`)
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 20. TABLE: `system_settings`
-- Global Application, Treasury, SLA & CMS Page Content Settings
-- =============================================================================
DROP TABLE IF EXISTS `system_settings`;
CREATE TABLE `system_settings` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `setting_key` VARCHAR(120) NOT NULL,
  `setting_group` ENUM('general', 'commercial', 'sla', 'cms_pages', 'security') NOT NULL DEFAULT 'general',
  `setting_value` LONGTEXT NOT NULL,
  `description` VARCHAR(255) DEFAULT NULL,
  `updated_by_user_id` INT UNSIGNED DEFAULT NULL,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_system_settings_key` (`setting_key`),
  CONSTRAINT `fk_settings_updater`
    FOREIGN KEY (`updated_by_user_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- 21. TABLE: `audit_logs`
-- Immutable SHA-256 Chained Security & Operational Audit Trail
-- =============================================================================
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `audit_code` VARCHAR(64) NOT NULL,
  `actor_user_id` INT UNSIGNED DEFAULT NULL,
  `actor_name` VARCHAR(150) NOT NULL,
  `actor_role` VARCHAR(60) NOT NULL,
  `action_description` VARCHAR(500) NOT NULL,
  `module_name` VARCHAR(100) NOT NULL,
  `target_ref` VARCHAR(100) DEFAULT NULL,
  `ip_address` VARCHAR(80) DEFAULT NULL,
  `severity` ENUM('Normal', 'Elevated', 'Critical') NOT NULL DEFAULT 'Normal',
  `integrity_hash_sha256` CHAR(64) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_audit_logs_code` (`audit_code`),
  KEY `idx_audit_actor` (`actor_user_id`),
  KEY `idx_audit_severity_date` (`severity`, `created_at`),
  CONSTRAINT `fk_audit_actor_user`
    FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`id`)
    ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- =============================================================================
-- INITIAL SEED DATA
-- =============================================================================

-- -----------------------------------------------------------------------------
-- Seed 1: `users`
-- Default Admin Email: admin@samstrusttech.com
-- Default Admin Password: Admin@ChangeMe123! (Bcrypt 12-round hash below)
-- -----------------------------------------------------------------------------
INSERT INTO `users` (
  `id`, `user_code`, `full_name`, `email`, `phone`, `password_hash`,
  `job_title`, `department`, `organization`, `location`,
  `system_scope`, `cms_role`, `portal_role`, `can_manage_live_desk`,
  `custom_permissions`, `status`, `must_change_password`, `two_factor_required`, `created_by`
) VALUES
(
  1,
  'USR-SAM-001',
  'Engr. Samuel O. Trust',
  'admin@samstrusttech.com',
  '+234 802 984 4356',
  '$2a$12$R9h/cIPz0gi.URNNX3kh2OPST9/PgBkqquzi.Ss7KIUgO2t0jWMUW',
  'Managing Director & Chief Metrologist',
  'Executive Governance & ISO 17025 Authority',
  'Samstrust Technologies Limited (RC 9898142)',
  'Head Office, Ikeja, Lagos',
  'Both (CMS & Portal)',
  'super-admin',
  'portal-admin',
  1,
  '["cms.livedesk.control","cms.slider.manage","cms.catalog.manage","cms.pages.manage","cms.services.manage","cms.rfq.triage","cms.users.manage","portal.assets.manage","portal.dispatch.assign","portal.calibration.certify","portal.quotes.approve","portal.rbac.manage","portal.audit.view"]',
  'Active',
  1,
  1,
  'System Bootstrap'
),
(
  2,
  'USR-SAM-002',
  'Aisha Bello',
  'editor@samstrusttech.com',
  '+234 803 551 2094',
  '$2a$12$8K1p/a0dL1LXMIgoEDFrwOfMQkF9/Y3Z9zJ6vQ8W5uK4nE1xG9v2C',
  'Senior Technical Marketing & Content Editor',
  'Corporate Communications & Product Documentation',
  'Samstrust Technologies Limited',
  'Ikeja HQ, Lagos',
  'CMS Only',
  'editor',
  'none',
  0,
  '["cms.slider.manage","cms.catalog.manage","cms.pages.manage","cms.services.manage"]',
  'Active',
  0,
  0,
  'Engr. Samuel O. Trust'
),
(
  3,
  'USR-SAM-003',
  'Chukwuma Eze',
  'sales@samstrusttech.com',
  '+234 802 984 4356',
  '$2a$12$4J9p/b2eM2MYNJhpFEGsxPgNRlG0/Z4A0aK7wR9X6vL5oF2yH0w3D',
  'Commercial Sales & Metrology Estimator',
  'Commercial Quotations & Proforma Billing',
  'Samstrust Technologies Limited',
  'Ikeja Head Office, Lagos',
  'Both (CMS & Portal)',
  'sales-reviewer',
  'accounts-sales',
  1,
  '["cms.rfq.triage","cms.livedesk.control","portal.quotes.approve","portal.assets.manage"]',
  'Active',
  0,
  1,
  'Engr. Samuel O. Trust'
),
(
  4,
  'USR-SAM-004',
  'Engr. Amina Suleiman',
  'a.suleiman@samstrusttech.com',
  '+234 809 412 8830',
  '$2a$12$7M2q/c3fN3NZOKiqGFHtyQhOSmH1/A5B1bL8xS0Y7wM6pG3zI1x4E',
  'Service Coordinator • Dispatch & SLA Planner',
  'National Service Operations Desk',
  'Samstrust Technologies Limited',
  'Ikeja HQ Operations Center, Lagos',
  'Enterprise Portal Only',
  'none',
  'coordinator',
  1,
  '["portal.dispatch.assign","portal.assets.manage","cms.livedesk.control"]',
  'Active',
  0,
  1,
  'Engr. Samuel O. Trust'
),
(
  5,
  'USR-SAM-005',
  'Engr. Nnamdi Okoye',
  'n.okoye@samstrusttech.com',
  '+234 806 778 1920',
  '$2a$12$9P4r/d4gO4OAPLjrHGIuzRiPTnI2/B6C2cM9yT1Z8xN7qH4aJ2y5F',
  'Senior Field Metrology Engineer (ISO/IEC 17025)',
  'Field Instrumentation & Calibration Bench',
  'Samstrust Technologies Limited',
  'Lagos & Port Harcourt Field Hubs',
  'Enterprise Portal Only',
  'none',
  'technician',
  0,
  '["portal.calibration.certify","portal.assets.manage"]',
  'Active',
  0,
  1,
  'Engr. Samuel O. Trust'
),
(
  6,
  'USR-CLI-006',
  'Dr. Chioma Nwachukwu',
  'c.nwachukwu@biozenith.com',
  '+234 802 334 1188',
  '$2a$12$2Q6s/e5hP5PBQMksIHJvaSjQUoJ3/C7D3dN0zU2A9yO8rI5bK3z6G',
  'Director of Quality Assurance & Regulatory Affairs',
  'Sterile QC & Stability Laboratories',
  'BioZenith Pharmaceuticals Ltd',
  'Ikeja Industrial Zone, Lagos',
  'Enterprise Portal Only',
  'none',
  'customer',
  0,
  '["portal.assets.manage","portal.quotes.approve"]',
  'Active',
  0,
  0,
  'Engr. Amina Suleiman'
),
(
  7,
  'USR-SAM-008',
  'Chioma Okonkwo',
  'livedesk@samstrusttech.com',
  '+234 802 984 4356',
  '$2a$12$5T8u/f6iQ6QCRNltJIKwbTkRVpK4/D8E4eO1aV3B0zP9sJ6cL4a7H',
  'WhatsApp Live Desk & Client Chat Coordinator',
  'Customer Support & Instant Technical Triage',
  'Samstrust Technologies Limited',
  'Ikeja HQ Support Desk, Lagos',
  'Both (CMS & Portal)',
  'live-desk-agent',
  'coordinator',
  1,
  '["cms.livedesk.control","cms.rfq.triage","portal.dispatch.assign"]',
  'Active',
  0,
  0,
  'Engr. Samuel O. Trust'
);

-- -----------------------------------------------------------------------------
-- Seed 2: `categories`
-- -----------------------------------------------------------------------------
INSERT INTO `categories` (`id`, `slug`, `label`, `category_type`, `description`, `icon_name`, `display_order`, `is_active`) VALUES
(1, 'flowmeters', 'Flow Measurement', 'both', 'Electromagnetic, Coriolis mass, ultrasonic, and vortex industrial flowmeters.', 'Gauge', 1, 1),
(2, 'viscometers', 'Viscometers & Rheology', 'both', 'Digital rotational viscometers and inline process rheology analyzers.', 'Activity', 2, 1),
(3, 'water-quality', 'Water & Liquid Analysis', 'both', 'Benchtop and inline pH, conductivity, dissolved oxygen, and turbidity analyzers.', 'Droplets', 3, 1),
(4, 'weighing-systems', 'Weighing & Force', 'both', 'Analytical microbalances, precision balances, checkweighers, and tank load cells.', 'Scale', 4, 1),
(5, 'cleanroom-fume', 'Cleanroom & Fume Hoods', 'both', 'EN 14175 VAV fume cupboards, Class II biosafety cabinets, and laminar flow benches.', 'Wind', 5, 1),
(6, 'spectrophotometers', 'Spectroscopy & Optics', 'both', 'UV-Vis double-beam scanning spectrophotometers and atomic absorption systems.', 'Microscope', 6, 1),
(7, 'thermal-chambers', 'Thermal & Stability', 'both', 'ICH Q1A climatic stability chambers, muffle furnaces, and class-B autoclaves.', 'Thermometer', 7, 1),
(8, 'process-control', 'Pressure, Temp & Valves', 'both', 'HART/Modbus differential pressure transmitters, RTD sensors, and pneumatic valves.', 'Cpu', 8, 1);

-- -----------------------------------------------------------------------------
-- Seed 3: `brand_partners`
-- -----------------------------------------------------------------------------
INSERT INTO `brand_partners` (`id`, `brand_code`, `name`, `country`, `specialty`, `tier`, `website`, `description`, `is_active`) VALUES
(1, 'BR-SAMSTRUST', 'Samstrust FlowTech', 'Nigeria / Germany', 'Electromagnetic & Ultrasonic Custody Transfer Flowmeters', 'Principal OEM', 'https://samstrusttech.com', 'Engineered industrial flow measurement systems calibrated for West African process utilities and oil/gas skids.', 1),
(2, 'BR-BROOKFIELD', 'Brookfield AMETEK Partner', 'USA', 'Rotational Viscometers, Rheometers & Texture Analyzers', 'Authorized Distributor', 'https://www.brookfieldengineering.com', 'Global benchmark in rotational viscosity measurement for pharmaceuticals, petrochemicals, and coatings.', 1),
(3, 'BR-METTLER', 'Mettler Toledo Channel', 'Switzerland', 'Analytical Balances, Process Weighing & Electrochemistry', 'Certified Metrology Channel', 'https://www.mt.com', 'Ultra-precision laboratory balances, industrial checkweighers, and Thornton pure water sensors.', 1),
(4, 'BR-ENDRESS', 'Endress+Hauser Partner', 'Switzerland / Germany', 'Process Automation, Coriolis Flow & Radar Level', 'Master OEM Partner', 'https://www.endress.com', 'Field process instrumentation for custody transfer, tank gauging, and hazardous area HART/Profibus loops.', 1),
(5, 'BR-SHIMADZU', 'Shimadzu Scientific', 'Japan', 'UV-Vis Spectrophotometers, HPLC & Analytical Optics', 'Authorized Distributor', 'https://www.shimadzu.com', 'Pharmacopeia-compliant optical spectroscopy and chromatographic instrumentation with 21 CFR Part 11 software.', 1),
(6, 'BR-BINDER', 'Memmert / Binder Germany', 'Germany', 'ICH Q1A Climatic Stability Chambers & Vacuum Ovens', 'Certified Technical Partner', 'https://www.binder-world.com', 'Precision environmental simulation chambers engineered for WHO Climactic Zone IVb pharmaceutical stability.', 1);

-- -----------------------------------------------------------------------------
-- Seed 4: `products`
-- -----------------------------------------------------------------------------
INSERT INTO `products` (
  `id`, `product_code`, `sku_model`, `name`, `category_id`, `category_slug`, `subcategory`,
  `brand_id`, `brand_name`, `badge`, `price_estimate`, `unit_price_usd`, `stock_status`,
  `iso_calibratable`, `short_description`, `primary_image_url`, `datasheet_url`,
  `specifications_json`, `applications_json`, `compliance_standards_json`, `is_featured`, `is_active`
) VALUES
(
  1,
  'prod-01',
  'ST-EMF-8000',
  'Electromagnetic Industrial Flowmeter',
  1,
  'flowmeters',
  'Inline Process Flow',
  1,
  'Samstrust FlowTech',
  'Best Seller',
  '$1,850 – $3,400',
  2450.00,
  'In Stock (Lagos)',
  1,
  'High-precision flanged electromagnetic flowmeter with PTFE/PFA lining and Hastelloy C electrodes for conductive liquids, slurries, and corrosive industrial effluents.',
  '/assets/aistudio/flowmeter_electromagnetic.png',
  '/docs/ST-EMF-8000-Datasheet.pdf',
  '{"Nominal Diameter":"DN15 to DN1200 (1/2\\" to 48\\")","Measuring Accuracy":"±0.2% of reading (Optional ±0.1% Custody Grade)","Liner Material":"PTFE / PFA / Neoprene / Polyurethane","Electrode Material":"316L SS, Hastelloy C-276, Titanium, Tantalum","Output & Protocol":"4-20mA + Pulse + HART 7.0 / Modbus RTU RS485","Ingress Protection":"IP68 Submersible Sensor / IP67 Transmitter"}',
  '["Municipal & Industrial Water Treatment Plants","Chemical & Acid Dosing Skids","Food & Beverage CIP Return Lines","Mining Slurry & Effluent Discharge Monitoring"]',
  '["ISO/IEC 17025:2017","ISO 9104","OIML R49","ATEX Ex d IIC T6"]',
  1,
  1
),
(
  2,
  'prod-02',
  'ST-VISC-PRO2',
  'Digital Rotational Laboratory Viscometer',
  2,
  'viscometers',
  'Rotational Rheology',
  2,
  'Brookfield AMETEK Partner',
  'ISO 17025 Ready',
  '$3,200 – $4,850',
  3650.00,
  'In Stock (Lagos)',
  1,
  '7-inch touchscreen programmable rotational viscometer with RTD temperature probe, 4-spindle LV/RV set, and 21 CFR Part 11 audit trail data logging.',
  '/assets/aistudio/viscometer_digital_lab.png',
  '/docs/ST-VISC-PRO2-Datasheet.pdf',
  '{"Viscosity Range":"1.0 to 6,000,000 mPa·s (cP)","Rotational Speed":"0.1 to 250 RPM Stepless Programmable","Measurement Accuracy":"±1.0% of full scale range","Repeatability":"±0.2%","Temperature Probe":"PT100 RTD (-20°C to +300°C, ±0.1°C)","Data Interface":"USB Host, RS232 LIMS & Thermal Micro-Printer"}',
  '["Pharmaceutical Syrups, Gels & Suspension QC","Paints, Coatings & Ink Formulation","Lubricating Oil & Bitumen Blending","Food Sauces, Dairy & Chocolate Rheology"]',
  '["ASTM D2196","ISO 2555","USP <912>","ISO/IEC 17025:2017"]',
  1,
  1
),
(
  3,
  'prod-03',
  'ST-LAB-PRECISION-04',
  'Analytical & Top-Loading Precision Balance (0.1mg)',
  4,
  'weighing-systems',
  'Analytical Weighing',
  3,
  'Mettler Toledo Channel',
  'USP <41> Compliant',
  '$1,650 – $2,950',
  1890.00,
  'In Stock (Lagos)',
  1,
  'Electromagnetic force restoration (EMFR) analytical balance with motorized draft shield, internal IsoCAL motorized calibration weight, and GLP/GMP print formatting.',
  '/assets/aistudio/analytical_balance_precision.png',
  '/docs/ST-LAB-PRECISION-04-Datasheet.pdf',
  '{"Weighing Capacity":"220 g / 320 g","Readability":"0.0001 g (0.1 mg)","Repeatability (sd)":"≤ 0.08 mg","Linearity Deviation":"≤ ±0.2 mg","Internal Calibration":"Fully Automatic Time & Temp Controlled IsoCAL","Stabilization Time":"≤ 1.5 seconds"}',
  '["Pharmaceutical Active Ingredient (API) Assay","Gravimetric Volumetric Glassware Verification","Reference Standard Preparation","University & Research Analytical Chemistry"]',
  '["USP <41> & <1251>","OIML Class I","GLP / GMP 21 CFR Part 11","ISO/IEC 17025:2017"]',
  1,
  1
),
(
  4,
  'prod-04',
  'ST-FUME-VAV-150',
  'Certified Laboratory Fume Cupboard & VAV Extraction System',
  5,
  'cleanroom-fume',
  'Containment & Extraction',
  1,
  'Samstrust FlowTech',
  'Turnkey Install',
  '$4,500 – $7,800',
  5200.00,
  'In Stock (Lagos)',
  1,
  'Aerodynamic Variable Air Volume (VAV) chemical fume hood with phenolic resin worktop, digital face-velocity alarm monitor, and PP centrifugal acid scrubber fan.',
  '/assets/aistudio/fume_hood_cleanroom.png',
  '/docs/ST-FUME-VAV-150-Datasheet.pdf',
  '{"External Width":"1200mm / 1500mm / 1800mm","Face Velocity Range":"0.30 to 0.60 m/s (Auto VAV Controlled at 0.50 m/s)","Worktop Material":"19mm Solid Epoxy / Trespa Toplab Plus Acid Resistant","Sash Window":"6mm Toughened Laminated Safety Glass with Counterbalance","Airflow Alarm":"Digital LCD Velocity Sensor with Audible/Visual Low-Flow Alarm","Ducting & Blower":"Anti-Corrosive PP Blower (1,800 m³/h) included"}',
  '["Acid Digestion & Wet Chemistry Laboratories","Petrochemical Assay & Solvent Extraction","Pharmaceutical QC & Toxicology Suites","University Teaching & Research Labs"]',
  '["EN 14175-1/2/3","ASHRAE 110-2016","OSHA 29 CFR 1910.1450","SON / NESREA Compliant"]',
  1,
  1
),
(
  5,
  'prod-05',
  'ST-UV-SCAN-2800',
  'UV-Visible Double Beam Scanning Spectrophotometer',
  6,
  'spectrophotometers',
  'Molecular Spectroscopy',
  5,
  'Shimadzu Scientific',
  '21 CFR Part 11',
  '$5,400 – $8,900',
  6400.00,
  'In Stock (Lagos)',
  1,
  'Research-grade double-beam Czerny-Turner UV-Vis spectrophotometer with variable spectral bandwidth (0.5–5.0nm), 8-cell automatic changer, and Pharmacopeia validation suite.',
  '/assets/aistudio/spectrophotometer_uv_vis.png',
  '/docs/ST-UV-SCAN-2800-Datasheet.pdf',
  '{"Wavelength Range":"190 nm to 1100 nm","Spectral Bandwidth":"0.5 / 1.0 / 2.0 / 4.0 nm Variable","Wavelength Accuracy":"±0.1 nm (at 656.1 nm D2 Peak)","Photometric Range":"-4.0 to +4.0 Abs (0 to 400% T)","Stray Light":"≤ 0.015% T at 220 nm (NaI) & 340 nm (NaNO2)","Light Source":"Pre-aligned Deuterium (D2) & Tungsten-Halogen Lamps"}',
  '["Pharmaceutical Dissolution & Assay Validation","Water & Environmental Heavy Metal Colorimetry","Food & Beverage Purity & Additive Testing","Academic Biochemistry & Kinetics Research"]',
  '["USP / EP / BP Pharmacopeia","21 CFR Part 11","ISO/IEC 17025:2017"]',
  1,
  1
),
(
  6,
  'prod-06',
  'ST-CLIM-ICH-500',
  'ICH Q1A Climatic Stability Chamber (Zone IVb)',
  7,
  'thermal-chambers',
  'Environmental Simulation',
  6,
  'Memmert / Binder Germany',
  'NAFDAC Audit Ready',
  '$7,200 – $12,500',
  8950.00,
  'Ship 5-7 Days',
  1,
  '500-Liter ultrasonic humidity and Peltier/compressor climatic test chamber engineered for long-term (30°C/75% RH) and accelerated (40°C/75% RH) ICH Q1A drug stability studies.',
  '/assets/aistudio/climatic_stability_chamber.png',
  '/docs/ST-CLIM-ICH-500-Datasheet.pdf',
  '{"Internal Volume":"500 Liters (SUS 316L Electropolished Interior)","Temperature Range":"+10.0°C to +85.0°C (±0.1°C Fluctuation)","Humidity Range":"20% to 95% RH (±1.5% RH Capacitive Sensor)","ICH Preset Profiles":"25°C/60%RH, 30°C/65%RH, 30°C/75%RH, 40°C/75%RH","Data Logging":"21 CFR Part 11 Ethernet Logger + 9-Point Mapping Port","Safety Protection":"Independent Class 3.1 Over/Under Temp & Water Level Cutout"}',
  '["Pharmaceutical ICH Q1A/Q1B Shelf-Life Stability","Cosmetic & Nutraceutical Accelerated Aging","Electronic Component Damp-Heat Qualification","Packaging Integrity & Moisture Permeation"]',
  '["ICH Q1A(R2) & WHO TRS 1010","FDA 21 CFR Part 11","DIN 12880","ISO/IEC 17025 (9-Point Mapped)"]',
  1,
  1
);

-- -----------------------------------------------------------------------------
-- Seed 5: `gallery_images`
-- -----------------------------------------------------------------------------
INSERT INTO `gallery_images` (
  `id`, `asset_code`, `title`, `description`, `file_name`, `file_url`,
  `file_format`, `file_size_bytes`, `formatted_size`, `category_id`, `product_id`, `uploaded_by_user_id`, `is_public`
) VALUES
(1, 'MED-SAM-001', 'Electromagnetic Custody Flowmeter Assembly', 'DN100 ANSI 300# flanged electromagnetic flowmeter on calibration loop.', 'flowmeter_electromagnetic.png', '/assets/aistudio/flowmeter_electromagnetic.png', 'PNG', 428032, '418 KB', 1, 1, 1, 1),
(2, 'MED-SAM-002', 'Digital Rotational Viscometer Bench', 'Touchscreen rotational viscometer with RTD temperature probe and spindle rack.', 'viscometer_digital_lab.png', '/assets/aistudio/viscometer_digital_lab.png', 'PNG', 389120, '380 KB', 2, 2, 1, 1),
(3, 'MED-SAM-003', 'Analytical 0.1mg Precision Balance', 'EMFR analytical microbalance inside cleanroom anti-vibration weighing enclosure.', 'analytical_balance_precision.png', '/assets/aistudio/analytical_balance_precision.png', 'PNG', 356352, '348 KB', 4, 3, 1, 1),
(4, 'MED-SAM-004', 'VAV Cleanroom Fume Cupboard Installation', '1500mm EN 14175 VAV fume extraction hood commissioned at pharmaceutical QC lab.', 'fume_hood_cleanroom.png', '/assets/aistudio/fume_hood_cleanroom.png', 'PNG', 512000, '500 KB', 5, 4, 1, 1),
(5, 'MED-SAM-005', 'Double-Beam UV-Vis Spectrophotometer', 'Optical wavelength and photometric linearity validation bench.', 'spectrophotometer_uv_vis.png', '/assets/aistudio/spectrophotometer_uv_vis.png', 'PNG', 401408, '392 KB', 6, 5, 1, 1),
(6, 'MED-SAM-006', 'ICH Q1A Climatic Stability Chamber', '500L Zone IVb pharmaceutical stability chamber undergoing 9-sensor thermal mapping.', 'climatic_stability_chamber.png', '/assets/aistudio/climatic_stability_chamber.png', 'PNG', 475136, '464 KB', 7, 6, 1, 1);

-- -----------------------------------------------------------------------------
-- Seed 6: `hero_slides`
-- -----------------------------------------------------------------------------
INSERT INTO `hero_slides` (
  `id`, `slide_code`, `display_order`, `is_active`, `tag`, `title`, `subtext`,
  `cta_text`, `destination_tab`, `image_url`, `stat_label`, `stat_value`, `spec_badge`
) VALUES
(
  1,
  'SLIDE-01',
  1,
  1,
  'ISO/IEC 17025:2017 TRACEABLE METROLOGY',
  'Precision Process Instrumentation & Analytical Laboratory Systems',
  'Supplying, commissioning, and calibrating high-accuracy flowmeters, rotational viscometers, analytical balances, and cleanroom containment across West Africa.',
  'Explore Equipment Catalog',
  'catalog',
  '/assets/aistudio/hero_industrial_metrology.png',
  'Calibration Uncertainty',
  '±0.05% CMC',
  'NIST / PTB Traceable Standards'
),
(
  2,
  'SLIDE-02',
  2,
  1,
  'TURNKEY LABORATORY & CLEANROOM ENGINEERING',
  'End-to-End QC Laboratory Setup, VAV Fume Hoods & IQ/OQ Validation',
  'From epoxy chemical-resistant casework and EN 14175 fume extraction to 21 CFR Part 11 spectroscopy and ICH Zone IVb stability rooms.',
  'View Engineering Services',
  'services',
  '/assets/aistudio/fume_hood_cleanroom.png',
  'Turnkey Labs Delivered',
  '140+ Facilities',
  'NAFDAC / WHO GMP Ready'
);

-- -----------------------------------------------------------------------------
-- Seed 7: `services`
-- -----------------------------------------------------------------------------
INSERT INTO `services` (
  `id`, `service_code`, `title`, `tagline`, `icon_name`, `description`,
  `deliverables_json`, `standards_json`, `turnaround_time`, `display_order`, `is_active`
) VALUES
(
  1,
  'SRV-CAL-17025',
  'ISO/IEC 17025 Accredited Calibration Services',
  'Lab & On-Site Traceable Metrology',
  'ShieldCheck',
  'Comprehensive multi-point As-Found and As-Left calibration across mass, volume, dimensional, pressure, flow, temperature, optical spectroscopy, and electrochemistry.',
  '["Traceable Calibration Certificate with Uncertainty Budget (k=2)","Tamper-Proof QR Metrology Passport Sticker","As-Found / As-Left Adjustment & Linearity Plot","Automated 30-Day Recall Notification"]',
  '["ISO/IEC 17025:2017","OIML R76 / Class E2 & F1","USP <41> & <912>","NIST / PTB Traceable"]',
  '24 – 72 Hours (Express On-Site Available)',
  1,
  1
),
(
  2,
  'SRV-TURNKEY-LAB',
  'Turnkey Laboratory Setup & Cleanroom Engineering',
  'Concept, Casework, HVAC & IQ/OQ Qualification',
  'Building2',
  'Complete design, supply, and commissioning of chemical, microbiological, and petrochemical testing laboratories including VAV fume cupboards, gas piping, and anti-vibration benches.',
  '["3D CAD Laboratory Layout & Utility Routing","EN 14175 VAV Fume Hoods & Acid Scrubber Ducting","Phenolic / Epoxy Worktops & Safety Showers","Full DQ / IQ / OQ / PQ Validation Dossier"]',
  '["EN 14175 / ASHRAE 110","ISO 14644 Cleanrooms","WHO GMP / NAFDAC Guidelines"]',
  '4 – 10 Weeks (Project Scope Dependent)',
  2,
  1
);

-- -----------------------------------------------------------------------------
-- Seed 8: `calibration_scopes`
-- -----------------------------------------------------------------------------
INSERT INTO `calibration_scopes` (
  `id`, `scope_code`, `domain_name`, `reference_standards`, `measurement_range`,
  `reference_apparatus`, `cmc_uncertainty`, `deliverables`, `display_order`
) VALUES
(1, 'CAL-MASS', 'Mass & Analytical Balances', 'OIML R111 / USP <41> / EURAMET cg-18', '1 mg to 3,000 kg', 'OIML Class E2 & F1 Stainless Reference Weight Sets', '±0.08 mg to ±0.01%', '10-Point Repeatability, Eccentricity & Linearity Cert', 1),
(2, 'CAL-FLOW', 'Liquid & Gas Flow Meters', 'ISO 4185 / ISO 9104 / API MPMS Ch 4', '0.05 L/min to 1,200 m³/h', 'Master Coriolis Prover Loop & Ultrasonic Transit-Time Standard', '±0.08% to ±0.20% Rdg', '5-Point Flow Linearity & K-Factor Trim Certificate', 2),
(3, 'CAL-THERM', 'Temperature & Stability Chambers', 'DIN 12880 / IEC 60068-3-5 / ICH Q1A', '-80 °C to +1,200 °C | 10% to 98% RH', '16-Channel Reference PRT Scanner & Chilled-Mirror Hygrometer', '±0.05 °C / ±0.8% RH', '9-Sensor 24-Hour Spatial Thermal/RH Mapping Report', 3),
(4, 'CAL-OPTIC', 'Optical & UV-Vis Spectroscopy', 'USP <857> / EP 2.2.25', '190 nm to 1,100 nm (0 to 3.0 Abs)', 'NIST SRM 2034 Holmium Oxide & Potassium Dichromate Filter Set', '±0.08 nm / ±0.003 Abs', 'Wavelength Accuracy, Stray Light & Photometric Cert', 4);

-- -----------------------------------------------------------------------------
-- Seed 9: `faqs`
-- -----------------------------------------------------------------------------
INSERT INTO `faqs` (`id`, `faq_code`, `category`, `question`, `answer`, `display_order`, `is_active`) VALUES
(1, 'FAQ-001', 'Calibration', 'Are your calibration certificates accepted during NAFDAC, SON, and ISO 9001/17025 audits?', 'Yes. Every Samstrust calibration certificate includes complete NMI traceability chains (NIST/PTB/NPL), environmental ambient logs, As-Found/As-Left tables, and expanded measurement uncertainty at k=2 (95% confidence) in strict compliance with ISO/IEC 17025:2017.', 1, 1),
(2, 'FAQ-002', 'Procurement', 'Can we pay in Nigerian Naira (NGN) or US Dollars (USD), and do you accept Corporate Purchase Orders?', 'Yes. Our quotation engine issues dual-currency Pro-Forma Tax Invoices in both USD and NGN. For verified corporate and multinational facilities, we support Net-30 Purchase Orders alongside wire transfers.', 2, 1),
(3, 'FAQ-003', 'Field Dispatch', 'Do your engineers travel outside Lagos for on-site calibration and emergency repair?', 'Yes. We operate technical hubs in Ikeja (Lagos) and Trans-Amadi (Port Harcourt), with mobile metrology teams deploying nationwide across Ogun, Rivers, Kano, Kaduna, Delta, Oyo, and Abuja FCT.', 3, 1);

-- -----------------------------------------------------------------------------
-- Seed 10: `customer_facilities`
-- -----------------------------------------------------------------------------
INSERT INTO `customer_facilities` (
  `id`, `facility_code`, `company_name`, `rc_number`, `industry_sector`,
  `primary_contact_name`, `primary_contact_email`, `primary_contact_phone`,
  `head_office_address`, `state_location`, `sla_tier`, `account_manager_id`, `sites_json`
) VALUES
(
  1,
  'FAC-SAM-01',
  'BioZenith Pharmaceuticals Ltd',
  'RC-441920',
  'Pharmaceuticals & Life Sciences',
  'Dr. Chioma Nwachukwu',
  'c.nwachukwu@biozenith.com',
  '+234 802 334 1188',
  'Plot 14 Oba Akran Industrial Estate, Ikeja, Lagos',
  'Lagos State',
  'Platinum',
  3,
  '["Ikeja Sterile QC Suite, Lagos","Sagamu API Manufacturing Plant, Ogun State"]'
),
(
  2,
  'FAC-SAM-02',
  'Atlantic Energy & Refining Group',
  'RC-882104',
  'Oil, Gas & Petrochemicals',
  'Engr. Babatunde Alabi',
  'babatunde.alabi@atlanticenergy.ng',
  '+234 803 910 4421',
  'Plot 42 Trans-Amadi Industrial Layout, Port Harcourt',
  'Rivers State',
  'Platinum',
  3,
  '["Onne Marine Terminal Skid B, Rivers State","Escravos Custody Metering Station, Delta State"]'
);

-- -----------------------------------------------------------------------------
-- Seed 11: `equipment_assets`
-- -----------------------------------------------------------------------------
INSERT INTO `equipment_assets` (
  `id`, `asset_code`, `serial_number`, `qr_passport_code`, `product_id`, `facility_id`,
  `equipment_name`, `sku_model`, `manufacturer`, `category_name`, `plant_site_location`,
  `install_date`, `last_calibration_date`, `next_calibration_due`, `calibration_status`,
  `active_certificate_number`, `sla_tier`
) VALUES
(
  1,
  'AST-001',
  'SN-ST-2025-8841',
  'QR-PASSPORT-SN-ST-2025-8841',
  3,
  1,
  'Analytical 0.1mg Precision Balance',
  'ST-LAB-PRECISION-04',
  'Mettler Toledo Channel',
  'Weighing & Force',
  'Grade B Cleanroom Lab, Ikeja Industrial Zone, Lagos',
  '2025-02-10',
  '2026-08-14',
  '2027-02-14',
  'Valid',
  'CERT-ISO17025-2026-0891',
  'Platinum'
),
(
  2,
  'AST-002',
  'SN-ST-2025-7730',
  'QR-PASSPORT-SN-ST-2025-7730',
  5,
  1,
  'UV-Visible Double Beam Scanning Spectrophotometer',
  'ST-UV-SCAN-2800',
  'Shimadzu Scientific',
  'Spectroscopy & Optics',
  'Assay QC Suite 3, Ikeja Industrial Zone, Lagos',
  '2025-04-18',
  '2026-04-20',
  '2026-11-15',
  'Due Within 30 Days',
  'CERT-ISO17025-2026-0412',
  'Platinum'
),
(
  3,
  'AST-003',
  'SN-ST-2024-4419',
  'QR-PASSPORT-SN-ST-2024-4419',
  1,
  2,
  'Electromagnetic Custody Transfer Flowmeter',
  'ST-EMF-8000',
  'Samstrust FlowTech',
  'Flow Measurement',
  'Onne Marine Terminal Skid B, Port Harcourt',
  '2024-11-05',
  '2026-09-19',
  '2027-03-19',
  'Valid',
  'CERT-ISO17025-2026-0765',
  'Platinum'
);

-- -----------------------------------------------------------------------------
-- Seed 12: `service_tickets`
-- -----------------------------------------------------------------------------
INSERT INTO `service_tickets` (
  `id`, `ticket_number`, `facility_id`, `asset_id`, `equipment_serial`, `equipment_name`,
  `service_type`, `urgency_rating`, `priority_label`, `sla_tier`, `status`,
  `assigned_technician_id`, `assigned_technician_name`, `scheduled_datetime`, `sla_deadline`,
  `sla_status`, `issue_description`, `error_code_logs`, `reference_standards_used`
) VALUES
(
  1,
  'SRV-SAM-2026-1094',
  1,
  2,
  'SN-ST-2025-7730',
  'UV-Visible Double Beam Scanning Spectrophotometer (ST-UV-SCAN-2800)',
  'On-site ISO Calibration',
  'Urgent',
  'High (12-Hr SLA)',
  'Platinum',
  'In Progress',
  5,
  'Engr. Nnamdi Okoye',
  '2026-10-31 09:00:00',
  '2026-10-31 18:00:00',
  'Within SLA',
  'Bi-annual optical wavelength accuracy (Holmium Oxide filter) and photometric linearity (Potassium Dichromate) ISO/IEC 17025 calibration ahead of NAFDAC Q4 GMP inspection.',
  'WARN-OPT-04: Deuterium Lamp Hours > 1,850h | Baseline Drift +0.003 Abs at 254nm',
  'NIST SRM 2034 Holmium Oxide Wavelength Standard & Potassium Dichromate Optical Filter Set'
);

-- -----------------------------------------------------------------------------
-- Seed 13: `calibration_certificates`
-- -----------------------------------------------------------------------------
INSERT INTO `calibration_certificates` (
  `id`, `certificate_number`, `asset_id`, `ticket_id`, `serial_number`, `equipment_name`,
  `sku_model`, `customer_company`, `facility_location`, `calibration_date`, `next_due_date`,
  `technician_id`, `technician_name`, `approving_metrologist`, `environmental_temp`,
  `environmental_humidity`, `barometric_pressure`, `reference_standard_used`,
  `traceability_nmi`, `uncertainty_budget_k2`, `compliance_standard`,
  `work_report_summary`, `readings_json`, `status`
) VALUES
(
  1,
  'CERT-ISO17025-2026-0891',
  1,
  NULL,
  'SN-ST-2025-8841',
  'Analytical 0.1mg Precision Balance',
  'ST-LAB-PRECISION-04',
  'BioZenith Pharmaceuticals Ltd',
  'Grade B Cleanroom Lab, Ikeja Industrial Zone, Lagos',
  '2026-08-14',
  '2027-02-14',
  5,
  'Engr. Nnamdi Okoye',
  'Engr. Samuel O. Trust',
  '20.6 °C',
  '45.0 % RH',
  '1013.5 hPa',
  'OIML Class E2 Primary Reference Mass Set (Cert #PTB-DE-2025-9921)',
  'PTB Germany / NIST Mass Standard Traceable',
  'U = 0.12 mg at k = 2 (95% Confidence)',
  'ISO/IEC 17025:2017, OIML R76 & USP <41>',
  '10-point repeatability, corner eccentricity, and 5-point linearity verification completed inside cleanroom enclosure. Internal motorized IsoCAL weight verified and adjusted to zero nominal drift.',
  '[{"pointNumber":1,"nominalValue":"10.0000 g","asFoundValue":"10.0001 g","asFoundError":"+0.1 mg","asLeftValue":"10.0000 g","asLeftError":"0.0 mg","expandedUncertainty":"±0.12 mg","toleranceLimit":"±0.5 mg","pass":true},{"pointNumber":2,"nominalValue":"100.0000 g","asFoundValue":"100.0002 g","asFoundError":"+0.2 mg","asLeftValue":"100.0000 g","asLeftError":"0.0 mg","expandedUncertainty":"±0.15 mg","toleranceLimit":"±0.5 mg","pass":true},{"pointNumber":3,"nominalValue":"200.0000 g","asFoundValue":"200.0003 g","asFoundError":"+0.3 mg","asLeftValue":"200.0001 g","asLeftError":"+0.1 mg","expandedUncertainty":"±0.20 mg","toleranceLimit":"±1.0 mg","pass":true}]',
  'Issued'
);

-- -----------------------------------------------------------------------------
-- Seed 14: `rfq_inquiries`
-- -----------------------------------------------------------------------------
INSERT INTO `rfq_inquiries` (
  `id`, `ref_code`, `client_name`, `client_company`, `client_email`, `client_phone`,
  `delivery_state`, `delivery_address`, `status`, `assigned_engineer_id`, `assigned_engineer_name`,
  `internal_notes`, `total_usd`, `items_count`, `line_items_json`, `services_requested_json`,
  `documents_attached_json`, `source_channel`
) VALUES
(
  1,
  'RFQ-SAM-2026-3195',
  'Dr. Chioma Nwachukwu',
  'BioZenith Pharmaceuticals Ltd',
  'c.nwachukwu@biozenith.com',
  '+234 802 334 1188',
  'Lagos State',
  'Plot 14 Oba Akran Industrial Estate, Ikeja, Lagos',
  'Quoted',
  3,
  'Chukwuma Eze',
  'Priority cleanroom expansion quote for NAFDAC sterile audit. Includes on-site EN 14175 validation.',
  9630.00,
  2,
  '[{"id":"prod-03","name":"Analytical & Top-Loading Precision Balance (0.1mg)","model":"ST-LAB-PRECISION-04","quantity":2,"unitPriceUSD":1890},{"id":"prod-04","name":"Certified Laboratory Fume Cupboard & VAV Extraction System","model":"ST-FUME-VAV-150","quantity":1,"unitPriceUSD":5200}]',
  '{"fatRequired":false,"installationRequired":true,"isoCalibrationRequired":true,"trainingRequired":true,"maintenanceSla":"Platinum 4-Hr SLA","deliveryTimeline":"Immediate (Ex-Stock Lagos)"}',
  '["BioZenith_Cleanroom_Floorplan_2026.pdf","URS_Analytical_Balances_V2.pdf"]',
  'Website RFQ Builder'
);

-- -----------------------------------------------------------------------------
-- Seed 15: `quotes_invoices`
-- -----------------------------------------------------------------------------
INSERT INTO `quotes_invoices` (
  `id`, `quote_ref`, `proforma_invoice_ref`, `rfq_id`, `linked_rfq_ref`, `facility_id`,
  `customer_company`, `contact_name`, `contact_email`, `delivery_state`, `line_items_json`,
  `subtotal_usd`, `discount_percent`, `vat_percent`, `total_usd`, `exchange_rate_ngn`,
  `quote_status`, `payment_status`, `payment_method`, `issued_date`, `valid_until`, `notes`
) VALUES
(
  1,
  'QT-SAM-2026-401',
  'PI-SAM-2026-901',
  1,
  'RFQ-SAM-2026-3195',
  1,
  'BioZenith Pharmaceuticals Ltd',
  'Dr. Chioma Nwachukwu',
  'c.nwachukwu@biozenith.com',
  'Lagos State',
  '[{"id":"li-1","description":"Analytical & Top-Loading Precision Laboratory Balances (0.0001g IsoCAL)","model":"ST-LAB-PRECISION-04","qty":2,"unitPriceUSD":1890},{"id":"li-2","description":"Certified Laboratory Fume Cupboard & VAV Extraction System (1500mm)","model":"ST-FUME-VAV-150","qty":1,"unitPriceUSD":5200},{"id":"li-3","description":"On-Site Installation, EN 14175 Validation & ISO/IEC 17025 Calibration Bundle","model":"SRV-ISO-BUNDLE","qty":1,"unitPriceUSD":650}]',
  9630.00,
  5.00,
  7.50,
  9834.64,
  1485.00,
  'Sent for Approval',
  'Unpaid',
  'Corporate PO (Net-30)',
  '2026-10-24',
  '2026-11-24',
  'Includes 12-Month Platinum SLA coverage, NAFDAC audit dossier, and 2-day operator training in Ikeja.'
);

-- -----------------------------------------------------------------------------
-- Seed 16: `contact_messages`
-- -----------------------------------------------------------------------------
INSERT INTO `contact_messages` (
  `id`, `message_ref`, `sender_name`, `company_name`, `email`, `phone`,
  `inquiry_type`, `plant_location_state`, `subject`, `message_body`, `status`, `handled_by_user_id`, `ip_address`
) VALUES
(
  1,
  'MSG-SAM-2026-001',
  'Engr. Kunle Adeyemi',
  'Lagos Water Corporation',
  'k.adeyemi@lagoswater.org',
  '+234 803 441 9082',
  'ISO/IEC 17025 Calibration',
  'Lagos State',
  'On-site Ultrasonic Prover Calibration for 6x DN600 Magmeters at Adiyan Waterworks',
  'We require an on-site ISO/IEC 17025 calibration team to verify six DN600 electromagnetic flowmeters at our Adiyan treatment plant ahead of our quarterly regulatory audit.',
  'Read',
  4,
  '197.210.54.118'
);

-- -----------------------------------------------------------------------------
-- Seed 17: `live_support_settings`
-- -----------------------------------------------------------------------------
INSERT INTO `live_support_settings` (
  `id`, `whatsapp_enabled`, `live_chat_enabled`, `default_active_channel`, `whatsapp_number`,
  `desk_title`, `agent_name`, `agent_title`, `agent_status_text`,
  `welcome_message`, `auto_reply_message`, `offline_notice_message`,
  `widget_position`, `show_on_mobile`, `quick_prompts_json`, `updated_by_user_id`
) VALUES
(
  1,
  1,
  1,
  'livechat',
  '2348029844356',
  'Samstrust Engineering Support Desk',
  'Engr. Nnamdi Okoye',
  'Duty Metrology & Application Engineer',
  'Online • Ikeja & Port Harcourt Lab Hubs',
  'Welcome to Samstrust Technologies Limited (RC 9898142). How can our metrology and instrumentation engineers assist your facility today?',
  'Thank you! Your technical inquiry has been logged on our Live Engineering Desk. A duty metrologist is reviewing your message now.',
  'Our live chat desk is currently offline. Please leave your details or message our 24/7 WhatsApp Engineering Desk.',
  'bottom-right',
  1,
  '["Request Pro-Forma Quote for Equipment","Book On-Site ISO/IEC 17025 Calibration","Verify Calibration Certificate / QR Passport","Emergency Plant Breakdown Dispatch"]',
  1
);

-- -----------------------------------------------------------------------------
-- Seed 18: `live_chat_sessions` & `live_chat_messages`
-- -----------------------------------------------------------------------------
INSERT INTO `live_chat_sessions` (
  `id`, `session_code`, `visitor_name`, `visitor_email`, `visitor_company`,
  `visitor_phone`, `status`, `unread_by_admin`, `assigned_agent_user_id`
) VALUES
(
  1,
  'CHAT-SAM-101',
  'Engr. Damilola Olatunji',
  'd.olatunji@westafricanpharma.ng',
  'West African Pharma Plc',
  '+234 803 771 2290',
  'Active',
  1,
  7
);

INSERT INTO `live_chat_messages` (`id`, `session_id`, `sender_type`, `sender_name`, `message_text`) VALUES
(1, 1, 'agent', 'Engr. Nnamdi Okoye', 'Welcome to Samstrust Technologies Limited (RC 9898142). How can our metrology and instrumentation engineers assist your facility today?'),
(2, 1, 'visitor', 'Engr. Damilola Olatunji', 'Good morning, we need urgent on-site calibration for two analytical balances (0.1mg) and one VAV fume hood at our Sagamu sterile plant next week.');

-- -----------------------------------------------------------------------------
-- Seed 19: `system_settings`
-- -----------------------------------------------------------------------------
INSERT INTO `system_settings` (`id`, `setting_key`, `setting_group`, `setting_value`, `description`, `updated_by_user_id`) VALUES
(1, 'exchange_rate_ngn_usd', 'commercial', '1485.00', 'Official USD to NGN conversion rate for dual-currency quotations and Pro-Forma invoices', 1),
(2, 'statutory_vat_percent', 'commercial', '7.50', 'Statutory Value Added Tax (VAT) percentage applied to commercial quotes', 1),
(3, 'calibration_recall_notice_days', 'sla', '30', 'Days prior to calibration certificate expiry to trigger automated client recall alerts', 1),
(4, 'certificate_number_prefix', 'sla', 'CERT-ISO17025-2026-', 'Prefix used when issuing new ISO/IEC 17025 calibration certificates', 1),
(5, 'sla_response_hours_json', 'sla', '{"platinum":4,"gold":12,"silver":48}', 'Target emergency field response SLA hours by facility contract tier', 1),
(6, 'strict_two_man_metrology_signoff', 'security', 'true', 'Require both performing field technician and Chief Metrologist sign-off before certificate release', 1);

-- -----------------------------------------------------------------------------
-- Seed 20: `audit_logs`
-- -----------------------------------------------------------------------------
INSERT INTO `audit_logs` (
  `id`, `audit_code`, `actor_user_id`, `actor_name`, `actor_role`,
  `action_description`, `module_name`, `target_ref`, `ip_address`,
  `severity`, `integrity_hash_sha256`
) VALUES
(
  1,
  'AUD-2026-0001',
  1,
  'Engr. Samuel O. Trust',
  'portal-admin',
  'Initialized Samstrust production database schema, seeded default Super Admin credentials, and enabled WhatsApp Live Desk & On-Site Live Chat controls.',
  'System & Security Governance',
  'SYS-BOOTSTRAP-01',
  '197.210.54.101 (Ikeja HQ)',
  'Critical',
  'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
),
(
  2,
  'AUD-2026-0002',
  3,
  'Chukwuma Eze',
  'accounts-sales',
  'Generated Pro-Forma Tax Invoice PI-SAM-2026-901 ($9,834.64 USD) from RFQ-SAM-2026-3195 for BioZenith Pharmaceuticals Ltd.',
  'Commercial & Invoicing',
  'PI-SAM-2026-901',
  '197.210.54.122 (Ikeja HQ)',
  'Normal',
  '8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4'
);

SET FOREIGN_KEY_CHECKS = 1;
COMMIT;