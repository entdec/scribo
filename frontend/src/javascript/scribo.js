import "../images/caret-down.svg";
import "../images/caret-right.svg";
import "../images/folder.svg";
import "../images/icons";

import "../style/scribo.scss";

import { definitionsFromContext } from "stimulus/webpack-helpers"

export class Scribo {
  static start(application) {
    this.application = application;
    const context = require.context("./controllers", true, /\.js$/);
    this.application.load(definitionsFromContext(context));
  }
}
