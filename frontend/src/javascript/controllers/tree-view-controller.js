import { Controller } from "stimulus"
import "./tree-view.scss";
import "element-closest";

import Sortable from 'sortablejs';

/***
 * Treeview controller
 *
 * Manages the tree view
 */
export default class extends Controller {
    static targets = ["folderTemplate", "entryTemplate"];

    connect() {
        const self = this;

        self.element.querySelectorAll('li.directory').forEach(el => {
            el.addEventListener('click', event => {
                event.stopPropagation();
                if (event.target.closest('li.entry').classList.contains('directory')) {
                    el.classList.toggle('open');
                    el.classList.toggle('closed');
                }
            });
        });

        self.element.querySelectorAll('ul').forEach(el => {
            new Sortable(el, {
                group: 'nested',
                animation: 150,
                fallbackOnBody: true,
                swapThreshold: 0.65,
                onEnd: (evt) => {
                    let contentId = evt.item.getAttribute('data-content');
                    let parentId = evt.to.getAttribute('data-parent');
                    fetch(self.data.get('update-url'), {
                        method: 'PUT',
                        headers: {
                            'Content-Type': 'application/json'
                        },
                        body: JSON.stringify({
                            id: contentId,
                            to: parentId,
                            index: evt.newIndex
                        })
                    }).then((response) => {
                    });
                },
                onMove: function (evt) {
                    let parentId = evt.to.getAttribute('data-parent');
                    if (parentId) {
                        let file = document.querySelector('[data-content="' + parentId + '"]').classList.contains('file');
                        if (file) {
                            evt.preventDefault();
                            return false;
                        }
                    }
                }
            });
        });

    }

    // Collapse all folders
    collapseAll(event) {
        const self = this;
        self.element.querySelectorAll('li.directory').forEach(el => {
            el.classList.remove('open');
            el.classList.add('closed');
        });
    }

    // Create content
    create(event) {
        let kind = event.target.closest('[data-action]').getAttribute('data-kind');
        let url = event.target.closest('[data-action]').getAttribute('data-url');

        let template = 'entryTemplateTarget'
        if (kind == 'folder') {
            template = 'folderTemplateTarget'
        }

        this.newContentNode = document.importNode(this[template].content, true);

        let closestDirectory = event.target.closest('li.directory');
        if (closestDirectory) {
            this.newContentContainer = closestDirectory.querySelector('ul')
        } else {
            this.newContentContainer = event.target.closest('.section').querySelector('ul');
        }
        this.newContentContainer.prepend(this.newContentNode);

        let input = this.newContentContainer.querySelector('input')
        input.setAttribute('data-kind', kind)
        input.setAttribute('data-url', url)
        input.focus()
        input.setSelectionRange(0, input.value.length);

        input.addEventListener('keyup', this._createContent.bind(this));
        input.addEventListener('blur', this._cancelCreate.bind(this));

        event.stopPropagation();
    }

    // Save content
    save(event) {
        const self = this;
        let parentContent = event.target.closest('li')
        let contentId = parentContent.getAttribute('data-content');

        let form = document.querySelector('form#edit_content_' + contentId)
        form.submit();

        event.stopPropagation();
    }

    // Delete content
    delete(event) {
        event.stopPropagation();
        event.cancelBubble = true;

        let elm = event.target.closest('[data-action]')

        let result = true;
        if (elm.getAttribute('data-confirm')) {
            result = confirm(elm.getAttribute('data-confirm'))
        }
        if (!result) {
            return;
        }

        let formData = new FormData();
        formData.append('_method', 'DELETE');
        fetch(elm.getAttribute('data-url'), {
            method: 'POST',
            body: formData
        }).then((response) => {
            if (response.status == 200) {
                let node = elm.closest("li");
                if (node.parentNode) {
                    node.parentNode.removeChild(node);
                }
            }
        });
    }

    // Opens content in the editor pane
    open(event) {
        const self = this;
        let closestA = event.target.closest('a');

        // Is a rename currently happening? If so abort
        if (closestA.querySelector('input')) {
            return;
        }
        this.clicked = event;
        setTimeout(this._open.bind(this, event), 500)
        event.stopPropagation()
        event.preventDefault()
        return false
    }

    // Rename content
    rename(event) {
        const self = this;
        this.clicked = null;
        let closestA = event.target.closest('a');

        // Is a rename currently happening? If so abort
        if (closestA.querySelector('input')) {
            return;
        }

        let input = document.createElement('input')
        let nameSpan = closestA.firstChild;
        input.type = 'text'
        input.value = nameSpan.innerText

        input.addEventListener('keyup', this._renameContent.bind(this));
        input.addEventListener('blur', this._cancelRename.bind(this));

        // nameSpan.style.display = 'none'
        closestA.querySelector('.tools').style.display = 'none'
        nameSpan.innerText = ''
        nameSpan.appendChild(input)
        // closestA.insertBefore(input, nameSpan)
        input.focus()
        input.setSelectionRange(0, input.value.length);

        event.stopPropagation()
        event.preventDefault()
        return false
    }

    disconnect() {
    }

    // Private

    _open(event) {
        const self = this;

        if (this.clicked == null) {
            return;
        }
        // let event = this.clicked;
        this.clicked = null;
        event.stopPropagation();

        fetch(event.target.closest('a').getAttribute('data-tree-view-url'), {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json'
            }
        }).then((response) => {
            response.json().then(function (data) {
                document.querySelector('.editor-pane').innerHTML = data.html;
            });
        });

    }

    _renameContent(event) {
        const self = this;
        let closestA = event.target.closest('a');

        let input = closestA.querySelector('input')
        let nameSpan = closestA.querySelector('span.name')
        nameSpan.setAttribute('data-path', input.value)

        let newName = closestA.firstChild.value;
        if (event.key == "Enter") {
            fetch(closestA.getAttribute('tree-view-rename-url'), {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    to: newName,
                })
            }).then((response) => {
                // closestA.firstChild.nextSibling.innerText = newName;
                self._cancelRename(event)
            });
        } else if (event.key == 'Escape') {
            self._cancelRename(event)
        }
    }

    _cancelRename(event) {
        const self = this;
        let closestA = event.target.closest('a');
        let nameSpan = closestA.firstChild;
        let input = nameSpan.querySelector('input')
        closestA.querySelector('.tools').style.display = ''

        let name = input.value;
        nameSpan.removeChild(input)
        nameSpan.innerText = name
    }

    _createContent(event) {
        const self = this;
        let parentContent = event.target.closest('li.directory')

        let input = self.newContentContainer.querySelector('input')
        let nameSpan = self.newContentContainer.querySelector('span.name')
        nameSpan.setAttribute('data-path', input.value)

        if (event.key == "Enter") {
            let parent = self.newContentContainer.getAttribute('data-parent')

            fetch(input.getAttribute('data-url'), {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    parent: parent,
                    kind: input.getAttribute('data-kind'),
                    path: input.value
                })
            }).then((response) => {
                response.json().then(function (data) {
                    if (window.Turbolinks) {
                        Turbolinks.visit(data['url'])
                    } else {
                        window.location.href = data['url']
                    }

                    self._cancelCreate(event)
                });
            });
            self._cancelCreate(event)

        } else if (event.key == 'Escape') {
            self._cancelCreate(event)
        }

    }

    _cancelCreate(event) {
        this.newContentContainer.removeChild(this.newContentContainer.firstChild);
    }

}

