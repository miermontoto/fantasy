import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    this.debounceTimer = null
  }

  togglePosition(event) {
    event.preventDefault()
    const button = event.currentTarget
    const position = button.dataset.position
    const form = this.formTarget
    const positionInput = form.querySelector('input[name="position"]')
    const excludeInput = form.querySelector('input[name="exclude_position"]')

    if (event.shiftKey) {
      let excluded = excludeInput.value ? excludeInput.value.split(',') : []
      const index = excluded.indexOf(position)

      // Reset all buttons to default state first
      form.querySelectorAll('[data-position]').forEach(btn => {
        const pos = btn.dataset.position
        btn.classList.remove('bg-yellow-500', 'bg-blue-500', 'bg-green-500', 'bg-red-500')
        btn.classList.remove('border-yellow-500', 'border-blue-500', 'border-green-500', 'border-red-500')
        btn.classList.remove('opacity-40')
        btn.classList.add('bg-gray-700', 'border-gray-600', 'text-white')
        btn.querySelector('span').classList.remove('text-black')
        btn.querySelector('span').classList.add('text-white')
        const line = btn.querySelector('.absolute')
        if (line) line.remove()
      })

      if (index === -1) {
        excluded.push(position)
        // Add excluded style
        button.classList.add('opacity-40')
        const line = document.createElement('div')
        line.className = 'absolute inset-0 flex items-center justify-center'
        line.innerHTML = '<div class="w-full h-0.5 bg-gray-300 rotate-45"></div>'
        button.appendChild(line)
      } else {
        excluded.splice(index, 1)
      }

      excludeInput.value = excluded.join(',')
      positionInput.value = ''
    } else {
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
      excludeInput.value = ''
    }

    this.resetPageAndSubmit()
  }

  toggleSource(event) {
    event.preventDefault()
    const button = event.currentTarget
    const source = button.dataset.source
    const form = this.formTarget
    const sourceInput = form.querySelector('input[name="source"]')

    // Remove active class from all buttons
    form.querySelectorAll('[data-source]').forEach(btn => {
      btn.classList.remove('bg-blue-500', 'border-blue-500', 'text-black')
      btn.classList.add('bg-gray-700', 'border-gray-600', 'text-white')
    })

    if (sourceInput.value === source) {
      sourceInput.value = 'all'
      // Set "all" button as active
      form.querySelector('[data-source="all"]').classList.remove('bg-gray-700', 'border-gray-600', 'text-white')
      form.querySelector('[data-source="all"]').classList.add('bg-blue-500', 'border-blue-500', 'text-black')
    } else {
      sourceInput.value = source
      // Set clicked button as active
      button.classList.remove('bg-gray-700', 'border-gray-600', 'text-white')
      button.classList.add('bg-blue-500', 'border-blue-500', 'text-black')
    }

    this.resetPageAndSubmit()
  }

  toggleSortDirection(event) {
    event.preventDefault()
    const form = this.formTarget
    const directionInput = form.querySelector('input[name="sort_direction"]')
    const newDirection = directionInput.value === 'asc' ? 'desc' : 'asc'
    directionInput.value = newDirection
    event.currentTarget.querySelector('span').textContent = newDirection === 'asc' ? '↑' : '↓'
    this.resetPageAndSubmit()
  }

  changePage(event) {
    event.preventDefault()
    const page = event.currentTarget.dataset.page
    if (!page) return

    let pageInput = this.formTarget.querySelector('input[name="page"]')
    if (!pageInput) {
      pageInput = document.createElement('input')
      pageInput.type = 'hidden'
      pageInput.name = 'page'
      this.formTarget.appendChild(pageInput)
    }
    pageInput.value = page

    // Submit immediately for pagination
    this.formTarget.requestSubmit()
  }

  updatePriceDisplay(event) {
    const priceValue = document.getElementById('price-value')
    if (priceValue) {
      const formatter = new Intl.NumberFormat('es-ES', {
        style: 'currency',
        currency: 'EUR',
        maximumFractionDigits: 0
      })
      priceValue.textContent = formatter.format(event.currentTarget.value)
    }
  }

  resetPageAndSubmit() {
    let pageInput = this.formTarget.querySelector('input[name="page"]')
    if (!pageInput) {
      pageInput = document.createElement('input')
      pageInput.type = 'hidden'
      pageInput.name = 'page'
      this.formTarget.appendChild(pageInput)
    }
    pageInput.value = '1'

    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 300)
  }

  submitForm() {
    this.resetPageAndSubmit()
  }

  resetStyles() {
    const form = this.formTarget

    // Reset position buttons
    form.querySelectorAll('[data-position]').forEach(btn => {
      btn.classList.remove('bg-yellow-500', 'bg-blue-500', 'bg-green-500', 'bg-red-500')
      btn.classList.remove('border-yellow-500', 'border-blue-500', 'border-green-500', 'border-red-500')
      btn.classList.remove('opacity-40')
      btn.classList.add('bg-gray-700', 'border-gray-600', 'text-white')
      btn.querySelector('span').classList.remove('text-black')
      btn.querySelector('span').classList.add('text-white')
      const line = btn.querySelector('.absolute')
      if (line) line.remove()
    })

    // Reset source buttons
    form.querySelectorAll('[data-source]').forEach(btn => {
      btn.classList.remove('bg-blue-500', 'border-blue-500', 'text-black')
      btn.classList.add('bg-gray-700', 'border-gray-600', 'text-white')
    })
  }
}
