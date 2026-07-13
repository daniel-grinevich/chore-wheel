import { Controller } from "@hotwired/stimulus"

// Live-updating elapsed clock for a running work session. Renders mm:ss (or
// h:mm:ss) counting up from the session's started_at, ticking every second.
export default class extends Controller {
  static targets = ["display"]
  static values = { startedAt: String }

  connect() {
    this.tick()
    this.interval = setInterval(() => this.tick(), 1000)
  }

  disconnect() {
    clearInterval(this.interval)
  }

  tick() {
    if (!this.hasDisplayTarget) return

    const start = new Date(this.startedAtValue).getTime()
    const elapsed = Math.max(0, Math.floor((Date.now() - start) / 1000))
    const h = Math.floor(elapsed / 3600)
    const m = Math.floor((elapsed % 3600) / 60)
    const s = elapsed % 60
    const pad = (n) => String(n).padStart(2, "0")

    this.displayTarget.textContent =
      h > 0 ? `${h}:${pad(m)}:${pad(s)}` : `${pad(m)}:${pad(s)}`
  }
}
