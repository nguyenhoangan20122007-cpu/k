-- PHẦN 1 : THIẾT KẾ CSDL VÀ CHÈN DỮ LIỆU

-- tạo data base 
CREATE DATABASE Test_Exam;
USE Test_Exam;

-- tạo bảng Guests
CREATE TABLE Guests (
    guest_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20) NOT NULL UNIQUE,
    loyalty_points INT DEFAULT 0 CHECK (loyalty_points >= 0)
);

-- tạo bảng Guest_Profiles 
CREATE TABLE Guest_Profiles (
    profile_id INT PRIMARY KEY,
    guest_id INT,
    address VARCHAR(255) NOT NULL,
    birthday DATE NOT NULL,
    national_id VARCHAR(20) NOT NULL UNIQUE,
    CONSTRAINT fk_profile_guest
    FOREIGN KEY (guest_id)
    REFERENCES Guests(guest_id)
);


-- tạo bảng Rooms
CREATE TABLE Rooms (
    room_id INT PRIMARY KEY,
    room_name VARCHAR(100) NOT NULL,
    room_type ENUM('Standard', 'Deluxe', 'Suite') NOT NULL,
    price_per_night DECIMAL(12,2) NOT NULL
    CHECK (price_per_night > 0),
    room_status ENUM(
        'Available',
        'Occupied',
        'Maintenance'
    ) NOT NULL
);

-- tạo bảng Bookings 
CREATE TABLE Bookings (
    booking_id INT PRIMARY KEY,
    guest_id INT,
    room_id INT,
    check_in_date DATETIME NOT NULL,
    check_out_date DATETIME NOT NULL,
    total_charge DECIMAL(12,2) NOT NULL
    CHECK (total_charge > 0),
    booking_status ENUM(
        'Pending',
        'Completed',
        'Cancelled'
    ) NOT NULL,
    CONSTRAINT chk_booking_date
    CHECK (check_out_date > check_in_date),
    CONSTRAINT fk_booking_guest
    FOREIGN KEY (guest_id)
    REFERENCES Guests(guest_id),
    CONSTRAINT fk_booking_room
    FOREIGN KEY (room_id)
    REFERENCES Rooms(room_id)
);

-- tạo bảng Room_Log
CREATE TABLE Room_Log (
    log_id INT PRIMARY KEY,
    room_id INT,
    action_type ENUM(
        'Check-in',
        'Check-out',
        'Maintenance',
        'Cancelled'
    ) NOT NULL,
    change_note VARCHAR(255) NOT NULL,
    logged_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_log_room
    FOREIGN KEY (room_id)
    REFERENCES Rooms(room_id)
);


-- THÊM DỮ LIỆU THEO BẢNG DỮ LIỆU MẪU 
INSERT INTO Guests
VALUES
(1, 'Nguyen Van A', 'anv@gmail.com', '901234567', 150),
(2, 'Tran Thi B', 'btt@gmail.com', '912345678', 500),
(3, 'Le Van C', 'cle@yahoo.com', '922334455', 0),
(4, 'Pham Minh D', 'dpham@hotmail.com', '933445566', 1000),
(5, 'Hoang Anh E', 'ehoang@gmail.com', '944556677', 20);

INSERT INTO Guest_Profiles
VALUES
(101, 1, '123 Le Loi, Q1, HCM', '1990-05-15', '12345'),
(102, 2, '456 Nguyen Hue, Q1, HCM', '1985-10-20', '23456'),
(103, 3, '789 Phan Chu Trinh, Da Nang', '1995-12-01', '34567'),
(104, 4, '101 Hoang Hoa Tham, Ha Noi', '1988-03-25', '45678'),
(105, 5, '202 Tran Hung Dao, Can Tho', '2000-07-10', '56789');

