import { Controller } from "@hotwired/stimulus"
import { Offcanvas } from "bootstrap"

// Connects to data-controller="offcanvas"
export default class extends Controller {

  connect() {
    console.log('offcanvas load')
    this.offcanvas = new Offcanvas(this.element)
    
    // if (!this.offcanvas.isOpened) {
    //   this.offcanvas.show()
    // }

  }

  show() {
    if (!this.offcanvas.isOpened) {
      this.offcanvas.show()
    }
  }

  hide(event) {
    if (event.detail.success) {
      this.offcanvas.hide()
    }
  }

}

