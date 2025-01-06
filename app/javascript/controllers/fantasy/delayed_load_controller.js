import { Controller } from "@hotwired/stimulus"
import { Turbo } from "@hotwired/turbo-rails"

export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    // Wait a short moment after the page loads to trigger the update
    setTimeout(() => {
      this.loadContent()
    }, 100)
  }

  loadContent() {
    fetch(this.urlValue, {
      headers: {
        Accept: "text/vnd.turbo-stream.html",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
      .then(response => response.text())
      .then(html => {
        Turbo.renderStreamMessage(html)
      })
  }
}
