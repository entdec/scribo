import Painterro from 'painterro'

export default class extends Controller {
  static targets = ["textarea"];
  connect() {
    const self = this;
    Painterro().show(this.data.get('url'))
  }
  disconnect() {

  }
};
