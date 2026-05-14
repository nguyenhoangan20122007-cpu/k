-- Tạo cơ sở dữ liệu
CREATE DATABASE Library_Management;
USE Library_Management;

-- =========================
-- Tạo bảng Readers
-- =========================
CREATE TABLE Readers (
    reader_id INT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(20) NOT NULL UNIQUE,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- =========================
-- Tạo bảng Membership_Details
-- =========================
CREATE TABLE Membership_Details (
    card_id VARCHAR(20) PRIMARY KEY,
    reader_id INT UNIQUE,
    card_rank ENUM('Standard', 'VIP'),
    expiry_date DATE NOT NULL,
    citizen_id VARCHAR(20) NOT NULL UNIQUE,
    
    FOREIGN KEY (reader_id) REFERENCES Readers(reader_id)
);

-- =========================
-- Tạo bảng Categories
-- =========================
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT NOT NULL
);

-- =========================
-- Tạo bảng Books
-- =========================
CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title VARCHAR(200) NOT NULL UNIQUE,
    author VARCHAR(100) NOT NULL,
    category_id INT,
    price DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock_quantity INT NOT NULL CHECK (stock_quantity >= 0),

    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);

-- =========================
-- Tạo bảng Loan_Records
-- =========================
CREATE TABLE Loan_Records (
    loan_id INT PRIMARY KEY,
    reader_id INT,
    book_id INT,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,

    FOREIGN KEY (reader_id) REFERENCES Readers(reader_id),
    FOREIGN KEY (book_id) REFERENCES Books(book_id),

    CHECK (due_date > borrow_date)
);

-- =========================
-- Chèn dữ liệu vào Readers
-- =========================
INSERT INTO Readers (
    reader_id,
    full_name,
    email,
    phone_number,
    created_at
)
VALUES
(1, 'Nguyen Van A', 'anv@gmail.com', '901234567', '2022-01-15'),
(2, 'Tran Thi B', 'btt@gmail.com', '912345678', '2022-05-20'),
(3, 'Le Van C', 'cle@yahoo.com', '922334455', '2023-02-10'),
(4, 'Pham Minh D', 'dpham@hotmail.com', '933445566', '2023-11-05'),
(5, 'Hoang Anh E', 'ehoang@gmail.com', '944556677', '2023-01-12');

-- =========================
-- Chèn dữ liệu vào Membership_Details
-- =========================
INSERT INTO Membership_Details (
    card_id,
    reader_id,
    card_rank,
    expiry_date,
    citizen_id
)
VALUES
('CARD-001', 1, 'Standard', '2025-01-15', '123456789'),
('CARD-002', 2, 'VIP', '2025-05-20', '234567890'),
('CARD-003', 3, 'Standard', '2024-02-10', '345678901'),
('CARD-004', 4, 'VIP', '2025-11-05', '456789012'),
('CARD-005', 5, 'Standard', '2026-01-12', '567890123');

-- =========================
-- Chèn dữ liệu vào Categories
-- =========================
INSERT INTO Categories (
    category_id,
    category_name,
    description
)
VALUES
(1, 'IT', 'Sach ve cong nghe thong tin va lap trinh'),
(2, 'Kinh Te', 'Sach kinh doanh tai chinh khoi nghiep'),
(3, 'Van Hoc', 'Tieu thuyet truyen ngan tho'),
(4, 'Ngoai Ngu', 'Sach hoc tieng Anh Nhat Han'),
(5, 'Lich Su', 'Sach nghien cuu lich su van hoa');

-- =========================
-- Chèn dữ liệu vào Books
-- =========================
INSERT INTO Books (
    book_id,
    title,
    author,
    category_id,
    price,
    stock_quantity
)
VALUES
(1, 'Clean Code', 'Robert C. Martin', 1, 450000, 10),
(2, 'Dac Nhan Tam', 'Dale Carnegie', 2, 150000, 50),
(3, 'Harry Potter 1', 'J.K. Rowling', 3, 250000, 5),
(4, 'IELTS Reading', 'Cambridge', 4, 180000, 0),
(5, 'Dai Viet Su Ky', 'Le Van Huu', 5, 300000, 20);

-- =========================
-- Chèn dữ liệu vào Loan_Records
-- =========================
INSERT INTO Loan_Records (
    loan_id,
    reader_id,
    book_id,
    borrow_date,
    due_date,
    return_date
)
VALUES
(101, 1, 1, '2023-11-15', '2023-11-22', '2023-11-20'),
(102, 2, 2, '2023-12-01', '2023-12-08', '2023-12-05'),
(103, 1, 3, '2024-01-10', '2024-01-17', NULL),
(104, 3, 4, '2023-05-20', '2023-05-27', NULL),
(105, 4, 1, '2023-01-18', '2024-01-25', NULL);

-- =========================
-- Gia hạn thêm 7 ngày cho sách Van Hoc chưa trả
-- =========================
UPDATE Loan_Records lr
JOIN Books b 
ON lr.book_id = b.book_id
JOIN Categories c 
ON b.category_id = c.category_id
SET lr.due_date = DATE_ADD(lr.due_date, INTERVAL 7 DAY)
WHERE c.category_name = 'Van Hoc'
AND lr.return_date IS NULL;

