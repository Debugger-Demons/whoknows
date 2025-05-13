# Client-Side Architecture

## Overview
The frontend client-side implementation uses vanilla JavaScript and HTML/CSS to create a lightweight, fast-loading search interface. This document outlines the client-side components, their interactions, and implementation details.

## File Structure

```
static/
├── html/          # HTML templates
│   ├── search.html     # Main search page
│   ├── login.html      # User login page
│   ├── register.html   # User registration page
│   └── about.html      # About page
├── js/            # JavaScript functionality
│   ├── api.js          # API client library
│   ├── search.js       # Search functionality
│   ├── login.js        # Login handling
│   ├── register.js     # Registration handling
│   └── validation.js   # Input validation
└── css/           # Styling
    └── styles.css      # Global styles
```

## Core Components

### API Client
The `api.js` file provides a JavaScript client for interacting with the backend API:

- **Features**:
  - Handles authentication (login/logout)
  - Performs search queries
  - Manages user registration
  - Implements error handling

- **Key Methods**:
  - `search(query, language)`: Perform a search
  - `login(username, password)`: Authenticate a user
  - `logout()`: End a user session
  - `register(userData)`: Register a new user

### Page-Specific Logic

#### Search Page
The `search.js` file implements search functionality:
- Event handling for search input
- Results rendering
- Error handling

#### Login Page
The `login.js` file manages authentication:
- Form submission
- Input validation
- Error messaging
- Redirection after successful login

#### Registration Page
The `register.js` file handles user registration:
- Form submission
- Validation of username, email, and password
- Error handling and feedback

## Authentication Flow

1. **Login Request**:
   ```javascript
   // User enters credentials
   api.login(username, password)
     .then(response => {
       if (response.success) {
         // Handle successful login
       } else {
         // Display error
       }
     });
   ```

2. **Registration Flow**:
   ```javascript
   // User submits registration form
   api.register({
     username: username,
     email: email,
     password: password,
     password2: passwordConfirm
   })
     .then(response => {
       // Handle registration result
     });
   ```

## Search Implementation

The search feature follows this pattern:
1. User inputs search term
2. JavaScript captures form submission event
3. API client makes request to `/api/search` endpoint (proxied to backend)
4. Results are rendered in the DOM

Example from `search.js`:
```javascript
searchButton.addEventListener('click', async () => {
  const query = searchInput.value;
  const results = await api.search(query);
  displayResults(results);
});
```

## Security Considerations

1. **Input Validation**:
   - All user input is validated before submission
   - `validation.js` provides utility functions for input sanitization

2. **Content Security**:
   - DOMPurify library is used to sanitize HTML content
   - Prevents XSS attacks when rendering search results

3. **Authentication**:
   - Credentials are sent over HTTPS (in production)
   - Session cookies are used for maintaining authentication
   - API proxy ensures backend is not directly exposed 