<template>
  <div class="invoice_container">
    <div>
      <h2>Invoice</h2>

      <table style="width:100%">
        <tr>
          <td>Zone</td>
          <td>{{zone}}</td>
        </tr>
        <tr>
          <td>Start time</td>
          <td>{{start_time}}</td>
        </tr>
        <tr>
          <td>End time</td>
          <td>{{end_time}}</td>
        </tr>
        <tr>
          <td>Total cost</td>
          <td>{{price}}</td>
        </tr>
      </table>
      <div v-if="msg === 'OK'">
        <button class="btn btn-default" v-on:click="createBooking">Pay</button>
      </div>
      <div v-if="msg !== 'OK'">
        <span>You don't have enough credit!</span>
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
      start_time: null,
      end_time: null,
      price: null,
      is_hourly: false,
      space_id: null,
      zone: null,
      msg: null
    };
  },
  created: async function(params) {
    this.start_time = this.$route.params.start_time
    this.end_time = this.$route.params.end_time
    this.space_id = this.$route.params.space_id
    this.is_hourly = this.$route.params.is_hourly
    this.calculatePrice()
  },
  methods: {
    calculatePrice: function(e) {
      axios
        .post(
          "/api/calculate_price",
          {
            start_time: this.start_time,
            end_time: this.end_time,
            space_id: this.space_id,
            is_hourly: this.is_hourly
          },
          { headers: auth.getAuthHeader() }
        )
        .then(response => {
          (this.zone = response.data.zone), (this.price = response.data.price), (this.msg = response.data.msg);
        });
    },
    createBooking: function(e) {
      if (this.is_hourly) {
          axios
            .post(
            "/api/book_location",
            {
                start_time: this.start_time,
                end_time: this.end_time,
                space_id: this.space_id,
                is_hourly: this.is_hourly,
                price: this.price
            },
            { headers: auth.getAuthHeader() }
            )
            .then(response => {
            this.$router.push('/') 
            });
      } else {
        axios
            .post(
            "/api/end_parking",
            {
                space_id: this.space_id
            },
            { headers: auth.getAuthHeader() }
            )
            .then(response => {
            this.$router.push('/') 
            });
      }
      
    }
  }
};
</script>