INSERT INTO Rooms
VALUES
(1, 'Room 101', 'Standard', 100000, 'Available'),
(2, 'Room 202', 'Deluxe', 5000000, 'Occupied'),
(3, 'Room 303', 'Suite', 300000, 'Available'),
(4, 'Room 104', 'Standard', 200000, 'Occupied'),
(5, 'Room 205', 'Deluxe', 2000000, 'Maintenance');

INSERT INTO Bookings
VALUES
(1001, 1, 1,'2023-11-15 10:30:00','2023-11-18 12:00:00',300000,'Completed'),
(1002, 2, 2,'2023-12-01 14:20:00','2023-12-04 12:00:00',20000000,'Completed'),
(1003, 1, 2,'2021-01-10 09:15:00','2021-01-11 12:00:00',5000000,'Pending'),
(1004, 3, 3,'2023-05-20 16:45:00','2023-05-22 12:00:00',900000,'Cancelled'),
(1005, 4, 4,'2024-01-18 11:00:00','2024-01-20 12:00:00',8000000,'Completed');

INSERT INTO Room_Log
VALUES
(1, 1, 'Check-in','Guest checked in','2023-10-01 08:00:00'),
(2, 1, 'Check-out','Guest checked out','2023-11-15 10:35:00'),
(3, 4, 'Maintenance','Room report as damage','2023-11-20 15:00:00'),
(4, 2, 'Check-in','New guest arrival','2023-11-25 09:00:00'),
(5, 3, 'Maintenance','Schedule maintenance','2023-12-01 13:00:00');



-- viết câu lệnh UPDATE cộng 200 điểm tích lũy cho các khách hàng có đuôi là '@gmail.com'
UPDATE Guests
SET loyalty_points = loyalty_points + 200
WHERE email LIKE '%@gmail.com';

-- viết câu lệnh DELETE xóa các bản ghi trong Room_Log có logged_at trước ngày 10/11/2023
DELETE FROM Room_Log
WHERE logged_at < '2023-11-10';

-- PHẦN 2 : TRUY VẤN DỮ LIỆU CƠ BẢN
-- câu 1 : Lấy danh sách phòng có giá thuê > 1000000 hoặc room_status = 'Maintenance' hoặc room_type = 'Suite'
SELECT room_name, price_per_night, room_status
FROM Rooms
WHERE price_per_night > 1000000
   OR room_status = 'Maintenance'
   OR room_type = 'Suite';
   
   
   
-- câu 2 : lấy thông tin khách có email thuộc domain   '@gmail.com'  và loy-points nằm trong khoảng từ 50-300
SELECT full_name, email
FROM Guests
WHERE email LIKE '%@gmail.com'
AND loyalty_points BETWEEN 50 AND 300;


-- câu 3 : Hiển thị ba booking  có total_charge cao nhất, sắp xếp theo thứ tự giảm dần và bỏ qua booking cao nhất 
SELECT *
FROM Bookings
ORDER BY total_charge DESC
LIMIT 3 OFFSET 1;

-- PHẦN 3 : TRUY VẤN DỮ LIỆU NÂNG CAO
-- câu 1 : viêt câu lệnh truy vấn lấy ra các thông tin lịch đặt phòng
SELECT g.full_name, gp.national_id, b.booking_id, b.check_in_date, b.total_charge
FROM Guests g
JOIN Guest_Profiles gp
ON g.guest_id = gp.guest_id
JOIN Bookings b
ON g.guest_id = b.guest_id;


-- câu 2 : tính tổng số tiền thanh toán của mỗi khách . Hiển thị các khách có tổng chi tiêu của booking hoàn thành > 2000000
SELECT g.guest_id, g.full_name,
    SUM(b.total_charge) AS total_spending
FROM Guests g
JOIN Bookings b
ON g.guest_id = b.guest_id
WHERE b.booking_status = 'Completed'
GROUP BY g.guest_id, g.full_name
HAVING SUM(b.total_charge) > 20000000;


