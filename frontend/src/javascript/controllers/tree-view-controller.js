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
                }
            });
        });

    }

    disconnect() {
    }
}

