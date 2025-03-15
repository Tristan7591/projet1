CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    stock_quantity INTEGER NOT NULL DEFAULT 0,
    image_url VARCHAR(255),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER',
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'PENDING',
    shipping_address TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id),
    product_id INTEGER REFERENCES products(id),
    quantity INTEGER NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

-- Insertion de données de test pour les produits
INSERT INTO products (name, description, price, stock_quantity, image_url) VALUES
('Ordinateur Portable Pro', 'Ordinateur portable haute performance pour professionnels', 1299.99, 50, 'laptop.jpg'),
('Smartphone Galaxy X', 'Smartphone dernier cri avec écran pliable', 999.99, 100, 'phone.jpg'),
('Écouteurs sans fil', 'Écouteurs avec réduction de bruit active', 199.99, 200, 'earbuds.jpg'),
('Tablette MediaPad', 'Tablette légère avec écran haute résolution', 399.99, 75, 'tablet.jpg'),
('Smart TV 55"', 'Téléviseur intelligent 4K avec assistant vocal', 699.99, 25, 'tv.jpg'); 