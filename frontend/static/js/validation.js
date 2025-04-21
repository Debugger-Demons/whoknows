const sanitize = (text) => {
  const div = document.createElement("div");
  div.innerHTML = text;
  return div.textContent || div.innerText || "";
};

const sanitizedInput = DOMPurify.sanitize(input);
