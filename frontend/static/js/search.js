document.addEventListener("DOMContentLoaded", () => {
  const searchInput = document.getElementById("search-input");
  const searchButton = document.getElementById("search-button");
  const resultsContainer = document.getElementById("results");

  // Focus the input field
  searchInput.focus();

  // Check for query parameter and populate input if present
  const urlParams = new URLSearchParams(window.location.search);
  const queryParam = urlParams.get("q");

  if (queryParam) {
    searchInput.value = queryParam;
    performSearch(queryParam);
  }

  // Search when the user presses Enter
  searchInput.addEventListener("keypress", (event) => {
    if (event.key === "Enter") {
      makeSearchRequest();
    }
  });

  // Search when the button is clicked
  searchButton.addEventListener("click", makeSearchRequest);

  function makeSearchRequest() {
    const query = searchInput.value.trim();

    if (query) {
      // Update the URL with the search query
      const url = new URL(window.location.href);
      url.searchParams.set("q", query);
      window.history.pushState({}, "", url);

      // Perform the search
      performSearch(query);
    }
  }

  async function performSearch(query) {
    // Show loading indicator
    resultsContainer.innerHTML = "<p>Searching...</p>";

    try {
      // Call the backend API through our API client (./api.js)
      const data = await api.search(query);

      // Display results
      displayResults(data.search_results || []);
    } catch (error) {
      console.error("Error performing search:", error);
      resultsContainer.innerHTML =
        "<p>An error occurred while searching. Please try again.</p>";
    }
  }

  function displayResults(results) {
    if (results.length === 0) {
      resultsContainer.innerHTML = "<p>No results found.</p>";
      return;
    }

    const resultsHtml = results
      .map(
        (result) => `
      <div class="search-result">
        <h2><a class="search-result-title" href="${result.url}">${result.title}</a></h2>
        <div class="search-result-url">${result.url}</div>
        <p class="search-result-description">${result.description}</p>
      </div>
    `
      )
      .join("");

    resultsContainer.innerHTML = resultsHtml;
  }
});
