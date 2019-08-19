import { Controller } from "stimulus"

/***
 * IDE controller
 *
 * Used to copy a bit of text
 */
export default class extends Controller {
    static targets = ["editor", "editorContainer", "tab", "tabContainer"];

    connect() {
        const self = this;

        console.log("ohai");
        console.log(self.editorTargets);
        console.log(self.tabTargets);

    }

    disconnect() {
    }
}

