// Loaded only on the desktop /done page (QR code step). Keeps a live connection open and
// reloads the page as soon as the drawing is uploaded from the phone. While connected, the
// page's 15s backup check stands down (it reads data-connected).
import { createConsumer } from "@rails/actioncable"

const el = document.getElementById("live-upload")

if (el) {
  const goToDone = () => { window.location.href = el.dataset.doneUrl }

  createConsumer().subscriptions.create(
    { channel: "Turbo::StreamsChannel", signed_stream_name: el.dataset.stream },
    {
      connected() {
        el.dataset.connected = "true"
        // Catch an upload that landed before we (re)connected
        fetch("/upload_status")
          .then((r) => r.json())
          .then((data) => { if (data.uploaded) goToDone() })
      },
      disconnected() { delete el.dataset.connected },
      received: goToDone
    }
  )
}
