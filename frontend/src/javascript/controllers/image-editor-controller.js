import { Controller } from "stimulus"
import Painterro from "painterro"

export default class extends Controller {
  static targets = ["textarea"]
  connect() {
    console.log("connected - image-editor")
    const self = this
    this.dirtyTrackingEnabled = false
    this.editor = Painterro({
      id: "image-editor",
      toolbarPosition: "top",
      hiddenTools: ["close"], //, "save"],
      hideByEsc: false,
      saveByEnter: false,
      onImageLoaded: (e) => {
        self.dirtyTrackingEnabled = true
        console.log("image - editor - onImageLoaded called!")
      },
      onChange: (e) => {
        if (self.dirtyTrackingEnabled == false) {
          return
        }
        let event = new CustomEvent("image-editor.changed", {
          bubbles: true,
          cancelable: true,
          detail: {
            editor: self.editor,
            element: self.element,
          },
        })
        self.element.dispatchEvent(event)
      },
      saveHandler: (image, done) => {
        console.log("saving", image.getWidth(), image.getHeight())

        const formData = new FormData()
        formData.append("_method", "PATCH")
        formData.append("content[data_with_frontmatter]", image.asBlob())

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
            done(false)
            // Saved - not longer dirty, need to update treeview/openeditors
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
