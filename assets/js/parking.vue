<template>
  <div class="parking_container">
    <div v-if="loading" class="loading_container">
      <div class="loading_position">
        <div class="loader"></div>
      </div>
    </div>
    <div v-if="!booked">
      <div id="myMap" style="width: 100vw; height: 80vh;"></div>
    </div>
    <div
      v-if="!booked"
      v-bind:class="{ reduceVisibility: !loading }"
      class="row"
    >
      <label class="control-label col-sm-2" for="destination_address"
        >Destination address:</label
      >
      <div class="col-sm-3">
        <input
          type="text"
          class="form-control"
          id="destination_address"
          v-model="destination_address"
        />
      </div>

      <label class="control-label col-sm-2" for="stay_period"
        >Stay Period(Hrs):</label
      >
      <div class="col-sm-3">
        <input
          type="text"
          class="form-control"
          id="stay_period"
          v-model="stay_period"
        />
      </div>

      <div class="form-group col-sm-1">
        <div>
          <button class="btn btn-default" v-on:click="submitBookParking">
            Submit
          </button>
        </div>
      </div>
    </div>

    <div v-if="is_hourly" class="well col-sm-offset-4 col-sm-4">
      <h2>Period to Stay</h2>
      <div>
        <div class="form-group">
          <label for="start">start:</label>
          <input
            type="text"
            placeholder
            class="form-control"
            id="start"
            v-model="start_time"
          />
        </div>
        <div class="form-group">
          <label for="end">end:</label>
          <input
            type="text"
            placeholder
            class="form-control"
            id="end"
            v-model="end_time"
          />
        </div>

        <div class="form-group">
          <div>
            <button class="btn btn-default" v-on:click="bookSpace">
              Submit
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from "axios";
import auth from "./auth";
import moment from "moment";
import { router } from "vue-router";

export default {
  data() {
    return {
      destination_address: "Lossi 2, Tartu",
      stay_period: "",
      messages: "",
      infobox: null,
      loading: false,
      booked: false,
      start_time: null,
      end_time: null,
      space: null,
      msg: null
    };
  },
  methods: {
    bookSpace: function(e) {
      this.$router.push({
        name: "invoice",
        params: {
          start_time: this.start_time,
          end_time: this.end_time,
          space_id: this.space,
          is_hourly: this.is_hourly
        }
      });
    },
    pushpinClicked: function(e) {
      // return e.target;
      //Make sure the infobox has metadata to display.
      if (e.target.metadata) {
        // Set the infobox options with the metadata of the pushpin.
        this.infobox.setOptions({
          location: e.target.getLocation(),
          title: e.target.metadata.title,
          description: e.target.metadata.description,
          actions: e.target.metadata.actions,
          visible: true
        });
      }
    },
    selectMinutePayment: async function(id) {
      axios
        .post(
          "/api/book_location",
          {
            start_time: this.start_time,
            space_id: id,
            is_hourly: this.is_hourly,
            end_time: null,
            price: null
          },
          { headers: auth.getAuthHeader() }
        )
        .then(response => {
          this.$router.push("/");
        });
    },
    pickaPaymentScale: async function(param) {
      var theMap = document.getElementById("myMap");
      theMap.parentNode.removeChild(theMap);

      this.start_time = moment(new Date()).format("YYYY-MM-DD HH:mm:ss");
      this.end_time = moment(new Date()).format("YYYY-MM-DD HH:mm:ss");

      switch (param.is_hourly) {
        case true:
          this.is_hourly = true;
          break;
        case false:
          this.is_hourly = false;
          this.selectMinutePayment(param.id);
          break;
        default:
          console.log("Error");
          break;
      }
      this.booked = true;
      this.space = param.id;
      this.is_hourly = param.is_hourly;
      await this.$nextTick();
    },
    submitBookParking: function() {
      // let map = this.map;
      // let infobox = this.infobox;
      this.loading = true;
      var map = new Microsoft.Maps.Map("#myMap", {});

      //Create an infobox at the center of the map but don't show it.
      this.infobox = new Microsoft.Maps.Infobox(map.getCenter(), {
        visible: false
      });

      //Assign the infobox to a map instance.
      this.infobox.setMap(map);

      axios
        .post(
          "/api/find_location",
          {
            location: this.destination_address,
            intended_hour: this.stay_period
          },
          { headers: auth.getAuthHeader() }
        )
        .then(response => {
          this.loading = false;

          if (response.data.msg) {
            this.messages = response.data.msg;
          } else {
            // Zoom to the location
            map.setView({
              zoom: 13
            });

            var spaces = response.data.available_space;
            for (var i = 0, len = spaces.length; i < len; i++) {
              var pin = new Microsoft.Maps.Pushpin(
                new Microsoft.Maps.Location(
                  spaces[i].latitude,
                  spaces[i].longitude
                )
              );

              //Store some metadata with the pushpin.
              pin.metadata = {
                text: spaces[i].id,
                title: "Status: " + spaces[i].zone,
                actions: [
                  {
                    // name: spaces[i].id,
                    label: " Hour Rate ",
                    eventHandler: () => {
                      var openedDetails = document.getElementById("open_space");
                      var id = null;
                      if (openedDetails) {
                        var id_string = openedDetails.innerText;
                        id = parseInt(id_string);
                      }
                      this.pickaPaymentScale({
                        id: id,
                        is_hourly: true
                      });
                      // alert("Handler1");
                    }
                  },
                  {
                    // name: spaces[i].id,
                    label: " Minute Rate ",
                    eventHandler: () => {
                      var openedDetails = document.getElementById("open_space");
                      var id = null;
                      if (openedDetails) {
                        var id_string = openedDetails.innerText;
                        id = parseInt(id_string);
                      }

                      this.pickaPaymentScale({
                        id: id,
                        is_hourly: false
                      });
                      // alert("Handler2");
                    }
                  }
                ],
                description: `<div style="width: 200px;">

                              <div> <span class="label label-primary">Status:</span> ${
                                spaces[i].status
                              }</div>
                              <div> <span class="label label-primary"> One hour cost:</span> ${
                                spaces[i].zone_hourly_rate
                              }</div>
                              <div> <span class="label label-primary"> 5 minute cost:</span> ${
                                spaces[i].zone_real_time_rate
                              }</div>
                              <div> <span class="label label-primary"> Estimated hourly payment:</span> ${
                                spaces[i].calculated_hourly_rate
                                  ? spaces[i].calculated_hourly_rate
                                  : ""
                              }</div>
                              <div> <span class="label label-primary"> Estimated real-time payment:</span> ${
                                spaces[i].calculated_real_time_rate
                                  ? spaces[i].calculated_real_time_rate
                                  : ""
                              }</div>

                               <div id="open_space" style="display: none;"> ${
                                 spaces[i].id
                               }</div>

                              </div>`
              };

              //Add a click event handler to the pushpin.
              Microsoft.Maps.Events.addHandler(
                pin,
                "click",
                this.pushpinClicked
              );
              map.entities.push(pin);
            }

            // for (var i = map.entities.getLength() - 1; i >= 0; i--) {
            //   var pushpin = map.entities.get(i);
            //   if (pushpin instanceof Microsoft.Maps.Pushpin) {
            //     map.entities.removeAt(i);
            //   }
            // }
          }
        })
        .catch(error => {
          this.loading = false;
          console.log(error);
        });
    }
  }
};
</script>
