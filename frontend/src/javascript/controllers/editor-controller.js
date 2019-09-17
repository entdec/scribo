import { Controller } from "stimulus"
import CodeMirror from "codemirror"
import "codemirror/addon/mode/simple";
import "codemirror/addon/mode/multiplex";
import "codemirror/mode/htmlmixed/htmlmixed";
import "codemirror/mode/slim/slim";
import "codemirror/addon/dialog/dialog";
import "codemirror/addon/search/searchcursor";
import "codemirror/addon/search/search";
import "codemirror/addon/search/jump-to-line";
import "codemirror/addon/edit/matchtags";
import "codemirror/addon/hint/html-hint";
import "codemirror/addon/display/autorefresh";
import "codemirror/addon/hint/show-hint";
// import "codemirror-liquid";

import "codemirror/lib/codemirror.css";
import "codemirror/addon/dialog/dialog.css";
import "codemirror/addon/hint/show-hint.css";

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
        console.log(this.data.get('mode'));
        let editor = CodeMirror.fromTextArea(this.element, {
            lineNumbers: true,
            mode: this.data.get('content-type'),
            lineWrapping: true,
            tabSize: 2,
            autoRefresh: true,
            extraKeys: { "Ctrl-Space": "autocomplete" }
        });
        editor.setSize('100%', '100%');
    }

    disconnect() {
    }
}

