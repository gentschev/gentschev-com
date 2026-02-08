import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tooltip", "point"]

  connect() {
    this.boundMouseMove = this.handleMouseMove.bind(this)
  }

  pointTargetConnected(point) {
    point.addEventListener("mouseenter", this.showTooltip.bind(this))
    point.addEventListener("mouseleave", this.hideTooltip.bind(this))
    point.addEventListener("touchstart", this.handleTouch.bind(this), { passive: true })
  }

  pointTargetDisconnected(point) {
    point.removeEventListener("mouseenter", this.showTooltip.bind(this))
    point.removeEventListener("mouseleave", this.hideTooltip.bind(this))
    point.removeEventListener("touchstart", this.handleTouch.bind(this))
  }

  showTooltip(event) {
    const point = event.currentTarget
    const date = point.dataset.date
    const count = point.dataset.count
    const label = count === "1" ? "contribution" : "contributions"

    this.tooltipTarget.textContent = `${date}: ${count} ${label}`
    this.tooltipTarget.classList.remove("hidden")

    this.positionTooltip(event)

    // Track mouse movement while hovering
    document.addEventListener("mousemove", this.boundMouseMove)
  }

  hideTooltip() {
    this.tooltipTarget.classList.add("hidden")
    document.removeEventListener("mousemove", this.boundMouseMove)
  }

  handleMouseMove(event) {
    this.positionTooltip(event)
  }

  positionTooltip(event) {
    const container = this.element
    const tooltip = this.tooltipTarget
    const containerRect = container.getBoundingClientRect()

    // Position relative to container
    let x = event.clientX - containerRect.left + 10
    let y = event.clientY - containerRect.top - 30

    // Ensure tooltip stays within container bounds
    const tooltipWidth = tooltip.offsetWidth
    if (x + tooltipWidth > containerRect.width) {
      x = event.clientX - containerRect.left - tooltipWidth - 10
    }

    if (y < 0) {
      y = event.clientY - containerRect.top + 20
    }

    tooltip.style.left = `${x}px`
    tooltip.style.top = `${y}px`
  }

  handleTouch(event) {
    const point = event.currentTarget
    const date = point.dataset.date
    const count = point.dataset.count
    const label = count === "1" ? "contribution" : "contributions"

    this.tooltipTarget.textContent = `${date}: ${count} ${label}`
    this.tooltipTarget.classList.remove("hidden")

    // Position near the touched point
    const touch = event.touches[0]
    const containerRect = this.element.getBoundingClientRect()
    const x = touch.clientX - containerRect.left
    const y = touch.clientY - containerRect.top - 40

    this.tooltipTarget.style.left = `${x}px`
    this.tooltipTarget.style.top = `${y}px`

    // Hide after a delay
    setTimeout(() => this.hideTooltip(), 2000)
  }
}
