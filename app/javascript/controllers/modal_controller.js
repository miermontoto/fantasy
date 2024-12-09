import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "input"]
  static values = {
    communityId: String
  }

  connect() {
    // Modal starts hidden by default
    this.modalTarget.classList.add("hidden")
    // Bind the click handler
    this.clickHandler = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.clickHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.clickHandler)
  }

  show(event) {
    event?.preventDefault()
    // Clear input when showing modal
    this.inputTarget.value = ""
    this.modalTarget.classList.remove("hidden")
    this.inputTarget.focus()
  }

  hide(event) {
    event?.preventDefault()
    this.modalTarget.classList.add("hidden")
    // Clear input when hiding modal
    this.inputTarget.value = ""
  }

  handleSubmit(event) {
    event.preventDefault()
    const token = this.inputTarget.value.trim()

    if (!token || !this.communityIdValue) return

    // Send token to backend
    fetch(`/api/set_xauth/${this.communityIdValue}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ token: token })
    }).then(response => {
      if (response.ok) {
        this.inputTarget.value = "" // Clear input on success
        window.location.reload()
      } else {
        throw new Error('Failed to save token')
      }
    }).catch(error => {
      console.error('Error:', error)
      // Optionally show an error message to the user
    })
  }

  handleClickOutside(event) {
    // If the click is outside the modal and the modal is visible
    if (!this.modalTarget.contains(event.target) &&
        !event.target.closest('[data-action="click->modal#show"]') &&
        !this.modalTarget.classList.contains("hidden")) {
      this.hide()
    }
  }
}
