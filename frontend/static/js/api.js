/**
 * @description API client for Frontend to communicate with Backend
 *
 * @url http://<Container-Service-Name>:${BACKEND_INTERNAL_PORT}
 * @url fx. http://backend:92
 *
 * @note THIS CLIENT DOES NOT IMPLEMENT CSRF PROTECTION.
 * Ensure your backend API either uses alternative security measures (like stateless token auth)
 * or that you understand and accept the risks of CSRF attacks if using session cookies.
 */
class ApiClient {
  /**
   * Perform a search query
   * @param {string} query - The search query
   * @param {string} language - The language code (default: en)
   * @returns {Promise<Object>} - Promise resolving to search results
   */
  async search(query, language = "en") {
    try {
      const url = `/api/search?q=${encodeURIComponent(
        query
      )}&language=${language}`;

      const response = await fetch(url, {
        credentials: "include",
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error("Search error:", error);
      return { search_results: [] };
    }
  }

  /**
   * Attempt to log in a user by sending JSON data.
   * @param {string} username - The username
   * @param {string} password - The password
   * @returns {Promise<Object>} - Promise resolving to login result
   */
  async login(username, password) {
    try {
      const url = `/api/login`;
      // Prepare login data as a JavaScript object
      const loginData = {
        username: username,
        password: password,
      };

      const response = await fetch(url, {
        method: "POST",
        headers: {
          // *** Set Content-Type to application/json ***
          "Content-Type": "application/json",
          // Optional: Indicate that we expect a JSON response back
          Accept: "application/json",
        },
        // *** Stringify the login data object for the body ***
        body: JSON.stringify(loginData),
        credentials: "include", // Send cookies with the request
      });

      // --- Start: Improved Error Handling (Optional but recommended) ---
      if (!response.ok) {
        // Handles 400, 401, 403, 404, 500 etc.
        let errorData = { message: `HTTP error! status: ${response.status}` };
        try {
          // Attempt to parse potential JSON error response from the backend
          const errorJson = await response.json();
          // Merge backend error details if available (e.g., {"error": "Invalid credentials"})
          errorData = { ...errorData, ...errorJson };
        } catch (parseError) {
          // If backend error response isn't JSON or is empty, add status text
          errorData.message += ` ${response.statusText || ""}`.trim();
        }
        // Create an Error object with more details
        const error = new Error(errorData.error || errorData.message); // Prioritize specific error message from backend
        error.status = response.status;
        error.data = errorData; // Attach full error data
        throw error; // Throw the detailed error
      }
      // --- End: Improved Error Handling ---

      // Parse the successful JSON response (e.g., {"success": true, "user": {...}})
      return await response.json();
    } catch (error) {
      // Log the detailed error from the catch block
      console.error(
        "Login error:",
        error.status,
        error.message,
        error.data || error
      );
      // Return a structured error object for the calling code (login.js)
      return {
        success: false,
        status: error.status || null, // Include HTTP status if available
        // Prioritize specific error message from backend if available
        error: error.data?.error || error.message || "Login failed",
      };
    }
  }

  /**
   * Logout a user
   * @returns {Promise<Object>} - Promise resolving to logout result
   */
  async logout() {
    try {
      const url = `/api/logout`;
      const response = await fetch(url, {
        method: "POST",
        headers: {
          // No specific headers needed usually for logout, unless backend requires them
        },
        credentials: "include", // Send cookies to invalidate session
      });

      if (!response.ok) {
        // --- Add similar improved error handling as login if needed ---
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      // Often logout might return empty body or simple {success: true}
      // Handle potential empty response body gracefully
      try {
        return await response.json();
      } catch (e) {
        // If parsing fails (e.g., empty body), return success based on status code
        return { success: response.ok };
      }
    } catch (error) {
      console.error("Logout error:", error);
      return { success: false, error: "Logout failed" };
    }
  }

  /**
   * Register a new user by sending JSON data
   * @param {Object} userData - User registration data
   * @returns {Promise<Object>} - Promise resolving to registration result
   */
  async register(userData) {
    try {
      const url = `/api/register`;
      const bodyData = JSON.stringify(userData);

      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
        },
        body: bodyData,
        credentials: "include",
      });

      if (!response.ok) {
        let errorData = { message: `HTTP error! status: ${response.status}` };
        try {
          const errorJson = await response.json();
          errorData = { ...errorData, ...errorJson };
        } catch (parseError) {
          errorData.message += ` ${response.statusText || ""}`.trim();
        }
        const error = new Error(errorData.error || errorData.message);
        error.status = response.status;
        error.data = errorData;
        throw error;
      }

      return await response.json();
    } catch (error) {
      console.error(
        "Registration error:",
        error.status,
        error.message,
        error.data || error
      );
      return {
        success: false,
        status: error.status || null,
        error: error.data?.error || error.message || "Registration failed",
      };
    }
  }
}

// Create a global API client instance
const api = new ApiClient();
