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

    collapseAll(event) {
        const self = this;
        self.element.querySelectorAll('li.directory').forEach(el => {
            el.classList.remove('open');
            el.classList.add('closed');
        });
    }

    newContent(event) {
        let kind = event.target.closest('i[data-action]').getAttribute('data-kind');
        let url = event.target.closest('i[data-action]').getAttribute('data-url');

        let template = 'entryTemplateTarget'
        if (kind == 'folder') {
            template = 'folderTemplateTarget'
        }

        this.newContentNode = document.importNode(this[template].content, true);
        this.newContentContainer = event.target.closest('li.directory').querySelector('ul')
        console.log(this.newContentContainer);
        this.newContentContainer.prepend(this.newContentNode);

        let input = this.newContentContainer.querySelector('input')
        input.setAttribute('data-kind', kind)
        input.setAttribute('data-url', url)
        console.log(input);
        input.focus()

        input.addEventListener('keyup', this.createContent.bind(this));
        input.addEventListener('blur', this.cancelCreate.bind(this));

        event.stopPropagation();
    }

    createContent(event) {
        const self = this;
        let parentContent = event.target.closest('li.directory')
        if (event.key == "Enter") {
            let parent = self.newContentContainer.getAttribute('data-parent')
            let input = self.newContentContainer.querySelector('input')

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
                    console.log(data);
                    if (window.Turbolinks) {
                        Turbolinks.visit(data['url'])
                    } else {
                        window.location.href = data['url']
                    }

                    self.cancelCreate(event)
                });
            });
            self.cancelCreate(event)

        } else if (event.key == 'Escape') {
            self.cancelCreate(event)
        }

    }

    cancelCreate(event) {
        this.newContentContainer.removeChild(this.newContentContainer.firstChild);
    }

    save(event) {
        const self = this;
        let parentContent = event.target.closest('li')
        let contentId = parentContent.getAttribute('data-content');

        let form = document.querySelector('form#edit_content_' + contentId)
        form.submit();

        event.stopPropagation();
    }

    disconnect() {
    }
}

