import { Controller } from "stimulus"

/***
 * IDE controller
 *
 * Used to copy a bit of text
 */
export default class extends Controller {

  connect() {
    const self = this;

    console.log("upload");

    let form = document.createElement("form");
    form.style = 'margin-left: -200vh; position: absolute;';
    form.setAttribute('method', "POST");
    form.setAttribute('enctype', "multipart/form-data");
    form.setAttribute('action', this.data.get('url'));
    form.setAttribute('data-remote', 'true');

    let input = document.createElement("input");
    input.setAttribute('type', "hidden");
    input.setAttribute('name', "content[parent_id]");
    input.setAttribute('value', this.data.get('parent-id'));

    this.fileInput = document.createElement("input");
    this.fileInput.setAttribute('type', "file");
    this.fileInput.setAttribute('name', "content[files][]");
    this.fileInput.setAttribute('multiple', true);

    form.appendChild(input);
    form.appendChild(this.fileInput);

    this.form = form;

    self.element.appendChild(form);

    self.element.addEventListener('dragover', function (evt) {
      evt.preventDefault();
    });

    self.element.addEventListener('dragenter', function (evt) {
      evt.preventDefault();
    });

    self.element.addEventListener('drop', function (evt) {
      console.log(evt);
      if (evt.dataTransfer.files.length == 0) {
        return;
      }
      self.fileInput.files = evt.dataTransfer.files;
      self.form.submit();
      evt.preventDefault();
      evt.cancelBubble();
    });
  }

}
