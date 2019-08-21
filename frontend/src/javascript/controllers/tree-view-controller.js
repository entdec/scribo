import { Controller } from "stimulus"
import "./tree-view.scss";

/***
 * IDE controller
 *
 * Used to copy a bit of text
 */
export default class extends Controller {

    connect() {
        const self = this;

        self.element.querySelectorAll('li.directory').forEach(el => {
            el.addEventListener('click', event => {
                event.stopPropagation();
                if(event.target.tagName != 'A' && event.target.parentElement.tagName != 'A') {
                    el.classList.toggle('open');
                    el.classList.toggle('closed');
                }
            });
        });

    }

    disconnect() {
    }
}

