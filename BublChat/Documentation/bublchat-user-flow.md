# BublChat MVP User Flow

## Initial Access
1. **User Opens App**
2. **Authentication**
   - New User → Sign Up Process → Brief Onboarding
   - Existing User → Log In
3. **Main Dashboard**
   - Central hub for accessing all features

## Interaction Modes
From the Main Dashboard, users can select one of three interaction modes:

### Text Chat Flow
1. **Enter Text Chat Interface**
2. **User Sends Text Message**
3. **System Processes Text via NLP**
4. **Bubl Responds with Text + Animation**
5. **Continue Chat or Return to Dashboard**

### Voice Call Flow
1. **Initiate Voice Call**
2. **Call Connected with Bubl**
3. **User Speaks**
4. **System Processes Speech via NLP**
5. **Bubl Responds with Voice**
6. **Continue Call or End and Return to Dashboard**

### Video Chat Flow
1. **Initiate Video Call**
2. **Video Connected with Animated Bubl**
3. **User Speaks/Shows Environment**
4. **System Processes Audio/Visual Input**
5. **Bubl Responds with Animation + Voice**
6. **Continue Video Chat or End and Return to Dashboard**

## Additional Functions
- **Settings**: Access from Dashboard, return to Dashboard
- **Logout**: Return to app opening screen

## Key User Interactions
- Users can seamlessly switch between interaction modes via Dashboard
- Each mode maintains conversation context when possible
- All interaction modes follow the same general pattern:
  - User initiates interaction
  - System processes input
  - Bubl generates appropriate response
  - User chooses to continue or end session

## Technical Considerations
- Authentication must be smooth and quick
- Dashboard should clearly present all interaction options
- Each interaction mode should have intuitive controls
- Transitions between dashboard and interaction modes should be seamless
- System should handle network interruptions gracefully
