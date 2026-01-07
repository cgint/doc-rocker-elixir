defmodule DocRockerWeb.MarkdownDemoLive do
  use DocRockerWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, sample_markdown: sample_markdown())}
  end

  defp sample_markdown do
    ~S"""
# Markdown Display Component

This is a demo of the markdown display component.

## Features
- Syntax highlighting for code blocks
- Copy buttons for code blocks
- Copy as Markdown or Rich Text buttons

### Code Example

```javascript
// This is a JavaScript code block
function helloWorld() {
  console.log('Hello, world!');
  return 42;
}
```

```python
# This is a Python code block
def hello_world():
    print("Hello, world!")
    return 42
```

```bash
# Bash script
echo "Hello World"
ls -la
```

### Tables

| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Row 1    | Data     | Data     |
| Row 2    | Data     | Data     |

### Links

[Visit GitHub](https://github.com)

### Images

![Placeholder](https://doc-rocker.com/logo.webp)

### Blockquotes

> This is a blockquote.
> It can span multiple lines.

### Lists

1. First item
2. Second item
3. Third item

- Unordered list
- Another item
- And another one
"""
  end
end
