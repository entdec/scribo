import { Controller } from "stimulus"
import Painterro from 'painterro'

export default class extends Controller {
  static targets = ["textarea"];
  connect() {
    console.log('connected - image-editor');
    const self = this;
    Painterro().show(this.data.get('url'))
  }
  disconnect() {

  }
};
