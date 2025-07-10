-- Creación de tablas
CREATE TABLE IF NOT EXISTS orders (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE IF NOT EXISTS customers (
    customer_id INTEGER PRIMARY KEY,
    name TEXT,
    email TEXT,
    registration_date DATE
);

CREATE TABLE IF NOT EXISTS products (
    product_id INTEGER PRIMARY KEY,
    name TEXT,
    price DECIMAL(10, 2),
    category TEXT
);

CREATE TABLE IF NOT EXISTS order_items (
    order_id INTEGER,
    product_id INTEGER,
    quantity INTEGER,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Pregunta 1: Obtener los 10 clientes con más órdenes en los últimos 6 meses
SELECT c.name, c.email, COUNT(o.order_id) AS total_orders
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_date >= '2023-11-01'
GROUP BY c.customer_id
ORDER BY total_orders DESC
LIMIT 10;

-- Pregunta 2: Calcular el promedio de gasto por categoría de producto para clientes registrados en 2023
SELECT p.category, AVG(oi.quantity * p.price) AS avg_spent
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
WHERE STRFTIME('%Y', c.registration_date) = '2023'
GROUP BY p.category
ORDER BY avg_spent DESC;

-- Pregunta 3: Detección de registros duplicados o inconsistentes en la tabla `customers`
WITH duplicated_customers AS (
    SELECT customer_id, name, email, registration_date
    FROM customers
    GROUP BY customer_id, name, email, registration_date
    HAVING COUNT(*) > 1
),
invalid_emails AS (
    SELECT customer_id, name, email, registration_date
    FROM customers
    WHERE email NOT LIKE '%@%' OR email LIKE '%..%' OR email LIKE '% %'
),
null_dates AS (
    SELECT customer_id, name, email, registration_date
    FROM customers
    WHERE registration_date IS NULL
)
SELECT * FROM duplicated_customers
UNION ALL
SELECT * FROM invalid_emails
UNION ALL
SELECT * FROM null_dates;