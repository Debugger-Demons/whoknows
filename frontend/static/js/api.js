/**
 * @description API client for Frontend to communicate with Backend
 *
 * @url http://<Container-Service-Name>:${BACKEND_INTERNAL_PORT}
 * @url fx. http://backend:92
 *
 * @note CSRF token is included in all requests
 * - benefit:
 *   - prevents CSRF attacks
 *   - prevents XSS attacks (csrf token helps prevent XSS attacks by validating the request origin)
 *   - prevents SQL injection attacks
 *   - prevents file upload attacks
 *   - prevents remote code execution attacks
 *   - prevents cross-site request forgery attacks
 *   - prevents clickjacking attacks
 * - CSRF token is fetched from the meta tag in the HTML file
 * - CSRF token is sent in the header of all requests
 * - CSRF token is sent in the body of POST requests
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
      const csrfToken = this.getCSRFToken();

      /**
       * @description Fetch the search results from the backend
       * @param {string} url - The URL to fetch the search results from
       * @returns {Promise<Object>} - Promise resolving to search results
       *
       * @note fetch() finds network to Backend container
       * - backend cotainer is found by service name in docker-compose.yml
       */
      const response = await fetch(url, {
        headers: {
          "X-CSRF-TOKEN": csrfToken,
        },
        credentials: "include", // cookies are included in requests
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
   * Attempt to log in a user
   * @param {string} username - The username
   * @param {string} password - The password
   * @returns {Promise<Object>} - Promise resolving to login result
   */
  async login(username, password) {
    try {
      const url = `/api/login`;
      const csrfToken = this.getCSRFToken();
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-TOKEN": csrfToken,
        },
        body: `username=${encodeURIComponent(
          username
        )}&password=${encodeURIComponent(password)}`,
        credentials: "include", // Send cookies with the request
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error("Login error:", error);
      return { success: false, error: "Login failed" };
    }
  }

  /**
   * Logout a user
   * @returns {Promise<Object>} - Promise resolving to logout result
   */
  async logout() {
    try {
      const url = `/api/logout`;
      const csrfToken = this.getCSRFToken();
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "X-CSRF-TOKEN": csrfToken,
        },
        credentials: "include", // cookies are included in requests
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error("Logout error:", error);
      return { success: false, error: "Logout failed" };
    }
  }

  /**
   * Register a new user
   * @param {Object} userData - User registration data
   * @returns {Promise<Object>} - Promise resolving to registration result
   */
  async register(userData) {
    try {
      const url = `/api/register`;
      const csrfToken = this.getCSRFToken();
      const formData = new URLSearchParams();

      for (const [key, value] of Object.entries(userData)) {
        formData.append(key, value);
      }

      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          "X-CSRF-TOKEN": csrfToken,
        },
        body: formData,
        credentials: "include", // cookies are included in requests
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      console.error("Registration error:", error);
      return { success: false, error: "Registration failed" };
    }
  }

  getCSRFToken() {
    const csrfTokenElement = document.querySelector('meta[name="csrf-token"]');
    const csrfToken = csrfTokenElement
      ? csrfTokenElement.getAttribute("content")
      : "";
    return csrfToken;
  }
}

// Create a global API client instance
const api = new ApiClient();
