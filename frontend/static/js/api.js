/**
 * API client for the Who Knows backend
 */
class ApiClient {
  constructor() {
    this.backendUrl = window.BACKEND_URL || "http://backend:92";
    this.init();
  }

  /**
   * Initialize the API client
   *
   * in Docker container, the backend is accessible at http://backend:92
   * in local development, the backend is accessible at http://localhost:xxxx
   *
   * the fetch call to /api/config will return the correct backend URL of the backend container
   * - it is called when the page is loaded
   */
  async init() {
    try {
      const response = await fetch("/api/config");
      if (response.ok) {
        const config = await response.json();
        this.backendUrl = config.BACKEND_URL;
      }
    } catch (error) {
      console.error("Failed to load config:", error);
    }
  }

  /**
   * Perform a search query
   * @param {string} query - The search query
   * @param {string} language - The language code (default: en)
   * @returns {Promise<Object>} - Promise resolving to search results
   */
  async search(query, language = "en") {
    try {
      const url = `${this.backendUrl}/api/search?q=${encodeURIComponent(
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
      const url = `${this.backendUrl}/api/login`;
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
      const url = `${this.backendUrl}/api/register`;
      const formData = new URLSearchParams();

      for (const [key, value] of Object.entries(userData)) {
        formData.append(key, value);
      }

      const response = await fetch(url, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: formData,
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
