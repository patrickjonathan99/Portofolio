CREATE DATABASE CyberWallet
GO
USE CyberWallet
GO
-- DROP DATABASE CyberWallet

-- DDL
CREATE TABLE MsUser (
	UserID INT IDENTITY(1,1) NOT NULL,
	UserName VARCHAR(30) NOT NULL,
	UserEmail VARCHAR(30) NOT NULL,
	PhoneNumber VARCHAR(30) NOT NULL,
	UserPassword VARCHAR(30) NOT NULL,
	UserSaldo BIGINT NOT NULL,
	DateOfBirth DATE NOT NULL,

	PRIMARY KEY (UserID),

	CONSTRAINT ValidEmail CHECK(UserEmail LIKE ('%@%.com')),
	CONSTRAINT PhoneLength CHECK(LEN(PhoneNumber) BETWEEN 11 AND 12),
	CONSTRAINT ValidPassword CHECK(LEN(UserPassword)<=30)
)
-- DROP TABLE MsUser
GO

CREATE TABLE TrTransaction (
	TransactionID INT IDENTITY(1,1) NOT NULL,
	UserID INT NOT NULL,
	TransactionBalance BIGINT NOT NULL,
	TransactionType VARCHAR(30) NOT NULL,
	TransactionDate DATE NOT NULL,

	PRIMARY KEY (TransactionID),
	FOREIGN KEY (UserID) REFERENCES MsUser(UserID),

	CONSTRAINT ValidType CHECK (TransactionType IN ('Penarikan', 'Transfer', 'Pembayaran', 'Penyetoran'))
)
-- DROP TABLE TrTransaction
GO

-- DML
INSERT INTO MsUser VALUES
('Nicholaus', 'nicholaus@gmail.com', '081289223433', 'Iloveyousomuch333', 10000000, '2002-05-04'),
('Kania Agatha', 'kania@gmail.com', '081233324442', 'kaniaaaaaaaaaaaaaaaaaaaaaaaa', 500000000, '2002-06-04'),
('Vika Valencia', 'vika@gmail.com', '081333785679', 'vikvikvikvikvikvik', 700000, '2002-07-04'),
('Patrick Jonathan', 'pejon@gmail.com', '09988574443', 'pejon123ahayduarmeme', 123456789, '2002-08-04'),
('Ariel Sefrian', 'ariel@gmail.com', '014758743322', 'aaaaaaaaaaaaaaaaaaaa', 987654321, '2002-09-04'),
('Audrey Tabitha', 'audreytbth@gmail.com', '09876567823', 'audreycanthikawwww', 800000000, '2002-05-04'),
('Anang', '4n4n9@gmail.com', '082440102120', 'Anangganteng', 3000000, '1995-03-24'),
('Patricio Johnny', 'patricio99@gmail.com', '082440064791', 'PatricioJ99!', 5250000, '1998-01-29'),
('Pica Valentino', 'picaboorah@gmail.com', '082440062123', 'Picapicachuuu123', 6300000, '2000-04-13'),
('Arial Stefanus', 'ariiial.stefanus@gmail.com', '082440067175', 'Arial0806_', 10000000, '2002-08-06')
GO

INSERT INTO TrTransaction VALUES
(1, '600000', 'Transfer', '2020-05-03'),
(1, '1000000', 'Penyetoran', '2020-05-01'),
(2, '950000', 'Pembayaran', '2020-12-12'),
(2, '1000000', 'Penarikan', '2020-10-01'),
(3, '100000', 'Transfer', '2020-05-03'),
(3, '7000000', 'Penyetoran', '2020-10-10'),
(4, '98500', 'Pembayaran', '2020-11-11'),
(4, '20000', 'Penarikan', '2020-01-01'),
(8, '550000', 'Penyetoran', '2021-08-19'),
(5, '2000000', 'Penarikan', '2022-01-22'),
(9, '750000', 'Pembayaran', '2021-02-01'),
(10, '2500000', 'Transfer', '2022-03-29'),
(7, '10000000', 'Penarikan', '2021-11-05'),
(8, '225000', 'Pembayaran', '2022-05-11'),
(6, '400000', 'Transfer', '2021-12-25')
GO

