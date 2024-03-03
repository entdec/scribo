import EditorComponentController from "satis/components/editor/component_controller"

/***
 * Text editor controller
 *
 * Control codemirror
 */
export default class extends EditorComponentController {
  static targets = ["textarea"]

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
