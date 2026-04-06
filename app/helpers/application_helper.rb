module ApplicationHelper
  def render_stat(label, value, detail: nil)
    content_tag(:div, style: "background: white; border-radius: 1rem; padding: 1.1rem 1.25rem; border: 1px solid #e2ddd8;") do
      html = content_tag(:p, label, class: "font-sans", style: "font-size: 0.72rem; font-weight: 700; text-transform: uppercase; letter-spacing: 0.05em; color: #aaa; margin-bottom: 0.35rem;")
      html += content_tag(:p, value.to_s, class: "font-sans", style: "font-size: 1.6rem; font-weight: 700; color: #1a1a1a; line-height: 1;")
      html += content_tag(:p, detail, class: "font-sans", style: "font-size: 0.75rem; color: #bbb; margin-top: 0.25rem;") if detail
      html
    end
  end
end
