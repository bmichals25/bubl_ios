require('dotenv').config();
const admin = require('firebase-admin');

console.log('Attempting to initialize Firebase Admin SDK...');

try {
  // Initialize the app with credentials from environment variable
  admin.initializeApp({
    credential: admin.credential.applicationDefault()
  });
  
  console.log('✅ Firebase Admin SDK initialized successfully!');
  
  // List the first few users to verify connection (if any exist)
  admin.auth().listUsers(3)
    .then((listUsersResult) => {
      console.log('Firebase connection verified:');
      console.log(`Total users: ${listUsersResult.users.length}`);
      
      if (listUsersResult.users.length > 0) {
        console.log('Sample user emails:');
        listUsersResult.users.forEach((userRecord) => {
          console.log(`  - ${userRecord.email || 'No email'}`);
        });
      } else {
        console.log('No users found. This is normal for a new project.');
      }
    })
    .catch((error) => {
      console.log('Error listing users:', error.message);
    })
    .finally(() => {
      console.log('Test completed.');
    });
} catch (error) {
  console.error('❌ Firebase Admin SDK initialization failed:', error.message);
  console.error('Make sure your GOOGLE_APPLICATION_CREDENTIALS environment variable is set correctly.');
} 