import { Controller } from 'stimulus'
import './tree-view.scss'
import 'element-closest'

import Sortable from 'sortablejs'

/***
 * Treeview controller
 *
 * Manages the tree view
 */
export default class extends Controller {
  static targets = ['folderTemplate', 'entryTemplate', 'openEditorTemplate'];

  connect() {
    const self = this

    self.element.querySelectorAll('li.directory').forEach(el => {
      el.addEventListener('click', event => {
        event.stopPropagation()
        if (event.target.closest('li.entry').classList.contains('directory')) {
          el.classList.toggle('open')
          el.classList.toggle('closed')
        }
      })
    })

    document.addEventListener('scribo-editor.changed', (event) => {
      const contentId = event.detail.textarea.closest('form').getAttribute('id').split('_')[2]

      const openEditors = document.querySelector('ul.openEditors')
      const editorItem = openEditors.querySelector(`li[data-content="${contentId}"]`)

      if (editorItem) {
        editorItem.classList.add('dirty')
      }
    })

    document.addEventListener('keydown', (event) => {
      if (event.key == 's' && event.metaKey == true) {
        event.preventDefault()
        event.stopPropagation()
        event.cancelBubble = true

        let selectedItem = document.querySelector('.tree-view li.entry.selected')
        if (selectedItem) {
          let contentId = selectedItem.getAttribute('data-content')
          self._saveOpenEditor(contentId)
        }
      }
    })

    self.element.querySelectorAll('ul').forEach(el => {
      new Sortable(el, {
        group: 'nested',
        animation: 150,
        fallbackOnBody: true,
        swapThreshold: 0.65,
        onEnd: (evt) => {
          const contentId = evt.item.getAttribute('data-content')
          const parentId = evt.to.getAttribute('data-parent')
          fetch(self.data.get('update-url'), {
            method: 'PUT',
            headers: {
              Accept: 'application/json, text/javascript',
              'Content-Type': 'application/json',
              'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').content
            },
            body: JSON.stringify({
              id: contentId,
              to: parentId,
              index: evt.newIndex
            })
          }).then((response) => {
          })
        },
        onMove: function (evt) {
          const parentId = evt.to.getAttribute('data-parent')
          if (parentId) {
            const file = document.querySelector('[data-content="' + parentId + '"]').classList.contains('file')
            if (file) {
              evt.preventDefault()
              return false
            }
          }
        }
      })
    })
  }

  // Collapse all folders
  collapseAll(event) {
    const self = this
    self.element.querySelectorAll('li.directory').forEach(el => {
      el.classList.remove('open')
      el.classList.add('closed')
    })
  }

  // Create content
  create(event) {
    const kind = event.target.closest('[data-action]').getAttribute('data-kind')
    const url = event.target.closest('[data-action]').getAttribute('data-url')

    let template = 'entryTemplateTarget'
    if (kind == 'folder') {
      template = 'folderTemplateTarget'
    }

    const newContentNode = document.importNode(this[template].content, true)

    const closestDirectory = event.target.closest('li.directory')
    let newContentContainer = event.target.closest('.section').querySelector('ul')
    if (closestDirectory) {
      newContentContainer = closestDirectory.querySelector('ul')
    }
    newContentContainer.prepend(newContentNode)

    const input = newContentContainer.querySelector('input')
    input.setAttribute('data-kind', kind)
    input.setAttribute('data-url', url)
    input.focus()
    input.setSelectionRange(0, input.value.length)

    input.addEventListener('keyup', function (event) {
      this._createContent(event, newContentContainer)
    }.bind(this))
    input.addEventListener('blur', function (event) {
      this._cancelCreate(event, newContentContainer)
    }.bind(this))

    event.stopPropagation()
  }

  // Save content
  save(event) {
    const self = this
    const parentContent = event.target.closest('li')
    const contentId = parentContent.getAttribute('data-content')

    const form = document.querySelector('form#edit_content_' + contentId)

    const formData = new FormData()
    formData.append('_method', 'PATCH')
    if (form.querySelector('textarea[name="content[properties]"]')) {
      formData.append('content[properties]', this._editorControllerForElement(form.querySelector('textarea[name="content[properties]"]')).editor.getValue())
    }
    if (form.querySelector('textarea[name="content[data_with_frontmatter]"]')) {
      formData.append('content[data_with_frontmatter]', this._editorControllerForElement(form.querySelector('textarea[name="content[data_with_frontmatter]"]')).editor.getValue())
    }
    fetch(parentContent.getAttribute('data-url'), {
      method: 'POST',
      // headers: {
      //     'Accept': 'application/json, text/javascript',
      //     'Content-Type': 'multipart/form-data' // application/x-www-form-urlencoded
      // },
      headers: {
        Accept: 'application/json, text/javascript',
        'X-CSRF-Token': form.querySelector('input[name="authenticity_token"]').value
      },
      body: formData
    }).then((response) => {
      if (response.status == 200) {
        response.json().then(function (data) {
          document.querySelector('.editor-pane').innerHTML = data.html
          const openEditors = document.querySelector('ul.openEditors')
          const editorItem = openEditors.querySelector(`li.dirty[data-content="${contentId}"]`)
          if (editorItem) {
            editorItem.classList.remove('dirty')
          }
        })
      }
    })

    event.stopPropagation()
  }

  // Delete content
  delete(event) {
    const self = this

    event.stopPropagation()
    event.cancelBubble = true

    const elm = event.target.closest('[data-action]')

    let result = true
    if (elm.getAttribute('data-confirm')) {
      result = confirm(elm.getAttribute('data-confirm'))
    }
    if (!result) {
      return
    }

    const formData = new FormData()
    formData.append('_method', 'DELETE')
    fetch(elm.getAttribute('data-url'), {
      method: 'POST',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').content
      },
      body: formData
    }).then((response) => {
      if (response.status == 200) {
        const node = elm.closest('li')
        if (node.parentNode) {
          self._closeOpenEditor(node.getAttribute('data-content'))
          node.parentNode.removeChild(node)
        }
      }
    })
  }

  // Opens content in the editor pane
  open(event) {
    const self = this
    const closestA = event.target.closest('a')

    // Is a rename currently happening? If so abort
    if (closestA.querySelector('input')) {
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
    const closestA = event.target.closest('a')

    // Is a rename currently happening? If so abort
    if (closestA.querySelector('input')) {
      return
    }

    const input = document.createElement('input')
    const nameSpan = closestA.firstChild
    input.type = 'text'
    input.value = nameSpan.innerText

    input.addEventListener('keyup', this._renameContent.bind(this))
    input.addEventListener('blur', this._cancelRename.bind(this))

    closestA.querySelector('.tools').style.display = 'none'
    nameSpan.innerText = ''
    nameSpan.appendChild(input)

    input.focus()
    input.setSelectionRange(0, input.value.length)

    event.stopPropagation()
    event.preventDefault()
    return false
  }

  disconnect() {
  }

  // Private

  _editorControllerForElement(elm) {
    return this.application.getControllerForElementAndIdentifier(elm, 'scribo-editor')
  }

  _open(event) {
    const self = this

    if (this.clicked == null) {
      return
    }

    if (document.querySelector('ul.openEditors li.dirty')) {
      let result = confirm("You have unsaved changes, do you want close this editor?")
      if (!result) {
        return
      }
    }

    this.clicked = null
    event.stopPropagation()
    const closestA = event.target.closest('a')

    fetch(closestA.getAttribute('data-tree-view-url'), {
      method: 'GET',
      headers: {
        Accept: 'application/json, text/javascript'
      }
    }).then((response) => {
      response.json().then(function (data) {
        self._selectEntry(closestA.closest('li.entry'))
        self._setOpenEditor(data.content)
        document.querySelector('.editor-pane').innerHTML = data.html
      })
    })
  }

  _renameContent(event) {
    const self = this
    const closestA = event.target.closest('a')

    const input = closestA.querySelector('input')
    const nameSpan = closestA.querySelector('span.name')
    nameSpan.setAttribute('data-path', input.value)

    const newName = input.value
    if (event.key == 'Enter') {
      fetch(closestA.getAttribute('data-tree-view-rename-url'), {
        method: 'PUT',
        headers: {
          Accept: 'application/json, text/javascript',
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').content
        },
        body: JSON.stringify({
          to: newName
        })
      }).then((response) => {
        self._cancelRename(event)
      })
    } else if (event.key == 'Escape') {
      self._cancelRename(event)
    }
  }

  _cancelRename(event) {
    const closestA = event.target.closest('a')
    const nameSpan = closestA.firstChild
    const input = nameSpan.querySelector('input')
    closestA.querySelector('.tools').style.display = ''

    const name = input.value
    nameSpan.removeChild(input)
    nameSpan.innerText = name
  }

  _createContent(event, newContentContainer) {
    const self = this

    const input = newContentContainer.querySelector('input')
    const nameSpan = newContentContainer.querySelector('span.name')
    nameSpan.setAttribute('data-path', input.value)

    if (event.key == 'Enter') {
      const parent = newContentContainer.getAttribute('data-parent')

      fetch(input.getAttribute('data-url'), {
        method: 'POST',
        headers: {
          Accept: 'application/json, text/javascript',
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').content
        },
        body: JSON.stringify({
          parent: parent,
          kind: input.getAttribute('data-kind'),
          path: input.value
        })
      }).then((response) => {
        if (response.status == 200) {
          response.json().then(function (data) {
            self._cancelCreate(event, newContentContainer)
            newContentContainer.insertAdjacentHTML('afterbegin', data.itemHtml)
            if (data.content.kind != 'folder') {
              document.querySelector('.editor-pane').innerHTML = data.html
              self._selectEntry(newContentContainer.querySelector('li.' + (data.content.kind == 'folder' ? 'folder' : 'file')))
              self._setOpenEditor(data.content)
            }
          })
        }
      })
    } else if (event.key == 'Escape') {
      self._cancelCreate(event, newContentContainer)
    }
  }

  _cancelCreate(event, newContentContainer) {
    newContentContainer.removeChild(newContentContainer.firstChild)
  }

  _selectEntry(element) {
    const treeView = document.querySelector('.tree-view')
    const lastSelected = treeView.querySelector('li.entry.selected')
    if (lastSelected) {
      lastSelected.classList.remove('selected')
    }

    element.classList.add('selected')
  }

  _setOpenEditor(dataContent) {
    const self = this

    const openEditors = document.querySelector('ul.openEditors')

    let content = self.openEditorTemplateTarget.innerHTML
    for (const [key, value] of Object.entries(dataContent)) {
      content = content.replace(new RegExp('\\$\\{' + key + '\\}', 'g'), value)
    }

    openEditors.innerHTML = content
  }

  _closeOpenEditor(contentId) {
    const openEditors = document.querySelector('ul.openEditors')
    const editorItem = openEditors.querySelector(`li[data-content="${contentId}"]`)
    if (editorItem) {
      openEditors.removeChild(editorItem)
      document.querySelector('.editor-pane').innerHTML = ''
    }
  }

  _saveOpenEditor(contentId) {
    const openEditors = document.querySelector('ul.openEditors')
    const editorItem = openEditors.querySelector(`li.dirty[data-content="${contentId}"]`)
    if (editorItem) {
      this._triggerEvent(editorItem.querySelector('[data-action="click->tree-view#save"]'), 'click')
      editorItem.classList.remove('dirty')
    }
  }

  _triggerEvent(el, name, data) {
    if (typeof window.CustomEvent === 'function') {
      var event = new CustomEvent(name, { detail: data })
    } else {
      var event = document.createEvent('CustomEvent')
      event.initCustomEvent(name, true, true, data)
    }
    el.dispatchEvent(event)
  }
}
