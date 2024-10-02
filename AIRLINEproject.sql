--AIRLINE RESERVATION SYSTEM

--FLIGHT TABLE
CREATE TABLE flight(
    flight_id INT PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
	departure_airport VARCHAR(100) NOT NULL,
    arrival_airport VARCHAR(100) NOT NULL,
    departure_time DATETIME NOT NULL,
    arrival_time DATETIME NOT NULL,
    total_seats INT NOT NULL,
    available_seats INT NOT NULL
);

--PASSENGER TABLE
CREATE TABLE passengerss(
    passenger_id INT PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
	last_name VARCHAR(100) NOT NULL,
	passport_number VARCHAR(20) UNIQUE NOT NULL,
    frequent_flyer_status VARCHAR(20)
);

--BOOKING TABLE
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    flight_id INT,
    passenger_id INT,
    booking_date DATETIME,
    seat_number VARCHAR(5),
    status VARCHAR(20) DEFAULT 'Confirmed',
    FOREIGN KEY (flight_id) REFERENCES flight(flight_id),
    FOREIGN KEY (passenger_id) REFERENCES passengerss(passenger_id)
);

--PAYMENT TABLE
CREATE TABLE payments(
    payment_id INT PRIMARY KEY,
	booking_id INT,
	payment_date DATETIME,
	amount DECIMAL(10,2),
	payment_status VARCHAR(20) DEFAULT 'Completed',
	FOREIGN KEY (booking_id) REFERENCES Bookings(booking_id)
);

--INSERTING DATA
INSERT INTO flight (flight_id, flight_number, departure_airport, arrival_airport, departure_time, arrival_time, total_seats, available_seats)
VALUES
(101, 'AA123', 'JFK', 'LAX', '2024-09-15 07:00:00', '2024-09-15 10:00:00', 150, 10),
(102, 'AA456', 'JFK', 'LAX', '2024-09-15 12:00:00', '2024-09-15 15:00:00', 150, 0),  -- Overbooked
(103, 'UA789', 'JFK', 'ORD', '2024-09-15 09:00:00', '2024-09-15 11:00:00', 200, 25);

INSERT INTO passengerss (passenger_id, first_name, last_name, passport_number, frequent_flyer_status)
VALUES
(1, 'John', 'Doe', 'X12345678', 'Gold'),
(2, 'Jane', 'Smith', 'Y23456789', 'Silver'),
(3, 'Alice', 'Johnson', 'Z34567890', 'Bronze'),
(4, 'Bob', 'Brown', 'A45678901', 'Gold');

INSERT INTO Bookings (booking_id, flight_id, passenger_id, booking_date, seat_number, status)
VALUES
(201, 101, 1, '2024-09-01 10:00:00', '12A', 'Confirmed'),
(202, 101, 2, '2024-09-02 11:00:00', '12B', 'Confirmed'),
(203, 102, 3, '2024-09-03 09:00:00', '14A', 'Confirmed'),  -- Overbooked flight
(204, 103, 4, '2024-09-04 14:00:00', '18C', 'Confirmed');

INSERT INTO Payments (payment_id, booking_id, payment_date, amount, payment_status)
VALUES
(301, 201, '2024-09-01 11:00:00', 300.00, 'Completed'),
(302, 202, '2024-09-02 12:00:00', 300.00, 'Completed'),
(303, 203, '2024-09-03 10:00:00', 300.00, 'Pending'),
(304, 204, '2024-09-04 15:00:00', 400.00, 'Completed');

--Retrive available flights between two airports
SELECT flight_number,departure_time,arrival_time,available_seats FROM flight
WHERE departure_airport='JFK'
AND arrival_airport='LAX'
AND available_seats > 0;

INSERT INTO Bookings (booking_id,flight_id, passenger_id, booking_date, seat_number)
VALUES (5,101, 1,'2024-09-15 10:00:00' , '12A');

UPDATE flight
SET available_seats = available_seats - 1
WHERE flight_id = 101;

UPDATE Bookings
SET status = 'Cancelled'
WHERE booking_id = 202;

-- Update available seats
UPDATE flight
SET available_seats = available_seats + 1
WHERE flight_id = (SELECT flight_id FROM Bookings WHERE booking_id = 5);

SELECT * FROM flight;
SELECT * FROM Bookings;
SELECT * FROM passengerss;
SELECT * FROM payments;

