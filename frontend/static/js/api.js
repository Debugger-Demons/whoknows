/**
 * API client for the Who Knows backend
 */
class ApiClient {
  constructor() {
    // No longer need backendUrl or init
  }

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
      const response = await fetch(url);

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
      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: `username=${encodeURIComponent(
          username
        )}&password=${encodeURIComponent(password)}`,
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
   * Register a new user
   * @param {Object} userData - User registration data
   * @returns {Promise<Object>} - Promise resolving to registration result
   */
  async register(userData) {
    try {
      const url = `/api/register`;
      const formData = new URLSearchParams();

      for (const [key, value] of Object.entries(userData)) {
        formData.append(key, value);
      }

      const csrfToken = document
        .querySelector('meta[name="csrf-token"]')
        .getAttribute("content");
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
}

// Create a global API client instance
const api = new ApiClient();
