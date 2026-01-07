defmodule DocRockerWeb.MarkdownDisplay do
  use Phoenix.Component

  def markdown_display(assigns) do
    assigns =
      assign_new(assigns, :id, fn ->
        "markdown-" <> Integer.to_string(:erlang.unique_integer([:positive]))
      end)

    ~H"""
    <div
      id={@id}
      class="markdown-container"
      phx-hook="MarkdownRenderer"
      data-show-copy-buttons={@show_copy_buttons}
    >
      <div class="markdown-content-wrapper">
        <%= if @show_copy_buttons do %>
          <div class="action-buttons">
            <button
              class="action-button"
              type="button"
              data-action="copy-markdown"
              title="Copy Markdown"
              aria-label="Copy Markdown"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                <polyline points="14 2 14 8 20 8"></polyline>
              </svg>
            </button>
            <button
              class="action-button"
              type="button"
              data-action="copy-rich-text"
              title="Copy Rich Text"
              aria-label="Copy Rich Text"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                width="16"
                height="16"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                stroke-width="2"
                stroke-linecap="round"
                stroke-linejoin="round"
              >
                <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                <polyline points="16 17 21 12 16 7"></polyline>
                <line x1="21" y1="12" x2="9" y2="12"></line>
              </svg>
            </button>
          </div>
        <% end %>

        <div class="markdown-content">{@markdown}</div>
      </div>
    </div>
    """
  end
end
