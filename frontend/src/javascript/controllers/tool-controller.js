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
        let result = true;
        if (this.data.get('confirm')) {
            result = confirm(this.data.get('confirm'))
        }

        if (result) {
            // Hack
            if (window.Turbolinks && !this.data.get('method')) {
                Turbolinks.visit(this.data.get('url'));
            } else {
                window.location.href = this.data.get('url');
            }
        }
        event.stopPropagation();
    }

    disconnect() {
    }
}