--get passenger booking detail
SELECT b.booking_id, f.flight_number, f.departure_airport, f.arrival_airport, f.departure_time, b.seat_number, b.status
FROM Bookings b
JOIN flight f ON b.flight_id = f.flight_id
JOIN passengerss p ON b.passenger_id = p.passenger_id
WHERE p.passport_number = 'X12345678';

SELECT b.booking_id, f.flight_number, f.departure_airport, f.arrival_airport, f.departure_time, b.seat_number, b.status
FROM Bookings b
JOIN flight f ON b.flight_id = f.flight_id
JOIN passengerss p ON b.passenger_id = p.passenger_id
WHERE p.passport_number = 'Y23456789';

--Count Total Bookings for a Specific Flight
SELECT COUNT(booking_id) AS total_booking
FROM Bookings
WHERE flight_id = 103
AND status = 'Confirmed'

--Get Flights with More Than a Certain Number of Available Seats
SELECT flight_number, available_seats
FROM flight
WHERE available_seats > 10;

--List Passengers with Priority Status (Gold/Silver) on a Specific Flight
SELECT p.first_name , p.last_name ,p.frequent_flyer_status
FROM passengerss p
JOIN Bookings b ON p.passenger_id = b.passenger_id
WHERE b.flight_id = 101
AND p.frequent_flyer_status IN ('Gold', 'Silver')
AND b.status = 'Confirmed';

--ADDING NEW FEATURES : 
--Table: FrequentFlyerPoints
--Stores the points each frequent flyer has earned and their status.
CREATE TABLE FrequentFlyerPoints (
    passenger_id INT PRIMARY KEY,
    points INT DEFAULT 0,
    tier_status VARCHAR(50), -- e.g., Silver, Gold, Platinum
    FOREIGN KEY (passenger_id) REFERENCES passengerss(passenger_id)
);
INSERT INTO FrequentFlyerPoints (passenger_id, points, tier_status)
VALUES (1, 500, 'Silver'),
       (2, 1200, 'Gold'),
       (3, 2500, 'Platinum');

--FlightClassPoints Table
--This table will define the points awarded based on flight class.
CREATE TABLE FlightClassPoints (
    class_id INT PRIMARY KEY ,
    class_name VARCHAR(50), -- e.g., Economy, Business, First
    points_multiplier DECIMAL(3, 2) -- e.g., 1.0 for Economy, 1.5 for Business, 2.0 for First
);
INSERT INTO FlightClassPoints (class_id,class_name, points_multiplier)
VALUES (1,'Economy', 1.0),
       (2,'Business', 1.5),
       (3,'First', 2.0);
--Table: PointsCriteria
--Defines criteria for earning points (e.g., miles flown, ticket price).
CREATE TABLE PointsCriteria (
    criteria_id INT PRIMARY KEY ,
    criteria_name VARCHAR(100), -- e.g., "Miles Flown", "Ticket Price", "Partner Purchases"
    points_per_unit DECIMAL(10, 2), -- Points earned per unit (e.g., per mile, per dollar)
    description TEXT
);
INSERT INTO PointsCriteria (criteria_id,criteria_name, points_per_unit, description)
VALUES (1,'Miles Flown', 1.0, 'Points earned per mile flown'),
       (2,'Ticket Price', 1.0, 'Points earned per dollar spent on ticket'),
       (3,'Partner Purchases', 0.5, 'Points earned per dollar spent with partners');

--Table: FrequentFlyerTiers
--Defines different tiers and their benefits.
CREATE TABLE FrequentFlyerTiers (
    tier_id INT PRIMARY KEY ,
    tier_name VARCHAR(50), -- e.g., Silver, Gold, Platinum
    minimum_points INT, -- Minimum points required to reach this tier
    benefits TEXT -- List of benefits associated with this tier
);
INSERT INTO FrequentFlyerTiers (tier_id,tier_name, minimum_points, benefits)
VALUES (1,'Silver', 500, 'Priority boarding, 10% discount on flights'),
       (2,'Gold', 1000, 'Priority boarding, 20% discount on flights, free seat upgrades'),
       (3,'Platinum', 2000, 'Priority boarding, 30% discount on flights, free seat upgrades, access to lounges');

SELECT * FROM FrequentFlyerPoints
SELECT * FROM FlightClassPoints
SELECT * FROM PointsCriteria
SELECT * FROM FrequentFlyerTiers
