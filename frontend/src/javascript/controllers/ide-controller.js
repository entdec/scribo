import { Controller } from "stimulus"

/***
 * IDE controller
 *
 * Used to copy a bit of text
 */
export default class extends Controller {

    connect() {
        const self = this;

        let copySpan = document.createElement("span");
        copySpan.innerHTML = "Copy";
        copySpan.classList.add('copy');
        copySpan.classList.add('badge');
        copySpan.classList.add('badge-light');
        self.element.appendChild(copySpan);

        let copiedSpan = document.createElement("span");
        copiedSpan.innerHTML = "Copied";
        copiedSpan.classList.add('copied');
        copiedSpan.classList.add('hide');
        copiedSpan.classList.add('badge');
        copiedSpan.classList.add('badge-success');
        self.element.appendChild(copiedSpan);
    }

    disconnect() {
    }
}

