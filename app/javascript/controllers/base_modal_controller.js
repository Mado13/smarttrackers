import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]
  
  connect() {
    // Listen for turbo:frame-load on the document
    document.addEventListener("turbo:frame-load", this.handleFrameLoad.bind(this))
  }
  
  disconnect() {
    document.removeEventListener("turbo:frame-load", this.handleFrameLoad.bind(this))
  }
  
  handleFrameLoad(event) {
    // Check if the frame is the modal content frame
    if (event.target.id === "modal_content" && event.target.innerHTML.trim() !== "") {
      this.open()
    }
  }
  
  closeBackground(e) {
    if (e.target === this.element || e.target === this.overlayTarget) {
      this.close()
    }
  }
  
  closeWithKeyboard(e) {
    if (e.code == "Escape") {
      this.close()
    }
  }
  
  open() {
    this.element.classList.remove("hidden")
  }
  
  close() {
    this.element.classList.add("hidden")
  }
}
