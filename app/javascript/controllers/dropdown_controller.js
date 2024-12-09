import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    // Close dropdown when clicking outside
    this.clickHandler = this.handleClickOutside.bind(this)
    document.addEventListener("click", this.clickHandler)
  }

  disconnect() {
    document.removeEventListener("click", this.clickHandler)
  }

  toggle(event) {
    event.stopPropagation()
    this.menuTarget.classList.toggle("hidden")
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target) && !this.menuTarget.classList.contains("hidden")) {
      this.menuTarget.classList.add("hidden")
    }
  }
}
