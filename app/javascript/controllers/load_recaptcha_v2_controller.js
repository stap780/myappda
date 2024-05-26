import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="load-recaptcha-v2"
export default class extends Controller {
  static values = { siteKey: String }
  
  initialize() {
    grecaptcha.render("recaptchaV2", { sitekey: this.siteKeyValue } )
  }
  
  connect() {
  }
}
