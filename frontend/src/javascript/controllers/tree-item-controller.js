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
        if (window.Turbolinks) {
            Turbolinks.visit(this.data.get('url'));
        } else {
            window.location.href = this.data.get('url');
        }
        event.stopPropagation();
    }

    disconnect() {
    }
}

