import { Controller } from "stimulus"

/***
 * Tree item controller
 *
 * Used to copy a bit of text
 */
export default class extends Controller {

    connect() {
        const self = this;
    }

    // Opens content in the editor pane
    open(event) {
        if (this.element.firstChild.tagName == 'INPUT') {
            return;
        }
        this.clicked = event;
        setTimeout(this._open.bind(this), 500)
        event.stopPropagation()
        event.preventDefault()
        return false
    }

    // Rename content
    rename(event) {
        this.clicked = null;
        let input = document.createElement('input')
        input.type = 'text'
        input.value = this.element.firstChild.innerText

        input.addEventListener('keyup', this._renameContent.bind(this));
        input.addEventListener('blur', this._cancelRename.bind(this));

        this.element.firstChild.style.display = 'none'
        this.element.insertBefore(input, this.element.firstChild)
        input.focus()
        input.setSelectionRange(0, input.value.length);

        event.stopPropagation()
        event.preventDefault()
        return false
    }

    // Private

    _open() {
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

    _renameContent(event) {
        const self = this;
        let newName = this.element.firstChild.value;
        if (event.key == "Enter") {
            fetch(self.data.get('rename-url'), {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    to: newName,
                })
            }).then((response) => {
                self.element.firstChild.nextSibling.innerText = newName;
                self._cancelRename(event)
            });
        } else if (event.key == 'Escape') {
            self._cancelRename(event)
        }
    }

    _cancelRename(event) {
        const self = this;
        self.element.removeChild(self.element.firstChild)
        self.element.firstChild.style.display = ''
    }

    disconnect() {
    }
}

