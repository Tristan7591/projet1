package com.digitalstore.repository;

import com.digitalstore.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface ProductRepository extends JpaRepository<Product, Long> {
    
    List<Product> findByNameContainingIgnoreCase(String name);
    
    List<Product> findByPriceLessThanEqual(BigDecimal maxPrice);
    
    List<Product> findByStockQuantityGreaterThan(Integer minStock);
} 