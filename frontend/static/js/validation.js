const sanitize = (text) => {
  const div = document.createElement("div");
  div.innerHTML = text;
  return div.textContent || div.innerText || "";
};

// Define a utility function to sanitize inputs using DOMPurify
const sanitizeInput = (input) => {
  if (typeof DOMPurify === "undefined") {
    console.error("DOMPurify is not defined");
    return sanitize(input);
  }
  return DOMPurify.sanitize(input);
};

// Export the sanitizeInput function
export { sanitizeInput };
