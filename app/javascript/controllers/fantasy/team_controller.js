import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.submitForm = this.submitForm.bind(this)
    this.submitFormWithDelay = this.debounce(this.submitForm, 300)
  }

  togglePosition(event) {
    event.preventDefault()
    const button = event.currentTarget
    const position = button.dataset.position
    const form = this.formTarget
    const positionInput = form.querySelector('input[name="position"]')

    // Reset all buttons to default state first
    form.querySelectorAll('[data-position]').forEach(btn => {
      const pos = btn.dataset.position
      btn.classList.remove('bg-yellow-500', 'bg-blue-500', 'bg-green-500', 'bg-red-500')
      btn.classList.remove('border-yellow-500', 'border-blue-500', 'border-green-500', 'border-red-500')
      btn.classList.add('bg-gray-700', 'border-gray-600')
      btn.querySelector('span').classList.remove('text-black')
      btn.querySelector('span').classList.add('text-white')
    })

    if (positionInput.value === position) {
      positionInput.value = ''
    } else {
      positionInput.value = position
      // Add active style based on position
      const colors = {
        'PT': ['bg-yellow-500', 'border-yellow-500'],
        'DF': ['bg-blue-500', 'border-blue-500'],
        'MC': ['bg-green-500', 'border-green-500'],
        'DL': ['bg-red-500', 'border-red-500']
      }
      button.classList.remove('bg-gray-700', 'border-gray-600')
      button.classList.add(...colors[position])
      button.querySelector('span').classList.remove('text-white')
      button.querySelector('span').classList.add('text-black')
    }

    this.submitForm()
  }

  toggleSortDirection(event) {
    const directionInput = this.formTarget.querySelector('input[name="sort_direction"]')
    directionInput.value = directionInput.value === "asc" ? "desc" : "asc"
    this.submitForm()
  }

  submitForm() {
    this.formTarget.requestSubmit()
  }

  resetStyles() {
    this.formTarget.reset()
    // Reset position button styles
    this.formTarget.querySelectorAll('[data-position]').forEach(btn => {
      btn.classList.remove('bg-yellow-500', 'bg-blue-500', 'bg-green-500', 'bg-red-500')
      btn.classList.remove('border-yellow-500', 'border-blue-500', 'border-green-500', 'border-red-500')
      btn.classList.add('bg-gray-700', 'border-gray-600')
      btn.querySelector('span').classList.remove('text-black')
      btn.querySelector('span').classList.add('text-white')
    })
    this.submitForm()
  }

  debounce(func, wait) {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  }
}
