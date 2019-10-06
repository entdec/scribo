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
    static targets = ["textarea", "file"];

    connect() {
        const self = this;
        let mode = CodeMirror.mimeModes[this.data.get('mode')];
        // let mode = { name: 'liquidextra', base: CodeMirror.mimeModes[this.data.get('mode')] };

        this.editor = CodeMirror.fromTextArea(this.textareaTarget, {
            lineNumbers: true,
            mode: { name: 'yaml-frontmatter', base: mode },
            lineWrapping: true,
            tabSize: 2,
            autoRefresh: true,
            extraKeys: { "Ctrl-Space": "autocomplete" }
        });
        this.editor.setSize('100%', this.data.get('height') || '100%');

        this.editor.on('dragover', function (editor, evt) {
            evt.preventDefault();
        });

        this.editor.on('dragenter', function (editor, evt) {
            evt.preventDefault();
        });

        this.editor.on('drop', function (editor, evt) {
            if (self.hasFileTarget) {
                self.fileTarget.files = evt.dataTransfer.files;
                evt.preventDefault();
            }
        });

    }

    disconnect() {
        this.editor.toTextArea();
    }
}

