import { Controller } from "stimulus"
import "./scribo-editors.scss"

export default class extends Controller {
  static targets = ["tabs", "contents"]

  connect() {
    this.editors = {}
    this.editorActive = null
    window.scriboEditors = this
  }

  open(id, name, url, data) {
    let existingEditor = this.editors[id]

    if (existingEditor) {
      this._activateEditor(existingEditor.id)
    } else {
      this._createEditor(id, name, url, data)
    }
  }

  close(id) {
    let existingEditor = this.editors[id]
    if (existingEditor) {
      this._removeEditor(id)
    }
  }

  clickTabs(event) {
    let close = event.target.closest("i")
    let tab = event.target.closest(".editor-tab")

    if (tab) {
      if (close) {
        this._removeEditor(tab.dataset.tab)
      } else {
        this._activateEditor(tab.dataset.tab)
      }
    }
  }

  _createEditor(id, name, url, data) {
    this.editors[id] = { id: id, name: name, url: url, data: data }
    this._createTab(id, name)
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
    icon.setAttribute("class", "fa fa-times")

    tab.appendChild(document.createTextNode(name))
    tab.appendChild(icon)

    this.tabsTarget.appendChild(tab)
  }

  _createTabContent(id, url, data) {
    let content = document.createElement("div")
    content.setAttribute("data-tab", id)
    content.setAttribute("class", "editor-content")

    // content.appendChild(document.createTextNode(data))
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

  _removeContent(id) {
    let content = this._contentForId(id)
    content.remove()
  }

  _tabForId(id) {
    return this.tabsTarget.querySelector(".editor-tab[data-tab='" + id + "']")
  }

  _contentForId(id) {
    return this.contentsTarget.querySelector(
      ".editor-content[data-tab='" + id + "']"
    )
  }
}
