# React Frontend Security Checklist

This checklist covers security best practices for your React frontend application to protect against common web vulnerabilities.

## Dependency Management

- [ ] Run `npm audit` regularly to check for vulnerable dependencies
- [ ] Pin dependency versions to prevent unexpected updates
- [ ] Use lockfiles (package-lock.json) to ensure consistent installations
- [ ] Minimize dependency usage to reduce attack surface
- [ ] Remove unused dependencies to reduce vulnerabilities

## XSS (Cross-Site Scripting) Prevention

- [ ] Use React's built-in XSS protection by avoiding `dangerouslySetInnerHTML`
- [ ] When `dangerouslySetInnerHTML` is necessary, use a sanitization library like DOMPurify:

```jsx
import DOMPurify from "dompurify";

function Component({ userProvidedHtml }) {
  return (
    <div
      dangerouslySetInnerHTML={{
        __html: DOMPurify.sanitize(userProvidedHtml),
      }}
    />
  );
}
```

- [ ] Avoid inline JavaScript in JSX attributes
- [ ] Use TypeScript to ensure proper typing of user inputs
- [ ] Be careful with URL parameters - sanitize and validate them

## Authentication & Authorization

- [ ] Store tokens securely (preferably in memory, session storage over local storage)
- [ ] Implement token refresh logic to handle expiration
- [ ] Implement proper logout functionality that clears tokens
- [ ] Add authorization checks on the client side
- [ ] Verify all authorization on the server side (client-side is for UX only)

Example of secure token storage with React:

```jsx
// AuthContext.js
import React, { createContext, useState, useContext, useEffect } from "react";

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  // Store in memory - will be lost on page refresh
  // For persistence, could use sessionStorage (better than localStorage)
  const [token, setToken] = useState(null);

  // Load from sessionStorage on mount
  useEffect(() => {
    const storedToken = sessionStorage.getItem("auth_token");
    if (storedToken) {
      setToken(storedToken);
    }
  }, []);

  const login = (newToken) => {
    setToken(newToken);
    // If persistence needed, store in sessionStorage
    sessionStorage.setItem("auth_token", newToken);
  };

  const logout = () => {
    setToken(null);
    sessionStorage.removeItem("auth_token");
    // Additional cleanup as needed
  };

  return (
    <AuthContext.Provider
      value={{ token, login, logout, isAuthenticated: !!token }}
    >
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => useContext(AuthContext);
```

## CSRF Protection

- [ ] Use proper CSRF tokens for forms
- [ ] Include CSRF tokens in all state-changing requests
- [ ] Ensure cookies use SameSite attribute

Example with an API client:

```jsx
import axios from "axios";

const api = axios.create({
  baseURL: "/api",
  withCredentials: true, // Include cookies with requests
});

// Add CSRF token to requests if needed
api.interceptors.request.use((config) => {
  const token = document
    .querySelector('meta[name="csrf-token"]')
    ?.getAttribute("content");
  if (token) {
    config.headers["X-CSRF-Token"] = token;
  }
  return config;
});

export default api;
```

## Content Security Policy (CSP)

- [ ] Implement a strict Content Security Policy
- [ ] Avoid `unsafe-inline` and `unsafe-eval` in CSP when possible
- [ ] Use nonces for inline scripts when needed
- [ ] Use CSP reporting to monitor violations

Example CSP in your index.html:

```html
<meta
  http-equiv="Content-Security-Policy"
  content="default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; connect-src 'self' https://api.yourservice.com;"
/>
```

## Sensitive Data Exposure

- [ ] Don't store sensitive data in local/session storage
- [ ] Don't log sensitive information to the console
- [ ] Implement proper form validation
- [ ] Clear sensitive data from memory when no longer needed
- [ ] Don't include sensitive data in URLs

## Route Protection

- [ ] Implement protected routes for authenticated content
- [ ] Redirect unauthorized access attempts to login
- [ ] Handle authentication state loading gracefully

```jsx
// ProtectedRoute.jsx
import { Navigate, Outlet } from "react-router-dom";
import { useAuth } from "./AuthContext";

function ProtectedRoute() {
  const { isAuthenticated, token } = useAuth();

  // If authentication is loading, show loading screen
  if (token === null) {
    return <div>Loading...</div>;
  }

  // If not authenticated, redirect to login
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  // If authenticated, render the child routes
  return <Outlet />;
}

// In your routes configuration:
// <Route element={<ProtectedRoute />}>
//   <Route path="/dashboard" element={<Dashboard />} />
//   <Route path="/profile" element={<Profile />} />
// </Route>
```

