package com.dhrms.myhealth.controller;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoDatabase;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/test")
@CrossOrigin(origins = "*")
public class DatabaseTestController {

    @Autowired
    private MongoTemplate mongoTemplate;

    @Autowired
    private MongoClient mongoClient;

    @GetMapping("/db-connection")
    public ResponseEntity<Map<String, Object>> testDatabaseConnection() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Test MongoDB connection
            MongoDatabase database = mongoClient.getDatabase("myhealth");
            
            // Create a test collection and insert a document
            Map<String, Object> testDocument = new HashMap<>();
            testDocument.put("testMessage", "Database connection successful!");
            testDocument.put("timestamp", LocalDateTime.now().toString());
            testDocument.put("database", "myhealth");
            testDocument.put("user", "naresh");
            
            mongoTemplate.insert(testDocument, "connection_test");
            
            // Get database stats
            response.put("status", "SUCCESS");
            response.put("message", "MongoDB connection established successfully!");
            response.put("database", "myhealth");
            response.put("timestamp", LocalDateTime.now().toString());
            response.put("collections", mongoTemplate.getCollectionNames());
            
            // Test document retrieval
            Map<String, Object> retrievedDoc = mongoTemplate.findById(testDocument.get("_id"), Map.class, "connection_test");
            response.put("testDocument", retrievedDoc);
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("status", "ERROR");
            response.put("message", "Database connection failed: " + e.getMessage());
            response.put("timestamp", LocalDateTime.now().toString());
            
            return ResponseEntity.status(500).body(response);
        }
    }

    @GetMapping("/health")
    public ResponseEntity<Map<String, Object>> healthCheck() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "UP");
        response.put("service", "MyHealth DHRMS Backend");
        response.put("timestamp", LocalDateTime.now().toString());
        response.put("database", "myhealth");
        
        return ResponseEntity.ok(response);
    }

    @PostMapping("/create-collections")
    public ResponseEntity<Map<String, Object>> createInitialCollections() {
        Map<String, Object> response = new HashMap<>();
        
        try {
            // Create collections for DHRMS
            String[] collections = {
                "users",
                "patients", 
                "doctors",
                "hospitals",
                "prescriptions",
                "medical_records",
                "health_vitals",
                "appointments",
                "emergency_contacts",
                "audit_logs"
            };
            
            for (String collectionName : collections) {
                if (!mongoTemplate.collectionExists(collectionName)) {
                    mongoTemplate.createCollection(collectionName);
                }
            }
            
            response.put("status", "SUCCESS");
            response.put("message", "All collections created successfully!");
            response.put("collections", collections);
            response.put("timestamp", LocalDateTime.now().toString());
            
            return ResponseEntity.ok(response);
            
        } catch (Exception e) {
            response.put("status", "ERROR");
            response.put("message", "Failed to create collections: " + e.getMessage());
            response.put("timestamp", LocalDateTime.now().toString());
            
            return ResponseEntity.status(500).body(response);
        }
    }
}
