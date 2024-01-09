// Connects to data-controller="chart-form"
// Connects to data-action="chart-form#updateChart"
// not use for now due to conflict with form_with method: :get
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["timespan", "window", "limit", "title"];

  // async updateChart(event) {
  //   event.preventDefault();

  //   this.titleTarget.innerHTML = "";

  //   const timespan = this.timespanTarget.value;
  //   const window = this.windowTarget.value;
  //   const limit = this.limitTarget.value;

  //   const chartTitle = `<h2>Timespan: ${timespan}, Window: ${window}, Limit: ${limit}</h2>`;


  //   this.titleTarget.insertAdjacentHTML("afterbegin", chartTitle);

  // }

  preventChartDefault(event) {
    event.preventDefault();
  }
}
