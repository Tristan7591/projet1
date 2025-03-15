package com.digitalstore.service;

import com.digitalstore.model.Product;
import com.digitalstore.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProductService {
    
    private final ProductRepository productRepository;
    
    public List<Product> getAllProducts() {
        return productRepository.findAll();
    }
    
    public Optional<Product> getProductById(Long id) {
        return productRepository.findById(id);
    }
    
    public List<Product> searchProductsByName(String name) {
        return productRepository.findByNameContainingIgnoreCase(name);
    }
    
    public List<Product> getProductsInPriceRange(BigDecimal maxPrice) {
        return productRepository.findByPriceLessThanEqual(maxPrice);
    }
    
    public List<Product> getAvailableProducts() {
        return productRepository.findByStockQuantityGreaterThan(0);
    }
    
    @Transactional
    public Product saveProduct(Product product) {
        return productRepository.save(product);
    }
    
    @Transactional
    public void deleteProduct(Long id) {
        productRepository.deleteById(id);
    }
    
    @Transactional
    public boolean updateStock(Long productId, int quantity) {
        Optional<Product> productOpt = productRepository.findById(productId);
        
        if (productOpt.isPresent()) {
            Product product = productOpt.get();
            
            if (product.getStockQuantity() >= quantity) {
                product.setStockQuantity(product.getStockQuantity() - quantity);
                productRepository.save(product);
                return true;
            }
        }
        
        return false;
    }
} 