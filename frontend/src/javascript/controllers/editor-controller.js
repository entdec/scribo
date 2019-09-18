import { Controller } from "stimulus"
import CodeMirror from "codemirror"
import "codemirror/addon/mode/simple";
import "codemirror/addon/mode/multiplex";
import "codemirror/mode/htmlmixed/htmlmixed";

import "codemirror/mode/slim/slim";
import "codemirror/mode/javascript/javascript";
import "codemirror/mode/slim/slim";
import "codemirror/mode/css/css";
import "codemirror/mode/sass/sass";
import "codemirror/mode/markdown/markdown";
import "codemirror/mode/xml/xml";
import "codemirror/mode/yaml/yaml";
import "codemirror/mode/yaml-frontmatter/yaml-frontmatter";

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
 * IDE - Editor controller
 *
 * Control codemirror
 */
export default class extends Controller {
    static targets = ["editor", "editorContainer", "tab", "tabContainer"];

    connect() {
        let mode = CodeMirror.mimeModes[this.data.get('mode')];

        this.editor = CodeMirror.fromTextArea(this.element, {
            lineNumbers: true,
            mode: mode, //this.data.get('content-type'),
            lineWrapping: true,
            tabSize: 2,
            autoRefresh: true,
            extraKeys: { "Ctrl-Space": "autocomplete" }
        });
        this.editor.setSize('100%', '100%');
    }

    disconnect() {
        this.editor.toTextArea();
    }
}

