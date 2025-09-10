-- Using consistent snake_case naming and adding AUTO_INCREMENT to all primary keys.

CREATE TABLE `lines` (
    `line_id` INT PRIMARY KEY AUTO_INCREMENT,
    `line_name` VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE `stations` (
    `station_id` INT PRIMARY KEY AUTO_INCREMENT,
    `station_name` VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE `employees` (
    `employee_id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(100) NOT NULL,
    `last_name` VARCHAR(100) NOT NULL,
    `position` VARCHAR(100)
);

CREATE TABLE `customers` (
    `customer_id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(100) NOT NULL,
    `last_name` VARCHAR(100) NOT NULL,
    `email` VARCHAR(255) UNIQUE
);

CREATE TABLE `carriages` (
    `carriage_id` INT PRIMARY KEY AUTO_INCREMENT,
    `carriage_code` VARCHAR(20) NOT NULL UNIQUE,
    `carriage_type` VARCHAR(100),
    `capacity` INT NOT NULL
);

CREATE TABLE `routes` (
    `route_id` INT PRIMARY KEY AUTO_INCREMENT,
    `route_name` VARCHAR(255) NOT NULL,
    `route_code` VARCHAR(20) UNIQUE,
    `line_id` INT NOT NULL,
    `origin_station_id` INT NOT NULL,
    `destination_station_id` INT NOT NULL,

    -- Foreign Key Definitions
    FOREIGN KEY (`line_id`) REFERENCES `lines`(`line_id`),
    FOREIGN KEY (`origin_station_id`) REFERENCES `stations`(`station_id`),
    FOREIGN KEY (`destination_station_id`) REFERENCES `stations`(`station_id`),

    -- Index for the Foreign Key
    INDEX `idx_line_id` (`line_id`)
);

CREATE TABLE `route_stations` (
    `route_id` INT NOT NULL,
    `station_id` INT NOT NULL,
    `stop_order` INT NOT NULL, -- Changed from station_number for clarity

    PRIMARY KEY (`route_id`, `station_id`),
    FOREIGN KEY (`route_id`) REFERENCES `routes`(`route_id`),
    FOREIGN KEY (`station_id`) REFERENCES `stations`(`station_id`),

    -- Index for the foreign key part not covered by the PK's leftmost column
    INDEX `idx_station_id` (`station_id`)
);

CREATE TABLE `train_trips` (
    `trip_id` INT PRIMARY KEY AUTO_INCREMENT,
    `route_id` INT NOT NULL,
    `trip_date` DATE NOT NULL,
    `status` VARCHAR(50) DEFAULT 'Scheduled',

    FOREIGN KEY (`route_id`) REFERENCES `routes`(`route_id`),

    -- Index for the Foreign Key
    INDEX `idx_route_id` (`route_id`)
);

CREATE TABLE `trip_carriages` (
    `trip_id` INT NOT NULL,
    `carriage_id` INT NOT NULL,
    `coupling_order` INT NOT NULL,

    PRIMARY KEY (`trip_id`, `carriage_id`),
    FOREIGN KEY (`trip_id`) REFERENCES `train_trips`(`trip_id`),
    FOREIGN KEY (`carriage_id`) REFERENCES `carriages`(`carriage_id`),

    -- Index for the Foreign Key part not covered by the PK
    INDEX `idx_carriage_id` (`carriage_id`)
);

CREATE TABLE `train_crews` (
    `trip_id` INT NOT NULL,
    `employee_id` INT NOT NULL,
    `role` VARCHAR(100),

    PRIMARY KEY (`trip_id`, `employee_id`),
    FOREIGN KEY (`trip_id`) REFERENCES `train_trips`(`trip_id`),
    FOREIGN KEY (`employee_id`) REFERENCES `employees`(`employee_id`),

    -- Index for the Foreign Key part not covered by the PK
    INDEX `idx_employee_id` (`employee_id`)
);

CREATE TABLE `tickets` (
    `ticket_id` INT PRIMARY KEY AUTO_INCREMENT,
    `trip_id` INT NOT NULL,
    `customer_id` INT NOT NULL,
    `booking_date` DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (`trip_id`) REFERENCES `train_trips`(`trip_id`),
    FOREIGN KEY (`customer_id`) REFERENCES `customers`(`customer_id`),

    -- Indexes for Foreign Keys
    INDEX `idx_trip_id` (`trip_id`),
    INDEX `idx_customer_id` (`customer_id`)
);

CREATE TABLE `ticket_carriages` (
    `ticket_id` INT NOT NULL,
    `carriage_id` INT NOT NULL,
    `seat_number` VARCHAR(10),

    PRIMARY KEY (`ticket_id`, `carriage_id`),
    FOREIGN KEY (`ticket_id`) REFERENCES `tickets`(`ticket_id`),
    FOREIGN KEY (`carriage_id`) REFERENCES `carriages`(`carriage_id`),

    -- Index for the Foreign Key part not covered by the PK
    INDEX `idx_carriage_id` (`carriage_id`)
);
