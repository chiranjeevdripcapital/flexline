/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/views/**/*.{erb,html}",
  ],
  theme: {
    extend: {
      colors: {
        flexline: {
          navy: "#002147",
          green: "#2BB673",
          "green-hover": "#24a062",
          sidebar: "#eef1f5",
          "table-head": "#e3eef6",
          border: "#d4dee8",
          muted: "#5a6573",
          ink: "#1a2b3c",
          pending: "#fff4e5",
          "pending-text": "#9a3412",
        },
      },
      fontFamily: {
        sans: ["Montserrat", "system-ui", "sans-serif"],
      },
      boxShadow: {
        card: "0 1px 2px rgba(0, 33, 71, 0.06)",
      },
    },
  },
  plugins: [],
}
