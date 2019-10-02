import { Controller } from "stimulus"

/***
 * IDE controller
 *
 * Used to copy a bit of text
 */
export default class extends Controller {

    connect() {
        const self = this;

        console.log("tool");

    }

    start(event) {
        if (this.element.firstChild.getAttribute('contenteditable') == 'true') {
            return;
        }
        this.clicked = event;
        setTimeout(this.open.bind(this), 200)
    }

    open() {
        if (this.clicked == null) {
            return;
        }
        let event = this.clicked;
        this.clicked = null;
        if (window.Turbolinks) {
            Turbolinks.visit(this.data.get('url'));
        } else {
            window.location.href = this.data.get('url');
        }
        event.stopPropagation();
    }

    rename(event) {
        this.clicked = null;
        console.log('this.element.firstChild', this.element.firstChild);
        // this.element.firstChild.setAttribute('contenteditable', true)
        // this.element.firstChild.focus()
        console.log('rename')
        event.stopPropagation()
        event.preventDefault()
        return false
    }

    disconnect() {
    }
}

