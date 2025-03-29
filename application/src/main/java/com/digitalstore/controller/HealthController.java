package com.digitalstore.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

/**
 * Contrôleur pour les vérifications de santé de l'application.
 * Fournit un endpoint pour les healthchecks en complément de Spring Actuator.
 */
@RestController
public class HealthController {

    /**
     * Endpoint principal de santé.
     * @return Statut OK et informations sur l'application
     */
    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> health() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "digital-store-backend");
        response.put("timestamp", System.currentTimeMillis());
        
        return ResponseEntity.ok(response);
    }
} 