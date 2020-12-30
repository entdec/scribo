import { Controller } from "stimulus"

export default class extends Controller {
  static targets = ['tabs', 'contents'];

  connect() {
    this.editors = {}
    window.scriboEditors = this;
  }

  open(id, name, url, data) {
    let existingEditor = this.editors[id];

    if (existingEditor) {
      this._activateTab(existingEditor.id)
    } else {
      this._createTab(id, name)
      this._activateTab(id)
      this.editors[id] = { id: id, name: name, url: url, data: data }
    }
  }

  _createTab(id, name) {
    let tab = document.createElement('div');
    tab.setAttribute('data-tab', id);
    tab.setAttribute('class', 'editor-tab');

    let icon = document.createElement('i');
    icon.setAttribute('class', 'fa fa-times')

    tab.appendChild(document.createTextNode(name));
    tab.appendChild(icon);

    this.tabsTarget.appendChild(tab);
  }

  _activateTab(id) {
    this.tabsTarget.querySelectorAll(".editor-tab").forEach(element => {
      element.classList.remove('editor-tab--active');
    });
    let tab = this.tabsTarget.querySelector(".editor-tab[data-tab='" + id + "']")
    tab.classList.add('editor-tab--active');
  }
}
