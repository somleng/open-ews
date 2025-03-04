// Entry point for the build script in your package.json

import "@hotwired/turbo-rails";
import * as bootstrap from "bootstrap";
import * as tabler from "@tabler/core";
require("@rails/activestorage").start();
import moment from "moment";
import "./components/direct_upload";
import "./controllers";

document.addEventListener("turbo:load", function () {
  [].slice
    .call(document.querySelectorAll("time[data-behavior~=local-time]"))
    .map(function (element) {
      element.textContent = moment(element.textContent).format("lll (Z)");
    });
});
