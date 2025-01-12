import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "form",
    "userForm",
    "usersContent",
    "usersIcon",
    "filtersContent",
    "filtersIcon",
    "sortContent",
    "sortIcon",
    "searchContent",
    "searchIcon",
    "searchInput",
    "searchClear",
    "searchResults",
    "searchNoResults",
    "searchLoading"
  ]

  connect() {
    super.connect()
    this.usersExpanded = false
    this.filtersExpanded = false
    this.sortExpanded = false
    this.searchExpanded = false
  }

  handleUserChange(event) {
    const userId = event.target.value
    const url = new URL(window.location)

    if (userId) {
      url.searchParams.set('user_id', userId)
    } else {
      url.searchParams.delete('user_id')
    }

    // Perform a full page reload with the new URL
    window.location.href = url.toString()
  }

  toggleUsers() {
    this.usersExpanded = !this.usersExpanded
    this.usersContentTarget.classList.toggle("hidden", !this.usersExpanded)
    this.usersIconTarget.classList.toggle("rotate-180", this.usersExpanded)
  }

  toggleFilters() {
    this.filtersExpanded = !this.filtersExpanded
    localStorage.setItem("teamFiltersExpanded", this.filtersExpanded)
    this.updateFiltersVisibility()
  }

  updateFiltersVisibility() {
    this.filtersContentTarget.classList.toggle("hidden", !this.filtersExpanded)
    this.filtersIconTarget.innerHTML = this.chevronIcon(this.filtersExpanded)
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

  submitUserForm() {
    this.userFormTarget.requestSubmit()
  }

  togglePosition(event) {
    event.preventDefault()
    const button = event.currentTarget
    const position = button.dataset.position
    const currentPosition = this.formTarget.position.value

    this.formTarget.position.value = currentPosition === position ? "" : position
    this.updateButtonStyles()
    this.submitForm()
  }

  toggleSortDirection(event) {
    event.preventDefault()
    const currentDirection = this.formTarget.sort_direction.value
    this.formTarget.sort_direction.value = currentDirection === "asc" ? "desc" : "asc"
    this.submitForm()
  }

  updateButtonStyles() {
    const currentPosition = this.formTarget.position.value
    const positionColors = {
      'PT': ['bg-yellow-500', 'border-yellow-500', 'text-black'],
      'DF': ['bg-blue-500', 'border-blue-500', 'text-black'],
      'MC': ['bg-green-500', 'border-green-500', 'text-black'],
      'DL': ['bg-red-500', 'border-red-500', 'text-black']
    }

    this.formTarget.querySelectorAll('[data-position]').forEach(btn => {
      const pos = btn.dataset.position
      const span = btn.querySelector('span')

      // Remove all possible styles
      btn.classList.remove(
        'bg-yellow-500', 'bg-blue-500', 'bg-green-500', 'bg-red-500',
        'border-yellow-500', 'border-blue-500', 'border-green-500', 'border-red-500',
        'bg-gray-700', 'border-gray-600'
      )
      span.classList.remove('text-black', 'text-white')

      // Add appropriate styles
      if (pos === currentPosition) {
        btn.classList.add(...positionColors[pos])
        span.classList.add('text-black')
      } else {
        btn.classList.add('bg-gray-700', 'border-gray-600')
        span.classList.add('text-white')
      }
    })
  }
}
