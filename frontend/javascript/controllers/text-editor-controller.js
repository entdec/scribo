import { Controller } from "stimulus"
import CodeMirror from "codemirror"

import "codemirror/addon/edit/closebrackets"
import "codemirror/addon/edit/closetag"
import "codemirror/addon/edit/matchtags"

import "codemirror/addon/selection/active-line"

import "codemirror/addon/mode/simple"
import "codemirror/addon/mode/multiplex"
import "codemirror/addon/dialog/dialog"
import "codemirror/addon/search/searchcursor"
import "codemirror/addon/search/search"
import "codemirror/addon/search/jump-to-line"
import "codemirror/addon/edit/matchtags"
import "codemirror/addon/hint/html-hint"
import "codemirror/addon/display/autorefresh"
import "codemirror/addon/hint/show-hint"
import "codemirror/addon/fold/foldgutter"

import "codemirror/mode/htmlmixed/htmlmixed"
import "codemirror/mode/slim/slim"
import "codemirror/mode/javascript/javascript"
import "codemirror/mode/slim/slim"
import "codemirror/mode/css/css"
import "codemirror/mode/sass/sass"
import "codemirror/mode/markdown/markdown"
import "codemirror/mode/xml/xml"
import "codemirror/mode/yaml/yaml"
import "codemirror/mode/yaml-frontmatter/yaml-frontmatter"

import "codemirror-liquid"

import "codemirror/lib/codemirror.css"
import "codemirror/addon/dialog/dialog.css"
import "codemirror/addon/hint/show-hint.css"
import "codemirror/addon/fold/foldgutter.css"

import "codemirror/theme/gruvbox-dark.css"
/***
 * Text editor controller
 *
 * Control codemirror
 */
export default class extends Controller {
  static targets = ["textarea"]

  connect() {
    const self = this

    // this.form = document.querySelector("form#edit_content_" + contentId)

    let mode = {
      name: "liquid",
      base: CodeMirror.mimeModes[this.data.get("mode")],
    }

    this.editor = CodeMirror.fromTextArea(this.textareaTarget, {
      lineNumbers: true,
      mode: { name: "yaml-frontmatter", base: mode },
      lineWrapping: true,
      tabSize: 2,
      autoRefresh: true,
      extraKeys: { "Ctrl-Space": "autocomplete", "Ctrl-J": "toMatchingTag" },
      foldGutter: true,
      autoCloseBrackets: true,
      autoCloseTags: true,
      matchTags: true,
      gutters: ["CodeMirror-linenumbers", "CodeMirror-foldgutter"],
    })

    if (window.matchMedia("(prefers-color-scheme: dark)").matches) {
      this.editor.setOption("theme", "gruvbox-dark")
    }

    if (this.data.get("readonly")) {
      this.editor.setOption("readOnly", this.data.get("readonly"))
    }

    this.editor.setSize("100%", this.data.get("height") || "100%")

    this.editor.on("change", function (editor, evt) {
      let event = new CustomEvent("content-editor.changed", {
        bubbles: true,
        cancelable: true,
        detail: {
          contentId: self.data.get("content-id"),
          dirty: !self.editor.getDoc().isClean(),
        },
      })
      self.element.dispatchEvent(event)
    })
  }

  disconnect() {
    this.editor.toTextArea()
  }

  save() {
    const self = this

    const formData = new FormData()
    formData.append("_method", "PATCH")
    formData.append("content[data_with_frontmatter]", this.editor.getValue())

    fetch(self.data.get("save-url"), {
      method: "POST",
      headers: {
        Accept: "application/json, text/javascript",
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
      },
      body: formData,
    }).then((response) => {
      if (response.status == 200) {
        let event = new CustomEvent("content-editor.changed", {
          bubbles: true,
          cancelable: true,
          detail: {
            contentId: self.data.get("content-id"),
            dirty: false,
          },
        })
        self.element.dispatchEvent(event)
      }
    })
  }
}