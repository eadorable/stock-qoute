import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="chart-form"
// export default class extends Controller {
//   connect() {

//     console.log("Chart form controller connected")
//   }
// }

export default class extends Controller {
  static targets = ["timespan", "window", "limit"];

  async updateChart() {
    const timespan = this.timespanTarget.value;
    const window = this.windowTarget.value;
    const limit = this.limitTarget.value;

    const url = new URL(window.location.href);
    url.searchParams.set("timespan", timespan);
    url.searchParams.set("window", window);
    url.searchParams.set("limit", limit);

    const response = await fetch(url);
    const html = await response.text();

    document.getElementById('chart-container').innerHTML = html;
  }
}
