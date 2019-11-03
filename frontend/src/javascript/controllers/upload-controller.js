import { Controller } from "stimulus"

/***
 * IDE controller
 *
 * Used to copy a bit of text
 */
export default class extends Controller {

  connect() {
    const self = this;

    self.element.addEventListener('dragover', function (evt) {
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
      for (let [key, value] of Object.entries(JSON.parse(self.data.get('extra-data')))) {
        formData.append(key, value);
      }

      for (let i = 0; i < evt.dataTransfer.files.length; i++) {
        formData.append('content[files][]', evt.dataTransfer.files[i]);
      }

      fetch(self.data.get('url'), {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name=csrf-token]').content
        },
        body: formData
      }).then((response) => {
        response.json().then(function (data) {
          let node = document.querySelector(self.data.get('replace-content-selector'));
          if (node) {
            node.innerHTML = data.html;
          }
        });
      });
    });
  }
}
