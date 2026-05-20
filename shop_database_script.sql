-- PROJEKTOWANIE BAZY
CREATE DATABASE shop_DB;
USE shop_DB;

CREATE TABLE Users (
id INT PRIMARY KEY IDENTITY(1,1),
username VARCHAR(50) NOT NULL
);

CREATE TABLE Orders (
id INT PRIMARY KEY IDENTITY(1,1),
user_id INT NOT NULL,
created_at DATE DEFAULT GETDATE()
);

CREATE TABLE Products (
id INT PRIMARY KEY IDENTITY(1,1),
product_name VARCHAR(50) NOT NULL,
price DECIMAL(10,2) CHECK (price >= 0)
);

CREATE TABLE OrderItems (
id INT PRIMARY KEY IDENTITY(1,1),
order_id INT,
product_id INT,
quantity INT CHECK (quantity > 0)
);

-- klucze obce
ALTER TABLE Orders
ADD CONSTRAINT fk_orders
FOREIGN KEY (user_id)
REFERENCES Users (id);

ALTER TABLE OrderItems
ADD CONSTRAINT fk_orders123
FOREIGN KEY (order_id)
REFERENCES Orders (id);

ALTER TABLE OrderItems
ADD CONSTRAINT fk_products
FOREIGN KEY (product_id)
REFERENCES Products (id);

-- INDEKSY NA FK I UŻYWANYCH KOLUMNACH
CREATE INDEX idx_orders_user_id ON Orders(user_id);

CREATE INDEX idx_order_items_order_id ON OrderItems(order_id);

CREATE INDEX idx_order_items_product_id ON OrderItems(product_id);

CREATE INDEX idx_products_name ON Products(product_name);

-- DODAWANIE REKORDÓW

INSERT INTO Users (username) VALUES 
('jan_kowalski'), 
('anna_nowak'), 
('piotr_wisniewski'), 
('m_wojcik'), 
('kasia_mazur'), 
('tomek_lewandowski'), 
('ola_dabrowska'), 
('marcin_zielinski'), 
('karol_szymanski'), 
('beata_wozniak');

INSERT INTO Products (product_name, price) VALUES 
('Laptop Pro 15', 4500.00), 
('Mysz Bezprzewodowa', 120.50), 
('Monitor 24 cale', 850.00), 
('Klawiatura Mechaniczna', 350.00), 
('Słuchawki BT', 299.99), 
('Podkładka pod mysz', 45.00), 
('Kabel HDMI 2m', 30.00), 
('Dysk SSD 1TB', 420.00), 
('Kamera internetowa', 180.00), 
('Głośniki 2.1', 250.00);

INSERT INTO Orders (user_id, created_at) VALUES 
(1, '2024-01-10'), 
(2, '2024-01-12'), 
(3, '2024-01-15'), 
(4, '2024-02-01'), 
(5, '2024-02-05'), 
(1, '2024-02-10'), 
(7, '2024-03-01'), 
(8, '2024-03-05'), 
(9, '2024-03-10'), 
(10, '2024-03-15');

INSERT INTO OrderItems (order_id, product_id, quantity) VALUES 
(1, 1, 1), (1, 2, 1), -- Zamówienie 1: Laptop + Mysz
(2, 3, 1),           -- Zamówienie 2: Monitor
(3, 4, 1), (3, 2, 1), -- Zamówienie 3: Klawiatura + Mysz
(4, 2, 1),           -- Zamówienie 4: Mysz
(5, 5, 1),           -- Zamówienie 5: Słuchawki
(6, 6, 1), (6, 7, 1), -- Zamówienie 6: Podkładka + Kabel
(7, 1, 1),           -- Zamówienie 7: Laptop
(8, 8, 1), (8, 9, 1), -- Zamówienie 8: Dysk + Kamera
(9, 7, 1),           -- Zamówienie 9: Kabel
(10, 3, 1), (10, 10, 1); -- Zamówienie 10: Monitor + Głośniki

-- PODSTAWY

SELECT COUNT(*) AS liczba_zamowien FROM Orders;

SELECT u.username, o.id FROM Users u LEFT JOIN Orders o
ON o.user_id=u.id;

SELECT * FROM Users JOIN Orders 
ON Users.id = Orders.user_id
WHERE Orders.id IS NOT NULL;

SELECT Users.* FROM Users LEFT JOIN Orders 
ON Users.id = Orders.user_id
WHERE Orders.id IS NULL;
-- JOINY

SELECT OrderItems.*, Products.product_name FROM OrderItems
JOIN Products ON Products.id = OrderItems.product_id

SELECT OrderItems.*, Orders.* FROM Orders JOIN OrderItems
ON OrderItems.order_id = Orders.id;

SELECT Users.*, Orders.*, OrderItems.*, Products.* FROM OrderItems
JOIN Orders ON Orders.id = OrderItems.order_id
JOIN Products ON Products.id = OrderItems.product_id
JOIN Users ON Users.id = Orders.user_id;

SELECT Users.username, Products.product_name FROM Users
JOIN Orders ON Orders.user_id = Users.id
JOIN OrderItems ON OrderItems.order_id = Orders.id
JOIN Products ON Products.id = OrderItems.product_id;