-- CREATE VIEW

-- BASIC

-- View UserID, UserName, DateOfBirth of users who were born before 2002
CREATE VIEW ViewDateOfBirth AS
SELECT
UserID, UserName, DateOfBirth
FROM MsUser
WHERE YEAR(DateOfBirth) < 2002

SELECT * FROM ViewDateOfBirth

-- View contact UserName, [UserEmail], and [PhoneNumber] of customers
CREATE VIEW ViewUserContactDetails AS
SELECT 
	UserName,
	[UserEmail] = REPLACE(UserEmail, 'gmail.com', 'cyberwallet.co.id'),
	[PhoneNumber] = STUFF(PhoneNumber, 1, 1, '+62 ')
FROM
MsUser

SELECT * FROM ViewUserContactDetails

-- View transactions that happened during the first two quarters of the year
CREATE VIEW ViewMayTransactions AS
SELECT
	UserID,
	TransactionBalance,
	TransactionType,
	TransactionDate
FROM TrTransaction
WHERE DATENAME(QUARTER, TransactionDate) <= 2

SELECT * FROM ViewMayTransactions

-- ADVANCED

-- View [UserID], UserName, and [Total Transaction] of users
CREATE VIEW ViewTotalTransactions AS
SELECT
	[UserID] = 'User ' + CAST(mu.UserID AS VARCHAR),
	UserName,
	[Total Transaction] = count(t.TransactionID)
FROM
MsUser AS mu
JOIN TrTransaction AS t ON t.UserID = mu.UserID
GROUP BY mu.UserID, UserName

SELECT * FROM ViewTotalTransactions

-- View transaction details for every transaction with a TransactionBalance over the TransactionBalance average
CREATE VIEW ViewAboveTransferAverage AS
SELECT
	t.TransactionID,
	mu.UserName,
	[Transaction Balance] = t.TransactionBalance,
	t.TransactionDate
FROM MsUser AS mu
JOIN TrTransaction as t ON t.UserID = mu.UserID,
(SELECT [Average] = AVG(TransactionBalance)
FROM TrTransaction
WHERE TransactionType = 'Transfer') AS avgTransfer 
WHERE t.TransactionType = 'Transfer' AND t.TransactionBalance > avgTransfer.Average
GROUP BY t.TransactionID, mu.UserName, t.TransactionBalance, t.TransactionDate

SELECT * FROM ViewAboveTransferAverage

-- View customers whose number of transactions is larger than the average number of transactions
CREATE VIEW ViewManyTransactions AS
SELECT 
	UserName, 
	[TotalTransactions] = count(t.TransactionID)
FROM MsUser AS mu
JOIN TrTransaction AS t on mu.UserID = t.UserID
GROUP BY mu.UserName
HAVING count(t.TransactionID) >
(SELECT 
	[Average Transaction] = AVG(transNum.[TotalTransactions])
FROM
(SELECT 
	[TotalTransactions] = COUNT(t.TransactionID)
FROM TrTransaction AS t
GROUP BY UserID) transNum)

SELECT * FROM ViewManyTransactions

-- View customers who have done withdrawal(s)
CREATE VIEW ViewUsersWithWithdrawal AS
SELECT 
	[UserCode] = LOWER(LEFT(UserName, 3)) + CAST(mu.UserID AS VARCHAR),
	mu.UserSaldo,
	t.TransactionBalance,
	[Transaction Month] = DATENAME(MONTH, t.TransactionDate)
FROM MsUser AS mu
JOIN TrTransaction AS t ON t.UserID = mu.UserID
WHERE TransactionType LIKE 'Penarikan'

SELECT * FROM ViewUsersWithWithdrawal