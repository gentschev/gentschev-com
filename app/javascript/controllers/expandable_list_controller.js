import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "button", "buttonText"]
  static values = { limit: Number, expanded: { type: Boolean, default: false } }

  toggle() {
    this.expandedValue = !this.expandedValue
    this.updateVisibility()
  }

  updateVisibility() {
    this.itemTargets.forEach((item, index) => {
      if (index >= this.limitValue) {
        item.classList.toggle("hidden", !this.expandedValue)
      }
    })

    if (this.hasButtonTextTarget) {
      const hiddenCount = this.itemTargets.length - this.limitValue
      this.buttonTextTarget.textContent = this.expandedValue
        ? "Show less"
        : `Show more (${hiddenCount})`
    }
  }
}
