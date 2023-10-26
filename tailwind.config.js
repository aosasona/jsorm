/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{gleam,js,html}", "./priv/static/sources/js/**/*.js"],
  theme: {
    extend: {
      fontFamily: ["JetBrains Mono", "monospace"],
    },
  },
  plugins: [],
};