-- câu 3: tìm thông tin phòng có price_per_night cao nhất trong danh sách các phòng từng xuất hiện trong booking thành công
SELECT r.*
FROM Rooms r
JOIN Bookings b
ON r.room_id = b.room_id
WHERE b.booking_status = 'Completed'
AND r.price_per_night = (
    SELECT MAX(r2.price_per_night)
    FROM Rooms r2
    JOIN Bookings b2
    ON r2.room_id = b2.room_id
    WHERE b2.booking_status = 'Completed'
);

-- INDEX VÀ VIEW
-- câu 1 : Tạo Composite Index tên idx_booking_status_cgh trên bảng Bookings
CREATE INDEX idx_booking_status_cgh
ON Bookings(booking_status, check_in_date);


-- câu 2 : Tạo View vw_guest_booking_stats 
CREATE VIEW vw_guest_booking_stats AS
SELECT g.full_name AS guest_name,
    COUNT(b.booking_id) AS total_bookings,
    SUM(
        CASE
            WHEN b.booking_status <> 'Cancelled'
            THEN b.total_charge
            ELSE 0
        END
    ) AS total_paid
FROM Guests g
LEFT JOIN Bookings b
ON g.guest_id = b.guest_id
GROUP BY g.guest_id, g.full_name;


-- PHẦN 5 : TRIGGER 
-- câu 1 : Tạo trigger trg_after_update_booking_status 

DELIMITER $$

CREATE TRIGGER trg_after_update_booking_status
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN

    IF NEW.booking_status = 'Completed'
       AND OLD.booking_status <> 'Completed'
    THEN

        INSERT INTO Room_Log ( room_id, action_type, change_note, logged_at)
        VALUES ( NEW.room_id, 'Check-out', 'Booking Completed',
            NOW());

    END IF;

END $$

DELIMITER ;


-- câu 2 tạo trigger trg_update_loyalty_points
DELIMITER $$

CREATE TRIGGER trg_update_loyalty_points
AFTER INSERT ON Bookings
FOR EACH ROW
BEGIN

    IF NEW.booking_status = 'Completed' THEN

        UPDATE Guests
        SET loyalty_points = loyalty_points + FLOOR(NEW.total_charge / 1000000) * 2
        WHERE guest_id = NEW.guest_id;

    END IF;

END $$

DELIMITER ;


-- PHẦN 6 : STORED PROCEDURE 
-- câu 1 : Viết Procedure sp_get_room_status nhận vào room_id
DELIMITER $$

CREATE PROCEDURE sp_get_room_status (
    IN p_room_id INT
)
BEGIN

    DECLARE v_status VARCHAR(50);

    SELECT room_status
    INTO v_status
    FROM Rooms
    WHERE room_id = p_room_id;

    IF v_status = 'Available' THEN
        SELECT 'Phòng trống' AS message;

    ELSEIF v_status = 'Occupied' THEN
        SELECT 'Đang có khách' AS message;

    ELSEIF v_status = 'Maintenance' THEN
        SELECT 'Bảo trì' AS message;

    END IF;

END $$

DELIMITER ;


-- câu 2 : Viết Procedure sp_cancel_booking xử lý hủy đặt phòng an toàn 
DELIMITER $$

CREATE PROCEDURE sp_cancel_booking (
    IN p_booking_id INT
)
BEGIN

    DECLARE v_room_id INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
    END;

    START TRANSACTION;

    SELECT room_id
    INTO v_room_id
    FROM Bookings
    WHERE booking_id = p_booking_id;

    UPDATE Bookings
    SET booking_status = 'Cancelled'
    WHERE booking_id = p_booking_id;

    UPDATE Rooms
    SET room_status = 'Available'
    WHERE room_id = v_room_id;

    INSERT INTO Room_Log (room_id, action_type, change_note,logged_at)
    VALUES (v_room_id, 'Cancelled', 'Booking Cancelled',NOW());

    COMMIT;

END $$

DELIMITER ;

CALL sp_get_room_status(1);

CALL sp_cancel_booking(1003);