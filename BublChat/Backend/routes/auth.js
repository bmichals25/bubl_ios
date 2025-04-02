const express = require('express');
const router = express.Router();
const firebaseAdmin = require('firebase-admin');

// Middleware to verify Firebase token
const verifyToken = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized: No token provided' });
  }
  
  const token = authHeader.split(' ')[1];
  
  try {
    const decodedToken = await firebaseAdmin.auth().verifyIdToken(token);
    req.user = decodedToken;
    next();
  } catch (error) {
    console.error('Token verification error:', error);
    return res.status(403).json({ error: 'Forbidden: Invalid token' });
  }
};

// Get current user profile
router.get('/me', verifyToken, async (req, res) => {
  try {
    const userRecord = await firebaseAdmin.auth().getUser(req.user.uid);
    
    res.json({
      uid: userRecord.uid,
      email: userRecord.email,
      displayName: userRecord.displayName || '',
      photoURL: userRecord.photoURL || '',
      emailVerified: userRecord.emailVerified
    });
  } catch (error) {
    console.error('Error fetching user:', error);
    res.status(500).json({ error: 'Failed to fetch user data' });
  }
});

// Update user profile
router.put('/profile', verifyToken, async (req, res) => {
  try {
    const { displayName, photoURL } = req.body;
    
    // Update Firebase user
    await firebaseAdmin.auth().updateUser(req.user.uid, {
      displayName: displayName || null,
      photoURL: photoURL || null
    });
    
    res.json({ success: true, message: 'Profile updated successfully' });
  } catch (error) {
    console.error('Error updating profile:', error);
    res.status(500).json({ error: 'Failed to update profile' });
  }
});

module.exports = router; 