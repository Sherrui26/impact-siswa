CREATE DATABASE IF NOT EXISTS impact_siswa
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_unicode_ci;

USE impact_siswa;

DROP TABLE IF EXISTS hour_logs;
DROP TABLE IF EXISTS event_registrations;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS affiliations;
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(120) NOT NULL,
    matric_no     VARCHAR(20)  NOT NULL UNIQUE,
    email         VARCHAR(120) NOT NULL UNIQUE,
    phone         VARCHAR(30)  NOT NULL,
    faculty       VARCHAR(120) NOT NULL,
    role          ENUM('student','club_leader','admin') NOT NULL DEFAULT 'student',
    password_hash VARCHAR(255) NOT NULL,
    total_hours   DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    created_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE categories (
    cat_id      INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(80) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE affiliations (
    affiliation_id INT AUTO_INCREMENT PRIMARY KEY,
    name           VARCHAR(120) NOT NULL,
    type           ENUM('faculty','club','unit') NOT NULL,
    active         BOOLEAN NOT NULL DEFAULT TRUE,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_affiliation_name_type (name, type)
) ENGINE=InnoDB;

CREATE TABLE events (
    event_id       INT AUTO_INCREMENT PRIMARY KEY,
    title          VARCHAR(160) NOT NULL,
    description    TEXT NOT NULL,
    cat_id         INT NOT NULL,
    event_date     DATE NOT NULL,
    location       VARCHAR(160) NOT NULL,
    hours          DECIMAL(5,2) NOT NULL,
    image_path     VARCHAR(255) NULL,
    max_volunteers INT NOT NULL DEFAULT 50,
    status         ENUM('open','closed','cancelled') NOT NULL DEFAULT 'open',
    created_by     INT NOT NULL,
    created_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_events_category FOREIGN KEY (cat_id) REFERENCES categories(cat_id),
    CONSTRAINT fk_events_creator FOREIGN KEY (created_by) REFERENCES users(user_id)
) ENGINE=InnoDB;

CREATE TABLE event_registrations (
    registration_id INT AUTO_INCREMENT PRIMARY KEY,
    event_id        INT NOT NULL,
    user_id         INT NOT NULL,
    status          ENUM('pending','approved','rejected','cancelled') NOT NULL DEFAULT 'pending',
    registered_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_event_user (event_id, user_id),
    CONSTRAINT fk_reg_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_reg_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE hour_logs (
    log_id        INT AUTO_INCREMENT PRIMARY KEY,
    user_id       INT NOT NULL,
    event_id      INT NOT NULL,
    hours_claimed DECIMAL(5,2) NOT NULL,
    evidence      TEXT,
    proof_image   VARCHAR(255) NULL,
    status        ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
    remarks       TEXT,
    approved_by   INT NULL,
    submitted_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_at   TIMESTAMP NULL,
    CONSTRAINT fk_log_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_log_event FOREIGN KEY (event_id) REFERENCES events(event_id) ON DELETE CASCADE,
    CONSTRAINT fk_log_approver FOREIGN KEY (approved_by) REFERENCES users(user_id)
) ENGINE=InnoDB;

INSERT INTO categories (name, description) VALUES
('Education', 'Tutoring, mentoring, and knowledge-sharing programmes'),
('Environment', 'Cleanup, recycling, tree planting, and sustainability activities'),
('Community', 'Food bank, welfare, and neighbourhood outreach'),
('Health', 'Awareness campaigns, blood donation, and wellbeing booths'),
('Leadership', 'Student leadership, event crews, and campus service');

INSERT INTO affiliations (name, type, active) VALUES
('Computer and Mathematical Sciences', 'faculty', TRUE),
('Engineering', 'faculty', TRUE),
('Business and Management', 'faculty', TRUE),
('Education', 'faculty', TRUE),
('Health Sciences', 'faculty', TRUE),
('Student Affairs Club', 'club', TRUE),
('Environmental Volunteer Club', 'club', TRUE),
('BHEPA Volunteer Unit', 'unit', TRUE),
('University Administration', 'unit', TRUE);

INSERT INTO users (full_name, matric_no, email, phone, faculty, role, password_hash, total_hours) VALUES
('BHEPA Administrator', 'ADMIN-001', 'admin@impact.edu.my', '03-5544 2200', 'University Administration', 'admin', '120000:vKcb+40t/NwgW3GKrOCeJA==:Mj5MNRz7V5QDc/queek3Zs8JntlJYm51kyhThg3l2wA=', 0.00),
('Muhammad Sharul Aiman', 'CLB-2026-02', 'leader@impact.edu.my', '019-555 7710', 'Student Affairs Club', 'club_leader', '120000:1kWVOWutsCfr98sno5QW6w==:JotbNwdxF2OiBF1UnihqE6ae8TDRTFPamrmtBXpNbsM=', 0.00),
('Nur Fadhlin Qistina', '2023349961', 'student@impact.edu.my', '013-555 4012', 'Computer and Mathematical Sciences', 'student', '120000:S/aghhr3wd4ErgAR0B66/A==:rHWxjZtf858O6DnQOL3GbNWFipusOCQ9jOluVTw19O4=', 42.50);

INSERT INTO events (title, description, cat_id, event_date, location, hours, max_volunteers, created_by) VALUES
('River Cleanup at Sungai Klang', 'Community cleanup activity with waste sorting and awareness briefing.', 2, '2026-07-06', 'Sungai Klang', 6.00, 60, 2),
('STEM Mentoring for Primary Students', 'Facilitate basic coding and science activities for school pupils.', 1, '2026-07-12', 'SK Seksyen 7', 4.00, 35, 2),
('Food Bank Packing Drive', 'Pack and distribute dry food supplies for nearby communities.', 3, '2026-07-19', 'Dewan Mawar', 5.00, 80, 1),
('Campus Health Awareness Booth', 'Assist with registration, booth operations, and health campaign outreach.', 4, '2026-08-02', 'Faculty Walkway', 3.00, 30, 1),
('Recycling Collection Weekend', 'Collect, label, and sort recyclable materials from residential colleges.', 2, '2026-08-11', 'College Zone A', 4.00, 50, 2);