-- =========================
-- Xóa hồ sơ đã trả trước tháng 10/2023
-- =========================
DELETE FROM Loan_Records
WHERE return_date IS NOT NULL
AND borrow_date < '2023-10-01';

-- =========================
-- Câu 1:
-- Sách thuộc danh mục IT và giá > 200000
-- =========================
SELECT 
    b.book_id,
    b.title,
    b.price
FROM Books b
JOIN Categories c 
ON b.category_id = c.category_id
WHERE c.category_name = 'IT'
AND b.price > 200000;

-- =========================
-- Câu 2:
-- Độc giả tạo tài khoản năm 2022 và dùng gmail
-- =========================
SELECT
    reader_id,
    full_name,
    email
FROM Readers
WHERE YEAR(created_at) = 2022
AND email LIKE '%@gmail.com';

-- =========================
-- Câu 3:
-- Lấy sách từ vị trí thứ 3 đến thứ 7 giá cao nhất
-- =========================
SELECT
    book_id,
    title,
    price
FROM Books
ORDER BY price DESC
LIMIT 5 OFFSET 2;

-- =========================
-- Nâng cao Câu 1:
-- Danh sách phiếu chưa trả
-- =========================
SELECT
    lr.loan_id,
    r.full_name,
    b.title,
    lr.borrow_date,
    lr.return_date
FROM Loan_Records lr
JOIN Readers r
ON lr.reader_id = r.reader_id
JOIN Books b
ON lr.book_id = b.book_id
WHERE lr.return_date IS NULL;

-- =========================
-- Nâng cao Câu 2:
-- Tổng tồn kho từng danh mục > 10
-- =========================
SELECT
    c.category_name,
    SUM(b.stock_quantity) AS total_stock
FROM Categories c
JOIN Books b
ON c.category_id = b.category_id
GROUP BY c.category_name
HAVING SUM(b.stock_quantity) > 10;

-- =========================
-- Nâng cao Câu 3:
-- Độc giả VIP chưa từng mượn sách > 300000
-- =========================
SELECT
    r.full_name
FROM Readers r
JOIN Membership_Details md
ON r.reader_id = md.reader_id
WHERE md.card_rank = 'VIP'
AND r.reader_id NOT IN (
    SELECT lr.reader_id
    FROM Loan_Records lr
    JOIN Books b
    ON lr.book_id = b.book_id
    WHERE b.price > 300000
);

-- =========================
-- Tạo Composite Index
-- =========================
CREATE INDEX idx_loan_dates
ON Loan_Records (borrow_date, return_date);

-- =========================
-- Tạo View sách quá hạn chưa trả
-- =========================
CREATE VIEW vw_overdue_loans AS
SELECT
    lr.loan_id,
    r.full_name,
    b.title,
    lr.borrow_date,
    lr.due_date
FROM Loan_Records lr
JOIN Readers r
ON lr.reader_id = r.reader_id
JOIN Books b
ON lr.book_id = b.book_id
WHERE CURDATE() > lr.due_date
AND lr.return_date IS NULL;

-- =========================
-- Trigger tự động trừ tồn kho khi mượn sách
-- =========================
DELIMITER $$

CREATE TRIGGER trg_after_loan_insert
AFTER INSERT ON Loan_Records
FOR EACH ROW
BEGIN
    UPDATE Books
    SET stock_quantity = stock_quantity - 1
    WHERE book_id = NEW.book_id;
END$$

DELIMITER ;

-- =========================
-- Trigger ngăn xóa độc giả đang mượn sách
-- =========================
DELIMITER $$

CREATE TRIGGER trg_prevent_delete_active_reader
BEFORE DELETE ON Readers
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Loan_Records
        WHERE reader_id = OLD.reader_id
        AND return_date IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Khong the xoa doc gia dang muon sach';
    END IF;
END$$

DELIMITER ;

-- =========================
-- Procedure kiểm tra tình trạng sách
-- =========================
DELIMITER $$

CREATE PROCEDURE sp_check_availability(
    IN p_book_id INT,
    OUT p_message VARCHAR(50)
)
BEGIN
    DECLARE v_stock INT;

    SELECT stock_quantity
    INTO v_stock
    FROM Books
    WHERE book_id = p_book_id;

    IF v_stock = 0 THEN
        SET p_message = 'Het hang';

    ELSEIF v_stock > 0 AND v_stock <= 5 THEN
        SET p_message = 'Sap het';

    ELSE
        SET p_message = 'Con hang';
    END IF;
END$$

DELIMITER ;

-- =========================
-- Procedure trả sách có Transaction
-- =========================
DELIMITER $$

CREATE PROCEDURE sp_return_book_transaction(
    IN p_loan_id INT
)
BEGIN
    DECLARE v_return_date DATE;
    DECLARE v_book_id INT;

    START TRANSACTION;

    SELECT return_date, book_id
    INTO v_return_date, v_book_id
    FROM Loan_Records
    WHERE loan_id = p_loan_id;

    IF v_return_date IS NOT NULL THEN

        ROLLBACK;

        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Sach da tra roi';

    ELSE

        UPDATE Loan_Records
        SET return_date = CURDATE()
        WHERE loan_id = p_loan_id;

        UPDATE Books
        SET stock_quantity = stock_quantity + 1
        WHERE book_id = v_book_id;

        COMMIT;

    END IF;
END$$

DELIMITER ;
