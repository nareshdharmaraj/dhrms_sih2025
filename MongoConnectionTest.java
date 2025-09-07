// Simple MongoDB Connection Test
// This file tests MongoDB connection without Spring Boot
// Compile and run: java -cp "mongodb-driver-sync-4.9.1.jar:." MongoConnectionTest

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoCollection;
import org.bson.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class MongoConnectionTest {
    
    public static void main(String[] args) {
        System.out.println("🏥 MyHealth DHRMS - MongoDB Connection Test");
        System.out.println("=============================================");
        
        // MongoDB connection string
        String connectionString = "mongodb://naresh:123456789@localhost:27017/myhealth?authSource=admin";
        
        try {
            System.out.println("📡 Connecting to MongoDB...");
            
            // Create MongoDB client
            MongoClient mongoClient = MongoClients.create(connectionString);
            
            // Get database
            MongoDatabase database = mongoClient.getDatabase("myhealth");
            
            System.out.println("✅ Successfully connected to MongoDB!");
            System.out.println("🗄️  Database: " + database.getName());
            
            // Test database by creating a test collection and document
            MongoCollection<Document> testCollection = database.getCollection("connection_test");
            
            // Create test document
            Document testDoc = new Document("message", "Database connection successful!")
                    .append("timestamp", LocalDateTime.now().toString())
                    .append("database", "myhealth")
                    .append("user", "naresh")
                    .append("status", "CONNECTED");
            
            // Insert test document
            testCollection.insertOne(testDoc);
            System.out.println("✅ Test document inserted successfully!");
            
            // Retrieve and verify document
            Document retrieved = testCollection.find().first();
            if (retrieved != null) {
                System.out.println("✅ Test document retrieved successfully!");
                System.out.println("📄 Document: " + retrieved.toJson());
            }
            
            // List all collections
            System.out.println("\n📂 Existing collections:");
            List<String> collectionNames = new ArrayList<>();
            database.listCollectionNames().forEach(collectionNames::add);
            
            if (collectionNames.isEmpty()) {
                System.out.println("   No collections found. This is normal for a new database.");
            } else {
                for (String name : collectionNames) {
                    System.out.println("   - " + name);
                }
            }
            
            // Create initial collections for DHRMS
            System.out.println("\n🏗️  Creating DHRMS collections...");
            String[] dhrmsCollections = {
                "users", "patients", "doctors", "hospitals", 
                "prescriptions", "medical_records", "health_vitals",
                "appointments", "emergency_contacts", "audit_logs"
            };
            
            for (String collectionName : dhrmsCollections) {
                try {
                    database.createCollection(collectionName);
                    System.out.println("✅ Created collection: " + collectionName);
                } catch (Exception e) {
                    if (e.getMessage().contains("already exists")) {
                        System.out.println("ℹ️  Collection already exists: " + collectionName);
                    } else {
                        System.out.println("⚠️  Failed to create collection " + collectionName + ": " + e.getMessage());
                    }
                }
            }
            
            // Final verification
            System.out.println("\n📊 Final Database Status:");
            List<String> finalCollections = new ArrayList<>();
            database.listCollectionNames().forEach(finalCollections::add);
            System.out.println("   Total collections: " + finalCollections.size());
            
            for (String name : finalCollections) {
                System.out.println("   ✅ " + name);
            }
            
            System.out.println("\n🎉 MongoDB setup completed successfully!");
            System.out.println("🗄️  Database 'myhealth' is ready for DHRMS application!");
            
            // Close connection
            mongoClient.close();
            
        } catch (Exception e) {
            System.err.println("❌ MongoDB connection failed!");
            System.err.println("Error: " + e.getMessage());
            System.err.println("\n🔧 Troubleshooting:");
            System.err.println("1. Make sure MongoDB is running");
            System.err.println("2. Verify username 'naresh' and password '123456789'");
            System.err.println("3. Check if 'myhealth' database exists in MongoDB Compass");
            System.err.println("4. Ensure MongoDB is running on localhost:27017");
            
            e.printStackTrace();
        }
    }
}
