<template>
  <div class="customer_container">

    <div v-if="is_hourly && booked">
      <h2>Active parking</h2>
      <span>You have active parking at zone {{zone}} from {{start_time}} to {{end_time}}.</span>
      <button v-on:click="extendParking" >Extend</button>
    </div>

    <div v-if="!is_hourly && booked">
      <h2>Active parking</h2>
      <span>You have active parking at zone {{zone}} from {{start_time}}.</span>
      <button v-on:click="endMinuteParking">End</button>
    </div>

    <div class="noParkings" v-if="!booked">
      <h2>Active parking</h2>
      <span>You haven't got any active parking at the moment.</span>
      <button v-on:click="createParking" >Create</button>
      
      <div v-if="unpaid_allocations.length === 0"> 
        <h3>Regiter monthly payment</h3>
        <form>
          <input type="checkbox" v-model="monthly_payment"> Monthly payment scheme<br>
          <input v-on:click="saveMonthlyPlan" type="submit" value="Save changes">
        </form>
      </div>

      <div v-if="monthly_payment && unpaid_allocations.length !== 0">
        <h3>You have selected monthly payment. To unselect it, you have to pay for unpaid parkings.</h3>
        <table>
          <tr>
              <th>Start time</th>
              <th>End time</th>
              <th>Price</th>
          </tr>
          <tr v-for="allocation in unpaid_allocations">
              <td>{{ allocation.start_time }}</td>
              <td>{{ allocation.end_time }}</td>
              <td>{{ allocation.price }}</td>
          </tr>
        </table>
        <span>Total: {{total}} </span>
        <button v-on:click="payMonthlyPayment" >Pay for all unpaid parkings</button>
      </div>

    </div>

    <div v-if="extension"> 
      <div class="form-group">
          <label for="end">New end time:</label>
          <input type="text" placeholder class="form-control" id="end" v-model="end_time" />
      </div>
      <div class="form-group">
          <div>
            <button class="btn btn-default" v-on:click="createExtension">Submit</button>
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
      booked: false,
      start_time: null,
      end_time: null,
      space: null,
      zone: null,
      msg: null,
      is_hourly: false,
      monthly_payment: false,
      extension: false,
      allocation_id: null,
      unpaid_allocations: [],
      total: 0
    };
  },
  created: async function() {
    this.getCustomerAllocations()
    this.getMonthlyPayment()
    this.getUnpaidAllocatons()
  },
  methods: {
    getCustomerAllocations: function(e) {
      axios
        .get(
          "/api/get_allocations",
          { headers: auth.getAuthHeader() }
        )
        .then(response => {
          this.start_time = response.data.start_time
          this.end_time = response.data.end_time
          this.is_hourly = response.data.is_hourly
          this.zone = response.data.zone
          this.space = response.data.space_id
          this.msg = response.data.msg
          this.allocation_id = response.data.allocation_id

          if (this.msg === "OK") {
            this.booked = true
          }
        });
    },
    createParking: function(e) {
      this.$router.push('/parking') 
    },
    getUnpaidAllocatons: function(e) {
      axios
        .get(
          "/api/get_unpaid_allocations",
          { headers: auth.getAuthHeader() }
        ).then(response => {
          console.log(response)
          this.unpaid_allocations = response.data.unpaid_allocations
          this.total = response.data.total
        });
    },
    payMonthlyPayment: function(e) {
      axios
        .post(
          "/api/pay_monthly_payment",
          {
            total: this.total,
          },
          { headers: auth.getAuthHeader() }
        )
        this.unpaid_allocations = []
        this.total = 0
    },
    getMonthlyPayment: function(e) {
      axios
        .get(
          "/api/get_monthly_payment",
          { headers: auth.getAuthHeader() }
        )
        .then(response => {
          this.monthly_payment = response.data.monthly_payment
        });
    },
    saveMonthlyPlan: function(e) {
      axios
        .post(
          "/api/save_monthly_plan",
          {
            monthly_payment: this.monthly_payment,
          },
          { headers: auth.getAuthHeader() }
        )
        alert("Payment scheme preference saved!");
    },
    extendParking: function(e) {
      this.extension = true
    },
    createExtension: function(e) {
      axios
        .post(
          "/api/extend_hour_parking",
          {
            end_time: this.end_time,
            allocation_id: this.allocation_id
          },
          { headers: auth.getAuthHeader() }
        )
        .then(response => {
          this.extension = false
        });
    },
    endMinuteParking: function(e) {
      this.end_time = moment(new Date()).format("YYYY-MM-DD HH:mm:ss");
      if (!this.monthly_payment) {
        this.$router.push({
          name: "invoice",
          params: {start_time: this.start_time, end_time: this.end_time, space_id: this.space, is_hourly: this.is_hourly}
        });
      } else {
        axios
        .post(
          "/api/register_parking_for_monthly_payment",
          {
          start_time: this.start_time, 
          end_time: this.end_time, 
          space_id: this.space, 
          is_hourly: this.is_hourly
          },
          { headers: auth.getAuthHeader() }
        )
        .then(response => {
          this.getCustomerAllocations()
          this.booked = false
          this.getUnpaidAllocatons()
        });
      }

    },
  }
};
</script>

<style>
div.noParkings {
  padding-left: 75px;
}
</style>
