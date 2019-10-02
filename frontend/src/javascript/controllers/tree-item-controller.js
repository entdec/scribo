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
        if (this.element.firstChild.tagName == 'INPUT') {
            return;
        }
        this.clicked = event;
        setTimeout(this.open.bind(this), 500)
        event.stopPropagation()
        event.preventDefault()
        return false
    }

    open() {
        if (this.clicked == null) {
            return;
        }
        console.log("single click")
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
        console.log('this.element.firstChild', this.element.firstChild)
        let input = document.createElement('input')
        input.type = 'text'
        input.value = this.element.firstChild.innerText

        input.addEventListener('keyup', this.actualRename.bind(this));
        input.addEventListener('blur', this.cancelRename.bind(this));

        this.element.firstChild.style.display = 'none'
        this.element.insertBefore(input, this.element.firstChild)
        input.focus()
        event.stopPropagation()
        event.preventDefault()
        return false
    }

    actualRename(event) {
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
                self.cancelRename(event)
            });
        } else if (event.key == 'Escape') {
            self.cancelRename(event)
        }
    }

    cancelRename(event) {
        const self = this;
        self.element.removeChild(self.element.firstChild)
        self.element.firstChild.style.display = ''
    }

    disconnect() {
    }
}

