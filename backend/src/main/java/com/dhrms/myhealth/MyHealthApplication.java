package com.dhrms.myhealth;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.mongodb.config.EnableMongoAuditing;

@SpringBootApplication
@EnableMongoAuditing
public class MyHealthApplication {

    public static void main(String[] args) {
        SpringApplication.run(MyHealthApplication.class, args);
        System.out.println("\n🏥 MyHealth DHRMS Backend Started Successfully!");
        System.out.println("📊 Server running on: http://localhost:8080/api");
        System.out.println("🔍 Health Check: http://localhost:8080/api/actuator/health");
        System.out.println("🗄️  Database Connection Test: http://localhost:8080/api/test/db-connection");
    }
}
