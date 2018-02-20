-- DROP TABLE Account;
-- DROP TABLE Customer;
-- DROP TABLE Bank;

CREATE TABLE Bank (
	b# CHAR(2) PRIMARY KEY,
	name VARCHAR(10) NOT NULL,
	city VARCHAR(10) NOT NULL
);

CREATE TABLE Customer (
	c# CHAR(2) PRIMARY KEY,
	name VARCHAR(10) NOT NULL,
	age INT NOT NULL,
	city VARCHAR(10) NOT NULL
);

CREATE TABLE Account (
	c# CHAR(2),
	b# CHAR(2),
	balance INT NOT NULL,
	PRIMARY KEY(b#, c#),
	FOREIGN KEY(b#) REFERENCES Bank(b#) ON DELETE CASCADE,
	FOREIGN KEY(c#) REFERENCES Customer(c#) ON DELETE CASCADE
);

INSERT INTO Bank VALUES ('B1', 'England', 'London');
INSERT INTO Bank VALUES ('B2', 'America', 'New York');
INSERT INTO Bank VALUES ('B3', 'Royal', 'Toronto');
INSERT INTO Bank VALUES ('B4', 'France', 'Paris');

INSERT INTO Customer VALUES ('C1', 'Adams', 20, 'London');
INSERT INTO Customer VALUES ('C2', 'Blake', 30, 'Paris');
INSERT INTO Customer VALUES ('C3', 'Clark', 25, 'Paris');
INSERT INTO Customer VALUES ('C4', 'Jones', 20, 'London');
INSERT INTO Customer VALUES ('C5', 'Smith', 30, 'Toronto');

INSERT INTO Account VALUES ('C1', 'B1', 1000);
INSERT INTO Account VALUES ('C1', 'B2', 2000);
INSERT INTO Account VALUES ('C1', 'B3', 3000);
INSERT INTO Account VALUES ('C1', 'B4', 4000);
INSERT INTO Account VALUES ('C2', 'B1', 2000);
INSERT INTO Account VALUES ('C2', 'B2', 3000);
INSERT INTO Account VALUES ('C2', 'B3', 4000);
INSERT INTO Account VALUES ('C3', 'B1', 3000);
INSERT INTO Account VALUES ('C3', 'B2', 4000);
INSERT INTO Account VALUES ('C4', 'B1', 4000);
INSERT INTO Account VALUES ('C4', 'B2', 5000);

-- 1. 
SELECT C.name FROM Customer C WHERE EXISTS (
	SELECT null FROM Account A WHERE A.c# = C.c#
);
-- 2. 
SELECT C.name, B.name FROM Customer C, Bank B WHERE NOT EXISTS (
	SELECT null FROM Account A WHERE A.c# = C.c# and A.b# = B.b#
);
-- 3. 
SELECT C.name FROM Customer C WHERE NOT EXISTS (
	SELECT null FROM Account A WHERE A.c# = C.c#
);
-- 4. 
SELECT B.name FROM Bank B, Customer C, Account A WHERE A.c# = C.c# and B.b# = A.b# and C.name = 'Blake'
UNION
SELECT B.name FROM Bank B, Customer C, Account A WHERE A.c# = C.c# and B.b# = A.b# and C.name = 'Clark';
 -- 5. 
SELECT C.name FROM Customer C WHERE NOT EXISTS (
	SELECT null FROM Bank B WHERE NOT EXISTS (
		SELECT null FROM Account A WHERE C.c# = A.c# and B.b# = A.b#
	)
);
-- 6.
SELECT C.name FROM Customer C WHERE NOT EXISTS (
	SELECT null FROM Bank B WHERE (
		B.name != 'France' and B.name != 'Royal' OR EXISTS (
			SELECT null FROM Account A WHERE C.c# = A.c# and B.b# = A.b#
		)
	) and (
		B.name = 'France' OR B.name = 'Royal' OR NOT EXISTS (
			SELECT null FROM Account A WHERE C.c# = A.c# and B.b# = A.b#
		)
	)
);
-- 7. 
SELECT C1.name FROM Customer C1 WHERE C1.name != 'Clark' and EXISTS (
	SELECT * FROM Customer C WHERE C.name = 'Clark' and NOT EXISTS (
		SELECT * FROM Bank B WHERE EXISTS (
			SELECT * FROM Account A WHERE C.c# = A.c# and B.b# = A.b#
		) and NOT EXISTS (
			SELECT * FROM Account A, Account A1 WHERE C.c# = A.c# and A.b# = B.b# and C1.c# = A1.c# and A1.b# = B.b#
		)
	)
);
-- 8.
SELECT C1.name FROM Customer C1 WHERE C1.name != 'Clark' AND NOT EXISTS (
	SELECT null FROM Bank B, Customer C, Account A
	WHERE C.name = 'Clark' AND C.c# = A.c# AND B.b# = A.b#
	MINUS
	SELECT null FROM Bank B, Account A
	WHERE C1.c# = A.c# AND B.b# = A.b#
);
-- 9.
SELECT C.name FROM Customer C WHERE EXISTS (
	SELECT * FROM Account A WHERE EXISTS (
		SELECT * FROM Account A1 WHERE A.c# = A1.c# and C.c# = A.c# and A.b# != A1.b#
	)
);
-- 10.
SELECT C.name FROM Customer C WHERE EXISTS (
	SELECT A.c#, COUNT(*) count FROM Account A WHERE A.c# = C.c# GROUP BY c# HAVING COUNT(*) > 1
);
-- 11.
SELECT C.name, C.age, C.city, B.name, B.city, A.balance FROM Customer C
LEFT JOIN Account A ON C.c# = A.c#
LEFT JOIN Bank B ON B.b# = A.b#
ORDER BY C.name;
-- 12.
SELECT C.name, A.balance FROM Customer C
LEFT JOIN (SELECT c#, SUM(balance) balance FROM Account GROUP BY c#) A on A.c# = C.c#;