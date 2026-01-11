/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.js",
    "./app/components/**/*.{rb,html.erb}",
  ],
  theme: {
    extend: {},
  },
  daisyui: {
    themes: ["light"], // 👈 this is the correct place
  },
};
