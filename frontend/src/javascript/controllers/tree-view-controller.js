import { Controller } from "stimulus"
import "./tree-view.scss"
import "element-closest"

import Sortable from "sortablejs"

/***
 * Treeview controller
 *
 * Manages the tree view
 */
export default class extends Controller {
  static targets = ["folderTemplate", "entryTemplate"]

  connect() {
    const self = this

    self.element.addEventListener("click", (event) => {
      event.stopPropagation()
      let el = event.target.closest("li.entry")
      if (!el) {
        return
      }
      if (
        el &&
        event.target.closest("li.entry").classList.contains("directory")
      ) {
        el.classList.toggle("open")
        el.classList.toggle("closed")
      }
    })

    self.element.querySelectorAll("ul").forEach((el) => {
      new Sortable(el, {
        group: "nested",
        animation: 150,
        fallbackOnBody: true,
        swapThreshold: 0.65,
        onEnd: (evt) => {
          const contentId = evt.item.getAttribute("data-content")
          const parentId = evt.to.getAttribute("data-parent")
          fetch(self.data.get("update-url"), {
            method: "PUT",
            headers: {
              Accept: "application/json, text/javascript",
              "Content-Type": "application/json",
              "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")
                .content,
            },
            body: JSON.stringify({
              id: contentId,
              to: parentId,
              index: evt.newIndex,
            }),
          }).then((response) => {})
        },
        onMove: function (evt) {
          const parentId = evt.to.getAttribute("data-parent")
          if (parentId) {
            const file = document
              .querySelector('[data-content="' + parentId + '"]')
              .classList.contains("file")
            if (file) {
              evt.preventDefault()
              return false
            }
          }
        },
      })
    })
  }

  // Collapse all folders
  collapseAll(event) {
    const self = this
    self.element.querySelectorAll("li.directory").forEach((el) => {
      el.classList.remove("open")
      el.classList.add("closed")
    })
  }

  // Create content
  create(event) {
    const kind = event.target.closest("[data-action]").getAttribute("data-kind")
    const url = event.target.closest("[data-action]").getAttribute("data-url")

    let template = "entryTemplateTarget"
    if (kind == "folder") {
      template = "folderTemplateTarget"
    }

    const newContentNode = document.importNode(this[template].content, true)

    const closestDirectory = event.target.closest("li.directory")
    let newContentContainer = event.target
      .closest(".section")
      .querySelector("ul")
    if (closestDirectory) {
      newContentContainer = closestDirectory.querySelector("ul")
    }
    newContentContainer.prepend(newContentNode)

    const input = newContentContainer.querySelector("input")
    input.setAttribute("data-kind", kind)
    input.setAttribute("data-url", url)
    input.focus()
    input.setSelectionRange(0, input.value.length)

    input.addEventListener(
      "keyup",
      function (event) {
        this._createContent(event, newContentContainer)
      }.bind(this)
    )
    input.addEventListener(
      "blur",
      function (event) {
        this._cancelCreate(event, newContentContainer)
      }.bind(this)
    )

    event.stopPropagation()
  }

  // Delete content
  delete(event) {
    const self = this

    event.stopPropagation()
    event.cancelBubble = true

    const elm = event.target.closest("[data-action]")

    let result = true
    if (elm.getAttribute("data-confirm")) {
      result = confirm(elm.getAttribute("data-confirm"))
    }
    if (!result) {
      return
    }

    const formData = new FormData()
    formData.append("_method", "DELETE")
    fetch(elm.getAttribute("data-url"), {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name=csrf-token]").content,
      },
      body: formData,
    }).then((response) => {
      if (response.status == 200) {
        const node = elm.closest("li")
        const contentId = node.getAttribute("data-content")
        if (node.parentNode) {
          window.scriboEditors.close(contentId)
          node.parentNode.removeChild(node)
        }
      }
    })
  }

  // Opens content in the editor pane
  open(event) {
    const self = this
    const closestA = event.target.closest("a")

    // Is a rename currently happening? If so abort
    if (closestA.querySelector("input")) {
      return
    }
    this.clicked = event
    setTimeout(this._open.bind(this, event), 500)
    event.stopPropagation()
    event.preventDefault()
    return false
  }

  // Rename content
  rename(event) {
    const self = this
    this.clicked = null
    const closestA = event.target.closest("a")

    // Is a rename currently happening? If so abort
    if (closestA.querySelector("input")) {
      return
    }

    const input = document.createElement("input")
    const nameSpan = closestA.firstChild
    input.type = "text"
    input.value = nameSpan.innerText

    input.addEventListener("keyup", this._renameContent.bind(this))
    input.addEventListener("blur", this._cancelRename.bind(this))

    closestA.querySelector(".tools").style.display = "none"
    nameSpan.innerText = ""
    nameSpan.appendChild(input)

    input.focus()
    input.setSelectionRange(0, input.value.length)

    event.stopPropagation()
    event.preventDefault()
    return false
  }

  disconnect() {}

  // Private

  _open(event) {
    const self = this

    if (this.clicked == null) {
      return
    }

    this.clicked = null
    event.stopPropagation()
    const closestA = event.target.closest("a")

    fetch(closestA.getAttribute("data-tree-view-url"), {
      method: "GET",
      headers: {
        Accept: "application/json, text/javascript",
      },
    }).then((response) => {
      response.json().then(function (data) {
        window.scriboEditors.open(
          data.content.id,
          data.content.path,
          data.content.full_path,
          data.content.url,
          data.html
        )
        self._selectEntry(closestA.closest("li.entry"))
      })
    })
  }

  _renameContent(event) {
    const self = this
    const closestA = event.target.closest("a")

    const input = closestA.querySelector("input")
    const nameSpan = closestA.querySelector("span.name")
    nameSpan.setAttribute("data-path", input.value)

    const newName = input.value
    if (event.key == "Enter") {
      fetch(closestA.getAttribute("data-tree-view-rename-url"), {
        method: "PUT",
        headers: {
          Accept: "application/json, text/javascript",
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")
            .content,
        },
        body: JSON.stringify({
          to: newName,
        }),
      }).then((response) => {
        self._cancelRename(event)
      })
    } else if (event.key == "Escape") {
      self._cancelRename(event)
    }
  }

  _cancelRename(event) {
    const closestA = event.target.closest("a")
    const nameSpan = closestA.firstChild
    const input = nameSpan.querySelector("input")
    closestA.querySelector(".tools").style.display = ""

    const name = input.value
    nameSpan.removeChild(input)
    nameSpan.innerText = name
  }

  _createContent(event, newContentContainer) {
    const self = this

    const input = newContentContainer.querySelector("input")
    const nameSpan = newContentContainer.querySelector("span.name")
    nameSpan.setAttribute("data-path", input.value)

    if (event.key == "Enter") {
      const parent = newContentContainer.getAttribute("data-parent")

      fetch(input.getAttribute("data-url"), {
        method: "POST",
        headers: {
          Accept: "application/json, text/javascript",
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")
            .content,
        },
        body: JSON.stringify({
          parent: parent,
          kind: input.getAttribute("data-kind"),
          path: input.value,
        }),
      }).then((response) => {
        if (response.status == 200) {
          response.json().then(function (data) {
            self._cancelCreate(event, newContentContainer)
            newContentContainer.insertAdjacentHTML("afterbegin", data.itemHtml)
            if (data.content.kind != "folder") {
              // document.querySelector(".editor-pane").innerHTML = data.html
              self._selectEntry(
                newContentContainer.querySelector(
                  "li." + (data.content.kind == "folder" ? "folder" : "file")
                )
              )
              window.scriboEditors.open(
                data.content.id,
                data.content.path,
                data.content.full_path,
                data.content.url,
                data.html
              )
            }
          })
        }
      })
    } else if (event.key == "Escape") {
      self._cancelCreate(event, newContentContainer)
    }
  }

  _cancelCreate(event, newContentContainer) {
    newContentContainer.removeChild(newContentContainer.firstChild)
  }

  _selectEntry(element) {
    const treeView = document.querySelector(".tree-view")
    const lastSelected = treeView.querySelector("li.entry.selected")
    if (lastSelected) {
      lastSelected.classList.remove("selected")
    }

    element.classList.add("selected")
  }
}
