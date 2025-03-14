import { Controller } from "@hotwired/stimulus"
import { Tooltip } from 'bootstrap'

// Connects to data-controller="tooltip"
export default class extends Controller {
  connect() {
    // console.log("Tooltip work");
    this.tooltip = new Tooltip(this.element, {
      // container: 'body',
      // trigger : 'hover click'
  });
  }
}
