import { Controller } from "@hotwired/stimulus"
import Painterro from "painterro"

export default class extends Controller {
  static targets = ["textarea"]
  connect() {
    const self = this
    this.dirtyTrackingEnabled = false
    this.editor = Painterro({
      id: self.element.id,
      toolbarPosition: "top",
      hiddenTools: ["close", "save"],
      hideByEsc: false,
      saveByEnter: false,
      onImageLoaded: (e) => {
        self.dirtyTrackingEnabled = true
      },
      onChange: (e) => {
        if (self.dirtyTrackingEnabled == false) {
          return
        }
        let event = new CustomEvent("content-editor.changed", {
          bubbles: true,
          cancelable: true,
          detail: {
            contentId: self.data.get("content-id"),
            dirty: true,
          },
        })
        self.element.dispatchEvent(event)
      },
      saveHandler: (image, done) => {
        const formData = new FormData()
        formData.append("_method", "PATCH")
        formData.append(
          "content[data_with_frontmatter]",
          image.asBlob(self.data.get("mime-type"))
        )

        fetch(self.data.get("save-url"), {
          method: "POST",
          headers: {
            Accept: "application/json, text/javascript",
            "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")
              .content,
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
            done(false)
          }
        })
      },
    })
    this.editor.toolByKeyCode = {}

    this.editor.show(this.data.get("url"))
  }
  disconnect() {}
  save() {
    this.editor.save()
  }
}
