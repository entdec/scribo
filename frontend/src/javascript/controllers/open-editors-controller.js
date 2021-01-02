import { Controller } from "stimulus"
import "./open-editors.scss"

export default class extends Controller {
  static targets = ["tabs", "list", "contents"]

  connect() {
    this.editors = {}
    this.editorActive = null
    window.scriboEditors = this

    document.addEventListener("content-editor.changed", (event) => {
      let tab = this._tabForId(event.detail.contentId)
      let item = this._itemForId(event.detail.contentId)

      if (event.detail.dirty == true) {
        tab.classList.add("editor-tab--dirty")
        item.classList.add("dirty")
      } else if (event.detail.dirty == false) {
        tab.classList.remove("editor-tab--dirty")
        item.classList.remove("dirty")
      } else if (event.detail.path) {
        tab.querySelector(".name").innerText = event.detail.path
        item.querySelector(".name").firstChild.innerText = event.detail.path
        item.querySelector("small").innerText = event.detail.fullPath
      }
    })

    document.addEventListener("keydown", (event) => {
      if (event.key == "s" && event.metaKey == true && event.shiftKey == true) {
        event.preventDefault()
        event.stopPropagation()
        event.cancelBubble = true

        this.saveAll(event)
      } else if (event.key == "s" && event.metaKey == true) {
        event.preventDefault()
        event.stopPropagation()
        event.cancelBubble = true

        if (this.editorActive) {
          let elm = document.getElementById(
            "content-editor-" + this.editorActive
          )
          let controller = this._editorControllerForElement(elm)
          controller.save()
        }
      }
    })
  }

  open(id, name, path, url, data) {
    let existingEditor = this.editors[id]

    if (existingEditor) {
      this._activateEditor(existingEditor.id)
    } else {
      this._createEditor(id, name, path, url, data)
    }
  }

  close(id) {
    let existingEditor = this.editors[id]
    if (existingEditor) {
      let tab = this._tabForId(id)
      if (tab.classList.contains("editor-tab--dirty")) {
        let result = confirm(
          "You have unsaved changes, do you want close this editor?"
        )
        if (!result) {
          return
        }
      }
      this._removeEditor(id)
    }
  }

  closeAll(event) {
    this.tabsTarget.querySelectorAll(".editor-tab").forEach((element) => {
      if (!element.classList.contains("editor-tab--dirty")) {
        this._removeEditor(element.dataset.tab)
      }
    })
  }

  clickTabs(event) {
    let close = event.target.closest(".close")
    let tab = event.target.closest(".editor-tab")

    if (tab) {
      if (close) {
        this.close(tab.dataset.tab)
      } else {
        this._activateEditor(tab.dataset.tab)
      }
    }
  }

  clickList(event) {
    // TODO: Include close button and dirty indicator in list too
    let tab = event.target.closest("li.editor")
    if (tab) {
      this._activateEditor(tab.dataset.tab)
    }
  }

  save(event) {
    event.stopPropagation()
    let tab = event.target.closest("li.editor")
    let contentId = tab.dataset.tab

    let elm = document.getElementById("content-editor-" + contentId)
    let controller = this._editorControllerForElement(elm)
    controller.save()
  }

  saveAll(event) {
    this.tabsTarget.querySelectorAll(".editor-tab").forEach((element) => {
      if (element.classList.contains("editor-tab--dirty")) {
        let elm = document.getElementById(
          "content-editor-" + element.dataset.tab
        )
        let controller = this._editorControllerForElement(elm)
        controller.save()
      }
    })
  }

  _editorControllerForElement(elm) {
    let result = this.application.getControllerForElementAndIdentifier(
      elm,
      "text-editor"
    )

    if (!result) {
      result = this.application.getControllerForElementAndIdentifier(
        elm,
        "image-editor"
      )
    }

    return result
  }

  _createEditor(id, name, path, url, data) {
    this.editors[id] = { id: id, name: name, path: path, url: url, data: data }
    this._createTab(id, name)
    this._createListEntry(id, name, path)
    this._createTabContent(id, url, data)
    this._activateEditor(id)
  }

  _removeEditor(id) {
    delete this.editors[id]
    if (this.editorActive == id) {
      // Can be null/undefined which is fine
      this._activateEditor(Object.keys(this.editors)[0])
    }
    this._removeTab(id)
    this._removeItem(id)
    this._removeContent(id)
  }

  _activateEditor(id) {
    this.editorActive = id
    this._activateTabs()
    this._activateContents()
  }

  _createTab(id, name) {
    let tab = document.createElement("div")
    tab.setAttribute("data-tab", id)
    tab.setAttribute("class", "editor-tab")

    let icon = document.createElement("i")
    icon.setAttribute("class", "close fa fa-times")

    let nameSpan = document.createElement("span")
    nameSpan.setAttribute("class", "name")
    nameSpan.setAttribute("data-path", name)
    nameSpan.appendChild(document.createTextNode(name))

    tab.appendChild(nameSpan)
    tab.appendChild(icon)

    this.tabsTarget.appendChild(tab)
  }

  _createListEntry(id, name, path) {
    let entry = document.createElement("li")
    entry.setAttribute("data-tab", id)
    entry.setAttribute("class", "editor file")

    let link = document.createElement("a")
    link.setAttribute("class", "list-item")

    let nameSpan = document.createElement("span")
    nameSpan.setAttribute("class", "name")
    nameSpan.setAttribute("data-path", path)
    nameSpan.appendChild(document.createTextNode(name))

    let nameSmall = document.createElement("small")
    nameSmall.appendChild(document.createTextNode(path))
    nameSpan.appendChild(nameSmall)

    link.appendChild(nameSpan)

    entry.appendChild(link)

    let tools = document.createElement("span")
    tools.setAttribute("class", "tools")

    let saveIcon = document.createElement("i")
    saveIcon.setAttribute("class", "close fal fa-save")
    saveIcon.setAttribute("data-action", "click->open-editors#save")

    tools.appendChild(saveIcon)

    link.appendChild(tools)

    this.listTarget.appendChild(entry)
  }

  _createTabContent(id, url, data) {
    let content = document.createElement("div")
    content.setAttribute("data-tab", id)
    content.setAttribute("class", "editor-content")

    content.innerHTML = data

    this.contentsTarget.appendChild(content)
  }

  _activateTabs() {
    this.tabsTarget.querySelectorAll(".editor-tab").forEach((element) => {
      element.classList.remove("editor-tab--active")
    })

    if (this.editorActive) {
      let tab = this._tabForId(this.editorActive)
      tab.classList.add("editor-tab--active")
    }
  }

  _activateContents() {
    this.contentsTarget
      .querySelectorAll(".editor-content")
      .forEach((element) => {
        element.classList.remove("editor-content--active")
      })

    if (this.editorActive) {
      let tabContent = this._contentForId(this.editorActive)
      tabContent.classList.add("editor-content--active")
    }
  }

  _removeTab(id) {
    let tab = this._tabForId(id)
    tab.remove()
  }

  _removeItem(id) {
    let item = this._itemForId(id)
    item.remove()
  }

  _removeContent(id) {
    let content = this._contentForId(id)
    content.remove()
  }

  _tabForId(id) {
    return this.tabsTarget.querySelector(".editor-tab[data-tab='" + id + "']")
  }

  _itemForId(id) {
    return this.listTarget.querySelector(".editor[data-tab='" + id + "']")
  }

  _contentForId(id) {
    return this.contentsTarget.querySelector(
      ".editor-content[data-tab='" + id + "']"
    )
  }
}
