#!/usr/bin/env python3
"""
MyHealth DHRMS - MongoDB Database Setup Script
This script connects to MongoDB and creates the necessary database and collections
"""

import sys
import pymongo
from datetime import datetime

def test_mongodb_connection():
    """Test MongoDB connection and create database"""
    
    print("🏥 MyHealth DHRMS - Database Setup")
    print("=" * 50)
    
    # MongoDB connection parameters
    connection_string = "mongodb://naresh:123456789@localhost:27017/myhealth?authSource=admin"
    database_name = "myhealth"
    
    try:
        print("📡 Connecting to MongoDB...")
        
        # Create MongoDB client
        client = pymongo.MongoClient(connection_string)
        
        # Test connection
        client.admin.command('ping')
        print("✅ Successfully connected to MongoDB!")
        
        # Get or create database
        db = client[database_name]
        print(f"🗄️  Database: {database_name}")
        
        # Create test document
        test_doc = {
            "message": "Database connection successful!",
            "timestamp": datetime.now().isoformat(),
            "database": database_name,
            "user": "naresh",
            "status": "CONNECTED"
        }
        
        # Insert test document
        test_collection = db["connection_test"]
        result = test_collection.insert_one(test_doc)
        print(f"✅ Test document inserted with ID: {result.inserted_id}")
        
        # List existing collections
        existing_collections = db.list_collection_names()
        print(f"\n📂 Existing collections ({len(existing_collections)}):")
        if existing_collections:
            for collection in existing_collections:
                print(f"   - {collection}")
        else:
            print("   No collections found (this is normal for a new database)")
        
        # Create DHRMS collections
        print("\n🏗️  Creating DHRMS collections...")
        
        dhrms_collections = [
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
        ]
        
        created_collections = []
        for collection_name in dhrms_collections:
            try:
                if collection_name not in existing_collections:
                    db.create_collection(collection_name)
                    created_collections.append(collection_name)
                    print(f"✅ Created collection: {collection_name}")
                else:
                    print(f"ℹ️  Collection already exists: {collection_name}")
            except Exception as e:
                print(f"⚠️  Failed to create collection {collection_name}: {str(e)}")
        
        # Insert sample data to verify collections work
        print("\n📝 Inserting sample data...")
        
        # Sample user
        users_collection = db["users"]
        sample_user = {
            "user_id": "USER001",
            "username": "admin",
            "role": "hospital_admin",
            "created_at": datetime.now().isoformat(),
            "status": "active"
        }
        users_collection.insert_one(sample_user)
        print("✅ Sample user inserted")
        
        # Sample hospital
        hospitals_collection = db["hospitals"]
        sample_hospital = {
            "hospital_id": "HOSP001",
            "name": "Kochi General Hospital",
            "address": "Kochi, Kerala",
            "phone": "+91 484 123 4567",
            "created_at": datetime.now().isoformat(),
            "status": "active"
        }
        hospitals_collection.insert_one(sample_hospital)
        print("✅ Sample hospital inserted")
        
        # Sample doctor
        doctors_collection = db["doctors"]
        sample_doctor = {
            "doctor_id": "DOC001",
            "name": "Dr. Rajesh Kumar",
            "specialization": "Cardiology",
            "hospital_id": "HOSP001",
            "email": "rajesh.kumar@hospital.com",
            "phone": "+91 9876543210",
            "created_at": datetime.now().isoformat(),
            "status": "active"
        }
        doctors_collection.insert_one(sample_doctor)
        print("✅ Sample doctor inserted")
        
        # Final verification
        print("\n📊 Final Database Status:")
        final_collections = db.list_collection_names()
        print(f"   Total collections: {len(final_collections)}")
        
        for collection in sorted(final_collections):
            count = db[collection].count_documents({})
            print(f"   ✅ {collection} ({count} documents)")
        
        # Test a query
        print("\n🔍 Testing data retrieval...")
        test_user = users_collection.find_one({"user_id": "USER001"})
        if test_user:
            print(f"✅ Retrieved user: {test_user['username']} ({test_user['role']})")
        
        test_hospital = hospitals_collection.find_one({"hospital_id": "HOSP001"})
        if test_hospital:
            print(f"✅ Retrieved hospital: {test_hospital['name']}")
            
        test_doctor = doctors_collection.find_one({"doctor_id": "DOC001"})
        if test_doctor:
            print(f"✅ Retrieved doctor: {test_doctor['name']} - {test_doctor['specialization']}")
        
        print("\n🎉 SUCCESS: MongoDB database 'myhealth' is ready!")
        print("🎯 Database created with all collections and sample data")
        print("🔗 Connection string: mongodb://naresh:123456789@localhost:27017/myhealth")
        
        # Close connection
        client.close()
        return True
        
    except pymongo.errors.AuthenticationError:
        print("❌ Authentication failed!")
        print("🔧 Check username: 'naresh' and password: '123456789'")
        return False
        
    except pymongo.errors.ServerSelectionTimeoutError:
        print("❌ Could not connect to MongoDB server!")
        print("🔧 Make sure MongoDB is running on localhost:27017")
        return False
        
    except Exception as e:
        print(f"❌ Unexpected error: {str(e)}")
        return False

if __name__ == "__main__":
    try:
        import pymongo
    except ImportError:
        print("❌ pymongo is not installed!")
        print("🔧 Install it with: pip install pymongo")
        sys.exit(1)
    
    success = test_mongodb_connection()
    if success:
        print("\n✅ Ready to proceed with backend implementation!")
        sys.exit(0)
    else:
        print("\n❌ Database setup failed. Please fix the issues and try again.")
        sys.exit(1)
