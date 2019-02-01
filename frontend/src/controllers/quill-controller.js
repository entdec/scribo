import { Controller } from "stimulus"

import Quill from "quill";
import "quill/dist/quill.core.css";
import "quill/dist/quill.snow.css";

export default class extends Controller {
    static targets = ["editor"];

    connect() {
        var editor = new Quill(this.editorTarget, {
            // modules: { toolbar: '#toolbar' },
            theme: 'snow'
        });
    }
}
