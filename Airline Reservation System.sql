create database ARS;
use ARS;

-- Flights Table
CREATE TABLE Flights (
    flight_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_number VARCHAR(10) NOT NULL,
    departure_airport VARCHAR(50) NOT NULL,
    arrival_airport VARCHAR(50) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    total_seats INT NOT NULL
);

-- Passengers Table
CREATE TABLE Passengers (
    passenger_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

-- Bookings Table
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT,
    passenger_id INT,
    booking_date DATETIME NOT NULL,
    seat_number VARCHAR(10),
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES Passengers(passenger_id)
);

-- Schedules Table
CREATE TABLE Schedules (
    schedule_id INT PRIMARY KEY AUTO_INCREMENT,
    flight_id INT,
    flight_date DATE NOT NULL,
    status VARCHAR(20),
    FOREIGN KEY (flight_id) REFERENCES Flights(flight_id)
);

-- Flights Table[

INSERT INTO Flights (flight_number, departure_airport, arrival_airport, departure_time, arrival_time, total_seats)
VALUES
('AA101', 'JFK', 'LAX', '2024-07-15 08:00:00', '2024-07-15 11:00:00', 180),
('DL202', 'LAX', 'ORD', '2024-07-16 09:00:00', '2024-07-16 15:00:00', 200),
('UA303', 'ORD', 'DFW', '2024-07-17 10:00:00', '2024-07-17 12:30:00', 150);


-- Passengers Table

INSERT INTO Passengers (first_name, last_name, email, phone)
VALUES
('John', 'Doe', 'john.doe@example.com', '555-1234'),
('Jane', 'Smith', 'jane.smith@example.com', '555-5678'),
('Alice', 'Johnson', 'alice.johnson@example.com', '555-8765');

-- Bookings Table

INSERT INTO Bookings (flight_id, passenger_id, booking_date, seat_number)
VALUES
(1, 1, '2024-07-01 10:00:00', '12A'),
(1, 2, '2024-07-01 11:00:00', '14C'),
(2, 3, '2024-07-02 14:00:00', '22B');


-- Schedules Table

INSERT INTO Schedules (flight_id, flight_date, status)
VALUES
(1, '2024-07-15', 'On-Time'),
(2, '2024-07-16', 'Delayed'),
(3, '2024-07-17', 'On-Time');


-- Verifying the Data


-- Find Available Flights

SELECT 
    Flights.flight_id, 
    Flights.flight_number, 
    Flights.departure_airport, 
    Flights.arrival_airport, 
    Flights.departure_time, 
    Flights.arrival_time, 
    (Flights.total_seats - COALESCE(SUM(CASE WHEN Bookings.booking_date IS NOT NULL THEN 1 ELSE 0 END), 0)) AS available_seats
FROM 
    Flights
LEFT JOIN 
    Bookings ON Flights.flight_id = Bookings.flight_id
GROUP BY 
    Flights.flight_id
HAVING 
    available_seats > 0;

-- List Passengers on a Flight
SELECT 
    Passengers.passenger_id, 
    Passengers.first_name, 
    Passengers.last_name, 
    Passengers.email, 
    Passengers.phone
FROM 
    Bookings
JOIN 
    Passengers ON Bookings.passenger_id = Passengers.passenger_id
WHERE 
    Bookings.flight_id = 1;  -- Replace with the actual flight_id as needed

-- Calculate Occupancy Rates
SELECT 
    Flights.flight_id, 
    Flights.flight_number, 
    (COALESCE(SUM(CASE WHEN Bookings.booking_date IS NOT NULL THEN 1 ELSE 0 END), 0) / Flights.total_seats) * 100 AS occupancy_rate
FROM 
    Flights
LEFT JOIN 
    Bookings ON Flights.flight_id = Bookings.flight_id
GROUP BY 
    Flights.flight_id;

-- 1. Find All Flights Departing from a Specific Airport
SELECT 
    flight_id, 
    flight_number, 
    departure_airport, 
    arrival_airport, 
    departure_time, 
    arrival_time
FROM 
    Flights
WHERE 
    departure_airport = 'JFK';


-- 2. Find All Flights Arriving at a Specific Airport
SELECT 
    flight_id, 
    flight_number, 
    departure_airport, 
    arrival_airport, 
    departure_time, 
    arrival_time
FROM 
    Flights
WHERE 
    arrival_airport = 'LAX';


-- 3. Find the Next Scheduled Flight for a Specific Flight Number

SELECT 
    flight_id, 
    flight_number, 
    departure_airport, 
    arrival_airport, 
    departure_time, 
    arrival_time
FROM 
    Flights
WHERE 
    flight_number = 'AA101'
ORDER BY 
    departure_time ASC
LIMIT 1;

-- 4. Find All Bookings for a Specific Passenger

SELECT 
    Bookings.booking_id, 
    Flights.flight_number, 
    Bookings.booking_date, 
    Bookings.seat_number
FROM 
    Bookings
JOIN 
    Flights ON Bookings.flight_id = Flights.flight_id
WHERE 
    Bookings.passenger_id = 1;  -- Replace with the actual passenger_id as needed


-- 5. Calculate Total Seats Booked for Each Flight
SELECT 
    Flights.flight_id, 
    Flights.flight_number, 
    COUNT(Bookings.booking_id) AS total_booked_seats
FROM 
    Flights
LEFT JOIN 
    Bookings ON Flights.flight_id = Bookings.flight_id
GROUP BY 
    Flights.flight_id;

-- 6. List All Flights and Their Current Status
SELECT 
    Flights.flight_id, 
    Flights.flight_number, 
    Schedules.flight_date, 
    Schedules.status
FROM 
    Flights
JOIN 
    Schedules ON Flights.flight_id = Schedules.flight_id;


-- 7. Find Passengers with Multiple Bookings
SELECT 
    Passengers.passenger_id, 
    Passengers.first_name, 
    Passengers.last_name, 
    COUNT(Bookings.booking_id) AS total_bookings
FROM 
    Passengers
JOIN 
    Bookings ON Passengers.passenger_id = Bookings.passenger_id
GROUP BY 
    Passengers.passenger_id
HAVING 
    total_bookings > 1;


-- 8. Find Flights with Seats Available in a Specific Date Range

SELECT 
    Flights.flight_id, 
    Flights.flight_number, 
    Flights.departure_time, 
    Flights.arrival_time,
    (Flights.total_seats - COALESCE(SUM(CASE WHEN Bookings.booking_date IS NOT NULL THEN 1 ELSE 0 END), 0)) AS available_seats
FROM 
    Flights
LEFT JOIN 
    Bookings ON Flights.flight_id = Bookings.flight_id
WHERE 
    Flights.departure_time BETWEEN '2024-07-15 00:00:00' AND '2024-07-16 23:59:59'
GROUP BY 
    Flights.flight_id
HAVING 
    available_seats > 0;

-- 9. List Flights and Their Occupancy Rates
SELECT 
    Flights.flight_id, 
    Flights.flight_number, 
    (COALESCE(SUM(CASE WHEN Bookings.booking_date IS NOT NULL THEN 1 ELSE 0 END), 0) / Flights.total_seats) * 100 AS occupancy_rate
FROM 
    Flights
LEFT JOIN 
    Bookings ON Flights.flight_id = Bookings.flight_id
GROUP BY 
    Flights.flight_id;


-- 10. List All Passengers and Their Total Number of Flights

SELECT 
    Passengers.passenger_id, 
    Passengers.first_name, 
    Passengers.last_name, 
    COUNT(Bookings.booking_id) AS total_flights
FROM 
    Passengers
LEFT JOIN 
    Bookings ON Passengers.passenger_id = Bookings.passenger_id
GROUP BY 
    Passengers.passenger_id;


select * from flights;
select * from passengers;
select * from Bookings;
select * from Schedules;