## API Security

- [ ] Don't expose API keys in frontend code
- [ ] Handle API errors gracefully
- [ ] Implement proper loading and error states
- [ ] Add timeout for API requests
- [ ] Validate all data received from API

Example API client with timeout and error handling:

```jsx
import axios from "axios";

const api = axios.create({
  baseURL: "/api",
  timeout: 10000, // 10 seconds
  withCredentials: true,
});

api.interceptors.response.use(
  (response) => response,
  (error) => {
    // Log error but don't expose detailed error messages to users
    console.error("API Error:", error);

    // Handle specific errors
    if (error.response) {
      // Server responded with error status
      if (error.response.status === 401) {
        // Unauthorized - redirect to login
        window.location.href = "/login";
        return Promise.reject(new Error("Please log in to continue"));
      }

      if (error.response.status === 403) {
        // Forbidden - user doesn't have permissions
        return Promise.reject(
          new Error("You don't have permission to access this resource")
        );
      }
    } else if (error.request) {
      // Request made but no response received
      return Promise.reject(
        new Error("Network error - please try again later")
      );
    }

    // Default generic error
    return Promise.reject(new Error("Something went wrong"));
  }
);

export default api;
```

## Forms & User Input

- [ ] Validate all form inputs on both client and server
- [ ] Implement proper error messages for validation
- [ ] Rate limit form submissions to prevent abuse
- [ ] Use HTTPS for all form submissions
- [ ] Sanitize file uploads and implement proper file validation

Example form validation with React Hook Form:

```jsx
import { useForm } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import * as yup from "yup";

// Define validation schema
const schema = yup.object({
  username: yup
    .string()
    .required("Username is required")
    .min(3, "Username must be at least 3 characters")
    .max(20, "Username must be less than 20 characters"),
  email: yup
    .string()
    .required("Email is required")
    .email("Invalid email format"),
  password: yup
    .string()
    .required("Password is required")
    .min(8, "Password must be at least 8 characters")
    .matches(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/,
      "Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character"
    ),
});

function RegistrationForm() {
  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm({
    resolver: yupResolver(schema),
  });

  const onSubmit = (data) => {
    // Submit data to server
  };

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <div>
        <label htmlFor="username">Username</label>
        <input id="username" {...register("username")} />
        {errors.username && <p>{errors.username.message}</p>}
      </div>

      <div>
        <label htmlFor="email">Email</label>
        <input id="email" type="email" {...register("email")} />
        {errors.email && <p>{errors.email.message}</p>}
      </div>

      <div>
        <label htmlFor="password">Password</label>
        <input id="password" type="password" {...register("password")} />
        {errors.password && <p>{errors.password.message}</p>}
      </div>

      <button type="submit">Register</button>
    </form>
  );
}
```

## Error Handling & Logging

- [ ] Implement global error boundaries to catch React errors
- [ ] Don't expose detailed error messages to users
- [ ] Log errors in a structured way for monitoring
- [ ] Sanitize error details before logging to prevent sensitive data exposure
- [ ] Implement proper fallbacks for failed components

Example Error Boundary component:

```jsx
import React from "react";

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI
    return { hasError: true };
  }

  componentDidCatch(error, errorInfo) {
    // Log the error to an error reporting service
    console.error("React Error Boundary caught an error:", error, errorInfo);

    // You could send to a monitoring service like Sentry
    // logErrorToService(error, errorInfo);
  }

  render() {
    if (this.state.hasError) {
      // You can render any custom fallback UI
      return this.props.fallback || <h1>Something went wrong.</h1>;
    }

    return this.props.children;
  }
}

// Usage
// <ErrorBoundary>
//   <YourComponent />
// </ErrorBoundary>
```

## Build & Deployment

- [ ] Enable source maps only for development
- [ ] Minify and obfuscate production code
- [ ] Implement proper cache control headers
- [ ] Use subresource integrity when loading external scripts
- [ ] Perform regular security scans of the deployed application

## Additional Resources

- [OWASP Top Ten](https://owasp.org/www-project-top-ten/)
- [React Security Best Practices](https://reactjs.org/docs/security.html)
- [Web Security Academy](https://portswigger.net/web-security)
- [Content Security Policy (CSP)](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP)
- [JavaScript Security Best Practices](https://snyk.io/learn/javascript-security-best-practices/)
