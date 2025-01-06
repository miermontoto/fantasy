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
    fontSize: {
      '4xs': '.4rem',
      '3xs': '.5rem',
      '2xs': '.65rem',
      'xs': '.75rem',
      'sm': '.875rem',
      'base': '1rem',
      'lg': '1.125rem',
      'xl': '1.25rem',
      '2xl': '1.5rem',
      '3xl': '1.875rem',
      '4xl': '2.25rem',
      '5xl': '3rem',
      '6xl': '4rem',
      '7xl': '5rem',
    }
  },
  plugins: [
  ]
}
