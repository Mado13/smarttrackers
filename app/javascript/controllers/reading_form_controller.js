import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleSubmit = this.handleSubmit.bind(this)
    this.element.addEventListener("turbo:submit-end", this.handleSubmit)
  }

  disconnect() {
    this.element.removeEventListener("turbo:submit-end", this.handleSubmit)
  }

  handleSubmit(event) {
    const response = event.detail.fetchResponse
    if (response.statusCode === 200 && 
        response.response.headers.get("content-type").includes("text/vnd.turbo-stream.html")) {
      // Find the base modal controller and close it
      const baseModal = this.element.closest('[data-controller="base-modal"]')
      if (baseModal) {
        const controller = this.application.getControllerForElementAndIdentifier(baseModal, 'base-modal')
        controller.close()
      }
    }
  }
}
