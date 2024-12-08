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

      if (index === -1) {
        excluded.push(position)
      } else {
        excluded.splice(index, 1)
      }

      excludeInput.value = excluded.join(',')
      positionInput.value = ''
    } else {
      positionInput.value = positionInput.value === position ? '' : position
      excludeInput.value = ''
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
}
