document.addEventListener('DOMContentLoaded', () => {
  const loginForm = document.getElementById('login-form');
  const errorMessage = document.getElementById('error-message');
  const errorContent = document.getElementById('error-content');
  
  loginForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const username = loginForm.username.value.trim();
    const password = loginForm.password.value;
    
    // Simple validation
    if (!username || !password) {
      showError('Please enter both username and password.');
      return;
    }
    
    try {
      // In a real application, you would use the API client:
      
      const response = await api.login(username, password);
      
      if (response.success) {
        // Redirect to search page
        window.location.href = '/search.html';
      } else {
        showError(response.error || 'Login failed. Please check your credentials.');
      }
      
    } catch (error) {
      console.error('Login error:', error);
      showError('An error occurred during login. Please try again.');
    }
  });
  
  function showError(message) {
    errorContent.textContent = message;
    errorMessage.style.display = 'block';
  }
});