SELECT Orders.id, COUNT(OrderItems.id) AS ilosc_produktow 
FROM OrderItems
JOIN Orders ON Orders.id = OrderItems.order_id
GROUP BY Orders.id;

SELECT Products.id
FROM Products
LEFT JOIN OrderItems ON Products.id = OrderItems.product_id
WHERE OrderItems.id IS NULL;

--GRUPOWANIA

SELECT user_id, COUNT(id) AS ilosc_zamowien 
FROM Orders 
GROUP BY user_id;

SELECT o.user_id, SUM(p.price * oi.quantity) AS suma_wydatkow
FROM Orders o
JOIN OrderItems oi ON o.id = oi.order_id
JOIN Products p ON p.id = oi.product_id
GROUP BY o.user_id;

SELECT o.id, AVG(p.price * oi.quantity) AS srednia_pozycja
FROM Orders o
JOIN OrderItems oi ON o.id = oi.order_id
JOIN Products p ON p.id = oi.product_id
GROUP BY o.id;

SELECT TOP 1 o.id, SUM(p.price * oi.quantity) AS total_amount 
FROM Orders o
JOIN OrderItems oi ON o.id = oi.order_id
JOIN Products p ON p.id = oi.product_id
GROUP BY o.id 
ORDER BY total_amount DESC;

SELECT TOP 1 o.id, SUM(p.price * oi.quantity) AS total_amount 
FROM Orders o
JOIN OrderItems oi ON o.id = oi.order_id
JOIN Products p ON p.id = oi.product_id
GROUP BY o.id 
ORDER BY total_amount ASC;

SELECT created_at, COUNT(id) AS liczba_zamowien 
FROM Orders 
GROUP BY created_at;

SELECT user_id, COUNT(id) 
FROM Orders 
GROUP BY user_id 
HAVING COUNT(id) >= 2;

SELECT o.user_id, SUM(p.price * oi.quantity) AS bogaci_klienci 
FROM Orders o
JOIN OrderItems oi ON o.id = oi.order_id
JOIN Products p ON p.id = oi.product_id
GROUP BY o.user_id 
HAVING SUM(p.price * oi.quantity) > 500;

SELECT o.user_id, SUM(p.price * oi.quantity) AS wydatki 
FROM Orders o
JOIN OrderItems oi ON o.id = oi.order_id
JOIN Products p ON p.id = oi.product_id
GROUP BY o.user_id 
ORDER BY wydatki DESC;

SELECT TOP 3 o.user_id, SUM(p.price * oi.quantity) AS wydatki 
FROM Orders o
JOIN OrderItems oi ON o.id = oi.order_id
JOIN Products p ON p.id = oi.product_id
GROUP BY o.user_id 
ORDER BY wydatki DESC;

-- FUNKCJE

SELECT TOP 1 username, COUNT(Orders.id) AS liczba_zamowien FROM Orders
JOIN Users ON Users.id = Orders.user_id
GROUP BY username
ORDER BY liczba_zamowien DESC;

SELECT TOP 1 Products.product_name, COUNT(Orders.id) AS liczba_zamowien
FROM OrderItems
JOIN Products ON Products.id = OrderItems.product_id
JOIN Orders ON Orders.id = OrderItems.order_id
GROUP BY Products.product_name
ORDER BY liczba_zamowien DESC;

SELECT Products.product_name, COUNT(Users.id) FROM PRODUCTS
JOIN OrderItems ON Products.id = OrderItems.product_id
JOIN Orders ON Orders.id = OrderItems.order_id
JOIN Users ON Users.id = Orders.user_id
GROUP BY Products.product_name;

SELECT TOP 1 Orders.created_at, COUNT(orders.id) AS liczba_sprzedazy 
FROM Orders
GROUP BY created_at
ORDER BY liczba_sprzedazy DESC;

SELECT Products.product_name FROM Products
JOIN OrderItems ON Products.id = OrderItems.product_id
JOIN Orders ON Orders.id = OrderItems.order_id
GROUP BY Products.product_name
HAVING COUNT(Orders.id) = 1;

SELECT Users.username FROM Users
JOIN Orders ON Users.id = Orders.user_id
WHERE created_at <= DATEADD(DAY, -30, GETDATE());

CREATE PROCEDURE AddOrder
    @user_id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Users WHERE id = @user_id)
    BEGIN
        RAISERROR('User does not exist', 16, 1);
        RETURN;
    END

    INSERT INTO Orders (user_id)
    VALUES (@user_id);
END;

CREATE PROCEDURE GetUserOrders
    @user_id INT
AS
BEGIN
    SELECT o.id, p.product_name, oi.quantity
    FROM Orders o
    JOIN OrderItems oi ON o.id = oi.order_id
    JOIN Products p ON p.id = oi.product_id
    WHERE o.user_id = @user_id;
END;

CREATE VIEW wydatki_uzytkownikow
AS
SELECT u.id, u.username, SUM(p.price * oi.quantity) AS total_spent
FROM Users u
JOIN Orders o ON o.user_id = u.id
JOIN OrderItems oi ON oi.order_id = o.id
JOIN Products p ON p.id = oi.product_id
GROUP BY u.id, u.username;

SELECT * FROM wydatki_uzytkownikow;
