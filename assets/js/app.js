// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
import {marked} from "marked"
import hljs from "highlight.js"
import "highlight.js/styles/github.css"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
marked.setOptions({
  breaks: true,
  gfm: true,
  highlight: function(code, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return hljs.highlight(code, {language: lang}).value
      } catch (error) {
        console.error("Highlight.js error:", error)
      }
    }
    try {
      return hljs.highlightAuto(code).value
    } catch (error) {
      console.error("Highlight.js error:", error)
      return code
    }
  },
})

function addCodeCopyButtons(markdownElement) {
  const codeBlocks = markdownElement.querySelectorAll("pre code")
  codeBlocks.forEach(codeBlock => {
    const pre = codeBlock.parentNode
    if (!pre) return
    pre.style.position = "relative"

    const existingButton = pre.querySelector(".code-copy-button")
    if (existingButton) {
      existingButton.remove()
    }

    const copyButton = document.createElement("button")
    copyButton.className = "code-copy-button"
    copyButton.title = "Copy code"
    copyButton.innerHTML =
      '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>'

    copyButton.addEventListener("click", () => {
      const code = codeBlock.textContent || ""
      navigator.clipboard.writeText(code).then(() => {
        copyButton.innerHTML =
          '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"></path></svg>'
        setTimeout(() => {
          copyButton.innerHTML =
            '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>'
        }, 2000)
      })
    })

    pre.appendChild(copyButton)
  })
}

function copyRichText(markdownElement) {
  const range = document.createRange()
  range.selectNodeContents(markdownElement)

  const selection = window.getSelection()
  if (!selection) return

  selection.removeAllRanges()
  selection.addRange(range)
  document.execCommand("copy")
  selection.removeAllRanges()
}

const Hooks = {
  ScrollHandler: {
    mounted() {
      this.handleEvent("scroll_to", ({id, block}) => {
        const target = document.getElementById(id)
        if (target) {
          target.scrollIntoView({behavior: "smooth", block: block || "nearest"})
        }
      })
    },
  },
  MarkdownRenderer: {
    mounted() {
      this.renderMarkdown()
    },
    updated() {
      this.renderMarkdown()
    },
    renderMarkdown() {
      const markdownElement = this.el.querySelector(".markdown-content")
      if (!markdownElement) return

      const markdown = markdownElement._markdownSource || markdownElement.textContent || ""
      markdownElement._markdownSource = markdown
      markdownElement.innerHTML = marked.parse(markdown)

      const showCopyButtons = this.el.dataset.showCopyButtons === "true"
      if (showCopyButtons) {
        addCodeCopyButtons(markdownElement)
        const buttons = this.el.querySelectorAll(".action-button")
        buttons.forEach(button => {
          const action = button.dataset.action
          button.onclick = event => {
            event.preventDefault()
            if (action === "copy-markdown") {
              navigator.clipboard.writeText(markdownElement._markdownSource || markdown)
            }
            if (action === "copy-rich-text") {
              copyRichText(markdownElement)
            }
          }
        })
      }
    },
  },
  InputField: {
    mounted() {
      this.el.addEventListener("keydown", event => {
        if (event.key === "Enter" && event.metaKey) {
          event.preventDefault()
          this.pushEvent("submit", {})
        }
      })
    },
  },
  DocumentationPicks: {
    mounted() {
      this.storageKey = "selectedDocumentationPicks"
      this.handleEvent("save_picks", ({names}) => {
        if (Array.isArray(names)) {
          localStorage.setItem(this.storageKey, JSON.stringify(names))
        }
      })
      this.applySavedSelections()
    },
    updated() {
      this.applySavedSelections()
    },
    applySavedSelections() {
      if (this.hasApplied) {
        return
      }

      const saved = localStorage.getItem(this.storageKey)
      if (!saved) {
        this.hasApplied = true
        return
      }

      try {
        const savedPickNames = JSON.parse(saved)
        if (!Array.isArray(savedPickNames)) {
          this.hasApplied = true
          return
        }

        const customPickPrefix = "custom:"
        const customPick = savedPickNames.find(name => typeof name === "string" && name.startsWith(customPickPrefix))

        if (customPick) {
          const domain = customPick.replace(customPickPrefix, "")
          this.pushEvent("set_custom_domain", {domain: domain})
        } else {
          const firstPick = savedPickNames.length > 0 ? savedPickNames[0] : null
          if (firstPick) {
            this.pushEvent("select_pick_by_name", {name: firstPick})
          }
        }
      } catch (error) {
        console.error("Error parsing saved documentation picks:", error)
      }

      this.hasApplied = true
    },
  },
}
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: Hooks,
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}
