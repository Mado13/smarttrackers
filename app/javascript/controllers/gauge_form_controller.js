import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["startDate", "endDate", "timeUnit"]

  connect() {
    this.updateEndDate()
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

  updateEndDate() {
    const startDateValue = this.startDateTarget.value
    const timeUnitValue = this.timeUnitTarget.value
    if (!startDateValue || !timeUnitValue) return

    const startDate = new Date(startDateValue)
    let minEndDate = new Date(startDate)
    
    switch (timeUnitValue) {
      case "day":
        minEndDate.setDate(startDate.getDate() + 1)
        break
      case "week":
        minEndDate.setDate(startDate.getDate() + 7)
        break
      case "month":
        minEndDate.setMonth(startDate.getMonth() + 1)
        break
      case "year":
        minEndDate.setFullYear(startDate.getFullYear() + 1)
        break
    }

    const formattedMinEndDate = minEndDate.toISOString().split("T")[0]
    this.endDateTarget.min = formattedMinEndDate
    
    if (!this.endDateTarget.value || this.endDateTarget.value < formattedMinEndDate) {
      this.endDateTarget.value = formattedMinEndDate
    }
  }
}
