-- ============================================================
-- LOST AND FOUND MANAGEMENT SYSTEM 
-- Includes: DDL, DML, Triggers, Procedures, Functions, Privileges, Queries
-- ============================================================

-- ===========================
-- 1. DATABASE SETUP
-- ===========================
CREATE DATABASE IF NOT EXISTS lostandfounddb;
USE lostandfounddb;


-- ===========================
-- 2. DROP EXISTING OBJECTS 
-- ===========================
DROP TRIGGER IF EXISTS after_claim_update;
DROP FUNCTION IF EXISTS GetTotalClaimsByUser;
DROP PROCEDURE IF EXISTS AddLostItem;

-- Drop tables 
DROP TABLE IF EXISTS notification;
DROP TABLE IF EXISTS claim;
DROP TABLE IF EXISTS founditem;
DROP TABLE IF EXISTS lostitem;
DROP TABLE IF EXISTS `user`;

-- Drop users 
DROP USER IF EXISTS 'student'@'localhost';
DROP USER IF EXISTS 'admin'@'localhost';
DROP USER IF EXISTS 'app_user'@'localhost';


-- ===========================
-- 3. DATA DEFINITION LANGUAGE (DDL)
-- ===========================

-- Table: user
CREATE TABLE `user` (
    UserID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL UNIQUE,
    StudentID VARCHAR(20) NOT NULL UNIQUE,
    PhoneNo VARCHAR(15),
    Password VARCHAR(100) NOT NULL,
    Role VARCHAR(10) NOT NULL DEFAULT 'Student'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: LostItem
CREATE TABLE LostItem (
    LostItemID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    Category VARCHAR(50) NOT NULL,
    LocationLost VARCHAR(100),
    DateLost DATE NOT NULL,
    Image VARCHAR(255),
    UserID INT,
    AdminID INT,
    FOREIGN KEY (UserID) REFERENCES `user`(UserID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (AdminID) REFERENCES `user`(UserID) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: FoundItem
CREATE TABLE FoundItem (
    FoundItemID INT AUTO_INCREMENT PRIMARY KEY,
    Title VARCHAR(100) NOT NULL,
    Description TEXT NOT NULL,
    Category VARCHAR(50) NOT NULL,
    LocationFound VARCHAR(100),
    DateFound DATE NOT NULL,
    Image VARCHAR(255),
    UserID INT,
    AdminID INT,
    FOREIGN KEY (UserID) REFERENCES `user`(UserID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (AdminID) REFERENCES `user`(UserID) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: Claim
CREATE TABLE Claim (
    ClaimID INT AUTO_INCREMENT PRIMARY KEY,
    FoundItemID INT NOT NULL,
    ClaimantID INT,
    ClaimDate DATE NOT NULL,
    Status ENUM('Pending', 'Approved', 'Rejected') NOT NULL DEFAULT 'Pending',
    Justification TEXT,
    AdminID INT,
    FOREIGN KEY (FoundItemID) REFERENCES FoundItem(FoundItemID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ClaimantID) REFERENCES `user`(UserID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (AdminID) REFERENCES `user`(UserID) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Table: Notification
CREATE TABLE Notification (
    NotificationID INT AUTO_INCREMENT PRIMARY KEY,
    UserID INT NOT NULL,
    Message TEXT NOT NULL,
    DateTime DATETIME DEFAULT CURRENT_TIMESTAMP,
    Status ENUM('Read','Unread') DEFAULT 'Unread',
    FOREIGN KEY (UserID) REFERENCES `user`(UserID) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ===========================
-- 4. INSERT SAMPLE DATA (DML)
-- ===========================

-- Users
INSERT INTO `user` (UserID, Name, Email, StudentID, PhoneNo, Password, Role) VALUES
(1, 'Alice', 'alice@example.com', 'S001', '9876543210', 'pass123', 'Admin'),
(2, 'Bob', 'bob@example.com', 'S002', '9876543211', 'pass456', 'Student'),
(3, 'Charlie', 'charlie@example.com', 'S003', '9876543212', 'pass789', 'Student'),
(4, 'David', 'david@example.com', 'S004', '9876543213', 'passabc', 'Student'),
(5, 'Eve', 'eve@example.com', 'S005', '9876543214', 'passdef', 'Student');

-- Lost Items
INSERT INTO LostItem (Title, Description, Category, LocationLost, DateLost, UserID, AdminID) VALUES
('ID Card', 'Lost during lecture', 'ID Card', 'Library', '2025-09-10', 2, 1),
('Notebook', 'Lost near cafeteria', 'Stationery', 'Cafeteria', '2025-09-08', 3, 1),
('Headphones', 'Lost in lecture hall', 'Electronics', 'Lecture Hall A', '2025-09-09', 4, 1),
('Wallet', 'Lost near parking', 'Personal', 'Parking Lot', '2025-09-07', 5, 1),
('Textbook', 'Lost in library', 'Books', 'Library', '2025-09-06', 3, 1);

-- Found Items
INSERT INTO FoundItem (Title, Description, Category, LocationFound, DateFound, UserID, AdminID) VALUES
('ID Card', 'Found near library entrance', 'ID Card', 'Library', '2025-09-10', 1, 1),
('Notebook', 'Found near cafeteria', 'Stationery', 'Cafeteria', '2025-09-08', 1, 1),
('Wallet', 'Found in parking lot', 'Personal', 'Parking Lot', '2025-09-07', 1, 1),
('Headphones', 'Found in lecture hall', 'Electronics', 'Lecture Hall A', '2025-09-09', 1, 1),
('Textbook', 'Found in library', 'Books', 'Library', '2025-09-06', 1, 1);

-- Claims
INSERT INTO Claim (FoundItemID, ClaimantID, ClaimDate, Status, Justification, AdminID) VALUES
(1, 2, '2025-09-10', 'Pending', 'I lost my ID today near the library', 1),
(2, 3, '2025-09-08', 'Approved', 'Lost my notebook at cafeteria', 1),
(3, 4, '2025-09-09', 'Approved', 'Headphones were lost in lecture hall', 1),
(4, 5, '2025-09-07', 'Pending', 'Wallet lost near parking', 1),
(5, 3, '2025-09-06', 'Pending', 'Lost textbook in library', 1);

-- Notifications
INSERT INTO Notification (UserID, Message, DateTime, Status) VALUES
(2, 'Your lost item report is approved.', '2025-09-10 12:00:00', 'Unread'),
(3, 'Your found item report is approved.', '2025-09-08 14:00:00', 'Unread'),
(4, 'Your claim is rejected.', '2025-09-09 15:00:00', 'Unread'),
(5, 'Your claim is pending.', '2025-09-07 16:00:00', 'Unread'),
(3, 'Your claim is approved.', '2025-09-06 17:00:00', 'Unread');


-- ===========================
-- 5. ADVANCED OBJECTS (Triggers, Procedures, Functions)
-- ===========================
DELIMITER $$

-- Function
CREATE FUNCTION GetTotalClaimsByUser(uid INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE claim_count INT;
    SELECT COUNT(*) INTO claim_count FROM Claim WHERE ClaimantID = uid;
    RETURN claim_count;
END$$

-- Procedure
CREATE PROCEDURE AddLostItem (
    IN p_Title VARCHAR(100),
    IN p_Description TEXT,
    IN p_Category VARCHAR(50),
    IN p_LocationLost VARCHAR(100),
    IN p_DateLost DATE,
    IN p_UserID INT,
    IN p_AdminID INT
)
BEGIN
    INSERT INTO LostItem (Title, Description, Category, LocationLost, DateLost, UserID, AdminID)
    VALUES (p_Title, p_Description, p_Category, p_LocationLost, p_DateLost, p_UserID, p_AdminID);
END$$

-- Trigger
CREATE TRIGGER after_claim_update
AFTER UPDATE ON Claim
FOR EACH ROW
BEGIN
    IF NEW.Status = 'Approved' THEN
        INSERT INTO Notification (UserID, Message, DateTime, Status)
        VALUES (NEW.ClaimantID,
                CONCAT('Your claim ID ', NEW.ClaimID, ' has been approved.'),
                NOW(),
                'Unread');
    END IF;
END$$

DELIMITER ;


-- ===========================
-- 6. USER CREATION & PRIVILEGES
-- ===========================
CREATE USER 'student'@'localhost' IDENTIFIED BY 'Pesu@123';
GRANT SELECT, INSERT, UPDATE ON lostandfounddb.user TO 'student'@'localhost';
GRANT SELECT, INSERT, UPDATE ON lostandfounddb.LostItem TO 'student'@'localhost';
GRANT SELECT, INSERT, UPDATE ON lostandfounddb.FoundItem TO 'student'@'localhost';
GRANT SELECT, INSERT, UPDATE ON lostandfounddb.Claim TO 'student'@'localhost';
GRANT SELECT, INSERT, UPDATE ON lostandfounddb.Notification TO 'student'@'localhost';
GRANT EXECUTE ON PROCEDURE lostandfounddb.AddLostItem TO 'student'@'localhost';
GRANT EXECUTE ON FUNCTION lostandfounddb.GetTotalClaimsByUser TO 'student'@'localhost';

CREATE USER 'admin'@'localhost' IDENTIFIED BY 'Pesu@123';
GRANT ALL PRIVILEGES ON lostandfounddb.* TO 'admin'@'localhost' WITH GRANT OPTION;

FLUSH PRIVILEGES;


-- ===========================
-- 7. COMPLEX QUERIES
-- ===========================
-- Pending claim users
SELECT Name
FROM user
WHERE UserID IN (
    SELECT ClaimantID
    FROM Claim
    WHERE Status = 'Pending'
);

-- Approved claim details
SELECT
    U.Name AS ClaimantName,
    FI.Title AS FoundItemTitle,
    C.ClaimDate,
    C.Status
FROM Claim C
INNER JOIN `user` U ON C.ClaimantID = U.UserID
INNER JOIN FoundItem FI ON C.FoundItemID = FI.FoundItemID
WHERE C.Status = 'Approved';

-- Category-wise lost item count
SELECT
    Category,
    COUNT(LostItemID) AS TotalLostItems
FROM LostItem
GROUP BY Category
ORDER BY TotalLostItems DESC;


-- ===========================
-- 8. CRUD TESTS
-- ===========================
-- READ
SELECT * FROM FoundItem WHERE UserID = 1;

-- UPDATE 1
UPDATE LostItem
SET LocationLost = 'Library Entrance, Second Floor', AdminID = 1
WHERE LostItemID = 1;

-- UPDATE 2 (Trigger fires here)
UPDATE Claim
SET Status = 'Approved', AdminID = 1
WHERE ClaimID = 4;

-- DELETE 1
DELETE FROM LostItem WHERE LostItemID = 5;

-- DELETE 2
DELETE FROM Notification WHERE NotificationID = 3 AND Status = 'Unread';

-- MATCH QUERY
SELECT
    LI.LostItemID, LI.Title AS LostTitle, LI.Category AS LostCategory, LI.LocationLost,
    FI.FoundItemID, FI.Title AS FoundTitle, FI.Category AS FoundCategory, FI.LocationFound
FROM LostItem LI
INNER JOIN FoundItem FI ON LI.Category = FI.Category
WHERE
    LI.Category = FI.Category
    AND LI.LocationLost LIKE CONCAT('%', FI.LocationFound, '%')
    AND LI.LostItemID = 1;

-- ===========================
-- END OF FILE
-- ===========================
