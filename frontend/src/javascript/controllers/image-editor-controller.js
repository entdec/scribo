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
      hiddenTools: ["close", "save"],
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
      saveHandler: (saver, done) => {
        console.log("saving", saver.getWidth(), saver.getHeight())
        console.log("Base64", saver.asDataURL())
        done(true)
      },
    })
    this.editor.toolByKeyCode = {}

    this.editor.show(this.data.get("url"))
  }
  disconnect() {}
}
