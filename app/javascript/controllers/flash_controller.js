import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.style.opacity = '0'
    requestAnimationFrame(() => {
      this.element.style.opacity = '1'
    })

    this.timeout = setTimeout(() => {
      this.remove()
    }, 5000)
  }

  disconnect() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
  }

  remove() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }

    this.element.style.opacity = '0'
    
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}
