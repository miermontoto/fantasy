import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["form"]

  connect() {
    // Form is in the template
  }

  changePage(event) {
    event.preventDefault()
    const page = event.currentTarget.dataset.page
    if (!page) return

    // Add or update the page parameter
    let pageInput = this.formTarget.querySelector('input[name="page_feed"]')
    if (!pageInput) {
      pageInput = document.createElement('input')
      pageInput.type = 'hidden'
      pageInput.name = 'page_feed'
      this.formTarget.appendChild(pageInput)
    }
    pageInput.value = page

    // Submit the form
    this.formTarget.requestSubmit()

    // Update URL without reload
    const url = new URL(window.location)
    url.searchParams.set('page_feed', page)
    window.history.pushState({}, '', url)
  }
}
