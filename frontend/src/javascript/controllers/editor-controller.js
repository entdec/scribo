import { Controller } from "stimulus"
import * as monaco from 'monaco-editor';

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

        var editor = monaco.editor.create(self.editorTarget, {
            value: [
                'function x() {',
                '\tconsole.log("Hello world!");',
                '}'
            ].join('\n'),
            language: 'javascript'
        });

    }

    disconnect() {
    }
}

