module ApplicationHelper
  # Inline onerror for gallery images: retries 3 times (1s, 2s, 3s apart), then shows a calm
  # placeholder instead of the browser's broken-image icon. Inline so it works even if the
  # image fails before our JavaScript bundle has loaded.
  IMAGE_RETRY_ONERROR = <<~JS.squish.freeze
    var n = +(this.dataset.retries || 0);
    if (n < 3) {
      this.dataset.retries = n + 1;
      var img = this;
      setTimeout(function() { img.src = img.src.split('?')[0] + '?retry=' + (n + 1); }, 1000 * (n + 1));
    } else {
      this.style.display = 'none';
      this.parentElement.classList.remove('img-skeleton');
      this.parentElement.classList.add('img-failed');
    }
  JS

  # Inline onclick for the ↻ button shown on a failed gallery image: starts loading it again.
  IMAGE_RETRY_ONCLICK = <<~JS.squish.freeze
    var card = this.parentElement, img = card.querySelector('img');
    card.classList.remove('img-failed');
    card.classList.add('img-skeleton');
    img.dataset.retries = 0;
    img.style.display = 'block';
    img.src = img.src.split('?')[0] + '?retry=' + Date.now();
  JS

  def render_stat(label, value, detail: nil)
    content_tag(:div, style: "background: white; border-radius: 1rem; padding: 1.1rem 1.25rem; border: 1px solid #e2ddd8;") do
      html = content_tag(:p, label, class: "font-sans", style: "font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: #aaa; margin-bottom: 0.35rem;")
      html += content_tag(:p, value.to_s, class: "font-sans", style: "font-size: 1.6rem; font-weight: 700; color: #1a1a1a; line-height: 1;")
      html += content_tag(:p, detail, class: "font-sans", style: "font-size: 0.75rem; color: #bbb; margin-top: 0.25rem;") if detail
      html
    end
  end
end
