import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="debounce"
export default class extends Controller {
  static targets = ["form"]
  connect() {
    console.log('data-controller="debounce"')
  }
  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout( () => {
      this.formTarget.requestSubmit()
    }, 500)
  }

  clear() {
    console.log('this.formTarget', this.formTarget)
    this.formTarget.reset();
    this.formTarget.requestSubmit();
  }
}
