document.addEventListener('DOMContentLoaded', () => {
  const registerForm = document.getElementById('register-form');
  const errorMessage = document.getElementById('error-message');
  const errorContent = document.getElementById('error-content');
  
  registerForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    const username = registerForm.username.value.trim();
    const email = registerForm.email.value.trim();
    const password = registerForm.password.value;
    const password2 = registerForm.password2.value;
    
    // Simple validation
    if (!username) {
      showError('You have to enter a username');
      return;
    }
    
    if (!email || !email.includes('@')) {
      showError('You have to enter a valid email address');
      return;
    }
    
    if (!password) {
      showError('You have to enter a password');
      return;
    }
    
    if (password !== password2) {
      showError('The two passwords do not match');
      return;
    }
    
    try {
      // In a static demo, we'll just show a message
      showError('This is a static demo. Registration is not functional.');
      
      // In a real application, you would use the API client:
      /*
      const response = await api.register({
        username,
        email,
        password,
        password2
      });
      
      if (response.success) {
        // Redirect to login page
        window.location.href = '/login.html';
      } else {
        showError(response.error || 'Registration failed. Please try again.');
      }
      */
    } catch (error) {
      console.error('Registration error:', error);
      showError('An error occurred during registration. Please try again.');
    }
  });
  
  function showError(message) {
    errorContent.textContent = message;
    errorMessage.style.display = 'block';
  }
});
