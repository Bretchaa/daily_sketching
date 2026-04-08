import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["count"]
  static values = { submissionId: Number, cheered: Boolean }

  toggle(event) {
    event.preventDefault()

    fetch("/cheers", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "application/json"
      },
      body: JSON.stringify({ submission_id: this.submissionIdValue })
    })
    .then(r => r.json())
    .then(data => {
      this.cheeredValue = data.cheered
      this.element.style.background = data.cheered ? "rgba(255,255,255,0.35)" : "rgba(255,255,255,0.15)"
      this.countTarget.textContent = data.total > 0 ? data.total : ""
      this.countTarget.style.color = data.cheered ? "white" : "rgba(255,255,255,0.7)"
    })
  }
}
