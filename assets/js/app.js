import $ from "jquery";
window.jQuery = $;
window.$ = $;

import "bootstrap";
import Vue from "vue";
import VueRouter from "vue-router";

import login from "./login.vue";
import customer from "./customer.vue";
import parking from "./parking.vue";
import invoice from "./invoice.vue";
import main from "./main.vue";

import "phoenix";
import "axios";
// import "./socket";
import auth from "./auth";

const requireAuth = (to, _from, next) => {
  if (!auth.authenticated()) {
    next({
      path: "/login",
      query: { redirect: to.fullPath }
    });
  } else {
    next();
  }
};

const afterAuth = (_to, from, next) => {
  if (auth.authenticated()) {
    next(from.path);
  } else {
    next();
  }
};

Vue.use(VueRouter);

Vue.component("customer", customer);
Vue.component("parking", parking);
Vue.component("invoice", invoice);

var router = new VueRouter({
  routes: [
    { path: "/login", component: login, beforeEnter: afterAuth },
    { path: "/", component: main, beforeEnter: requireAuth },
    {
      path: "/parking",
      name: "parking",
      component: parking,
      beforeEnter: requireAuth
    },
    {
      path: "/invoice",
      name: "invoice",
      component: invoice,
      beforeEnter: requireAuth
    },
    { path: "*", redirect: "/" }
  ]
});

var app = new Vue({
  router
}).$mount("#parking-app");
