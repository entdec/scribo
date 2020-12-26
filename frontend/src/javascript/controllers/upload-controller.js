import { Controller } from "stimulus"

/***
 * Upload controller
 *
 * Uploads a file, when you drop a file.
 */
export default class extends Controller {

  connect() {
    const self = this;
    if(!self.data.has('param-name')) {
      console.warn(this.element, "has no data-upload-param attribute, uploads may not work")
    };

    self.element.addEventListener('dragover', function (evt) {
      self.element.classList.add('dragover');
      evt.preventDefault();
    });

    self.element.addEventListener('dragover', function (evt) {
      self.element.classList.remove('dragover');
      evt.preventDefault();
    });

    self.element.addEventListener('dragenter', function (evt) {
      evt.preventDefault();
    });

    self.element.addEventListener('drop', function (evt) {
      if (evt.dataTransfer.files.length == 0) {
        return;
      }

      evt.preventDefault();
      evt.cancelBubble = true;

      let formData = new FormData();
      if(self.data.has('extra-data')) {
        for (let [key, value] of Object.entries(JSON.parse(self.data.get('extra-data')))) {
          formData.append(key, value);
        }
      }

      for (let i = 0; i < evt.dataTransfer.files.length; i++) {
        formData.append(self.data.get('param-name'), evt.dataTransfer.files[i]);
      }

      fetch(self.data.get('url'), {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').content
        },
        body: formData
      }).then((response) => {
        response.json().then(function (data) {
          let node = document.querySelector(data.selector);
          if (node) {
            node.innerHTML = data.html;
          }
        });
      });
    });
  }
}
