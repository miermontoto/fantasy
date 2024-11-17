

module.exports = {
  purge: {
    safelist: [
      { pattern: /bg-+/ },
      { pattern: /text-+/ },
      { pattern: /mx-+/ },
      { pattern: /text-+/ },
      { pattern: /h-+/ },
      { pattern: /w-+/ },
    ],
  },
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,html.erb,slim}'
  ],
  theme: {
    extend: {
    },
  },
  plugins: [
  ]
}
