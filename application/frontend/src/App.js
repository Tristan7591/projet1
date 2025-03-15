import React, { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Fonction pour récupérer les produits
    const fetchProducts = async () => {
      try {
        const response = await axios.get('/api/products');
        setProducts(response.data);
        setLoading(false);
      } catch (error) {
        console.error('Erreur lors de la récupération des produits:', error);
        setLoading(false);
      }
    };

    fetchProducts();
  }, []);

  return (
    <div className="app">
      <header>
        <h1>Digital Store</h1>
      </header>
      
      <main>
        <h2>Nos Produits</h2>
        
        {loading ? (
          <p>Chargement des produits...</p>
        ) : (
          <div className="products">
            {products.length > 0 ? (
              products.map(product => (
                <div className="product-card" key={product.id}>
                  <h3>{product.name}</h3>
                  <p>{product.description}</p>
                  <p className="price">{product.price} €</p>
                  <button>Ajouter au panier</button>
                </div>
              ))
            ) : (
              <p>Aucun produit disponible.</p>
            )}
          </div>
        )}
      </main>
      
      <footer>
        <p>&copy; 2024 Digital Store. Tous droits réservés.</p>
      </footer>
    </div>
  );
}

export default App; 