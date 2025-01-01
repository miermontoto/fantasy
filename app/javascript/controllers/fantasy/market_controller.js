import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form", "filtersContent", "filtersIcon", "offersContent", "offersIcon"]

  connect() {
    this.filtersExpanded = localStorage.getItem("filtersExpanded") !== "false"
    this.offersExpanded = localStorage.getItem("offersExpanded") !== "false"
    this.updateFiltersVisibility()
    this.updateOffersVisibility()
  }

  toggleFilters() {
    this.filtersExpanded = !this.filtersExpanded
    localStorage.setItem("filtersExpanded", this.filtersExpanded)
    this.updateFiltersVisibility()
  }

  toggleOffers() {
    this.offersExpanded = !this.offersExpanded
    localStorage.setItem("offersExpanded", this.offersExpanded)
    this.updateOffersVisibility()
  }

  updateFiltersVisibility() {
    this.filtersContentTarget.classList.toggle("hidden", !this.filtersExpanded)
    this.filtersIconTarget.innerHTML = this.chevronIcon(this.filtersExpanded)
  }

  updateOffersVisibility() {
    if (this.hasOffersContentTarget) {
      this.offersContentTarget.classList.toggle("hidden", !this.offersExpanded)
      this.offersIconTarget.innerHTML = this.chevronIcon(this.offersExpanded)
    }
  }

  chevronIcon(expanded) {
    return expanded ? `
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M14.707 12.707a1 1 0 01-1.414 0L10 9.414l-3.293 3.293a1 1 0 01-1.414-1.414l4-4a1 1 0 011.414 0l4 4a1 1 0 010 1.414z" clip-rule="evenodd" />
      </svg>
    ` : `
      <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z" clip-rule="evenodd" />
      </svg>
    `
  }

  resetStyles() {
    this.formTarget.reset()
    this.updateButtonStyles()
    this.submitForm()
  }

  submitForm() {
    this.formTarget.requestSubmit()
  }

  togglePosition(event) {
    event.preventDefault()
    const button = event.currentTarget
    const position = button.dataset.position
    const currentPosition = this.formTarget.position.value
    const excludedPositions = this.formTarget.exclude_position.value.split(",").filter(Boolean)

    if (currentPosition === position) {
      // If already selected, remove selection and add to excluded
      this.formTarget.position.value = ""
      if (!excludedPositions.includes(position)) {
        excludedPositions.push(position)
      }
    } else if (excludedPositions.includes(position)) {
      // If excluded, remove from excluded
      const index = excludedPositions.indexOf(position)
      excludedPositions.splice(index, 1)
    } else {
      // If neither selected nor excluded, select it
      this.formTarget.position.value = position
      const index = excludedPositions.indexOf(position)
      if (index > -1) {
        excludedPositions.splice(index, 1)
      }
    }

    this.formTarget.exclude_position.value = excludedPositions.join(",")
    this.updateButtonStyles()
    this.submitForm()
  }

  toggleSource(event) {
    event.preventDefault()
    const button = event.currentTarget
    const source = button.dataset.source
    this.formTarget.source.value = source
    this.updateSourceButtonStyles()
    this.submitForm()
  }

  toggleSortDirection(event) {
    event.preventDefault()
    const currentDirection = this.formTarget.sort_direction.value
    this.formTarget.sort_direction.value = currentDirection === "asc" ? "desc" : "asc"
    this.submitForm()
  }

  updatePriceDisplay(event) {
    const value = event.target.value
    const formattedValue = new Intl.NumberFormat("es-ES", {
      style: "currency",
      currency: "EUR",
      maximumFractionDigits: 0
    }).format(value)
    document.getElementById("price-value").textContent = formattedValue
  }

  updateButtonStyles() {
    const currentPosition = this.formTarget.position.value
    const excludedPositions = this.formTarget.exclude_position.value.split(",").filter(Boolean)
    const positionColors = {
      'PT': ['bg-yellow-500', 'border-yellow-500', 'text-black'],
      'DF': ['bg-blue-500', 'border-blue-500', 'text-black'],
      'MC': ['bg-green-500', 'border-green-500', 'text-black'],
      'DL': ['bg-red-500', 'border-red-500', 'text-black']
    }

    this.formTarget.querySelectorAll('[data-position]').forEach(btn => {
      const pos = btn.dataset.position
      const span = btn.querySelector('span')
      const line = btn.querySelector('.absolute')

      // Remove all possible styles
      btn.classList.remove(
        'bg-yellow-500', 'bg-blue-500', 'bg-green-500', 'bg-red-500',
        'border-yellow-500', 'border-blue-500', 'border-green-500', 'border-red-500',
        'bg-gray-700', 'border-gray-600', 'opacity-40'
      )
      span.classList.remove('text-black', 'text-white')
      if (line) line.remove()

      // Add appropriate styles
      if (pos === currentPosition) {
        btn.classList.add(...positionColors[pos])
        span.classList.add('text-black')
      } else if (excludedPositions.includes(pos)) {
        btn.classList.add('bg-gray-700', 'border-gray-600', 'opacity-40')
        span.classList.add('text-white')
        const lineDiv = document.createElement('div')
        lineDiv.className = 'absolute inset-0 flex items-center justify-center skew-x-[10deg]'
        lineDiv.innerHTML = '<div class="w-full h-0.5 bg-gray-300 rotate-45"></div>'
        btn.appendChild(lineDiv)
      } else {
        btn.classList.add('bg-gray-700', 'border-gray-600')
        span.classList.add('text-white')
      }
    })
  }

  updateSourceButtonStyles() {
    const currentSource = this.formTarget.source.value
    this.formTarget.querySelectorAll('[data-source]').forEach(btn => {
      const source = btn.dataset.source
      const span = btn.querySelector('span')

      btn.classList.remove('bg-blue-500', 'border-blue-500', 'bg-gray-700', 'border-gray-600')
      span.classList.remove('text-black', 'text-white')

      if (source === currentSource || (source === 'all' && !currentSource)) {
        btn.classList.add('bg-blue-500', 'border-blue-500')
        span.classList.add('text-black')
      } else {
        btn.classList.add('bg-gray-700', 'border-gray-600')
        span.classList.add('text-white')
      }
    })
  }
}
