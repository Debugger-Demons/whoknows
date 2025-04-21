const sanitize = (text) => {
  const div = document.createElement("div");
  div.innerHTML = text;
  return div.textContent || div.innerText || "";
};

// Define a utility function to sanitize inputs using DOMPurify
const sanitizeInput = (input) => {
  return DOMPurify.sanitize(input);
};
