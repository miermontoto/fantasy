import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon", "buttonText"]

  connect() {
    this.isExpanded = false
  }

  toggle() {
    this.isExpanded = !this.isExpanded
    this.contentTarget.classList.toggle("hidden")
    this.iconTarget.style.transform = this.isExpanded ? "rotate(180deg)" : ""
    this.buttonTextTarget.textContent = this.isExpanded ? "Ocultar pujas" : "Ver otras pujas"
  }
}
