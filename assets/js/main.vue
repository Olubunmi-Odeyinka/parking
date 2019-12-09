<template>
  <div>
    <nav class="navbar navbar-inverse">
      <div class="container-fluid">
        <div class="navbar-header">
          <button
            type="button"
            class="navbar-toggle"
            data-toggle="collapse"
            data-target="#myNavbar"
          >
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </button>
          <a class="navbar-brand" href="#">Parking</a>
        </div>
        <div class="collapse navbar-collapse" id="myNavbar">
          <ul class="nav navbar-nav">
            <li class="active">
              <a href="#">Home</a>
            </li>
            <li>
              <a href="#">Page 1</a>
            </li>
            <li>
              <a href="#">Page 2</a>
            </li>
            <li>
              <a href="#">Page 3</a>
            </li>
          </ul>
          <ul class="nav navbar-nav navbar-right">
            <li>
              <a href="#">
                <span class="glyphicon glyphicon-log-out"></span> Log Out
              </a>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <customer v-if="getUserRole() === 'customer'"></customer>
    <div>
      <p class="pull-right">
        Done?
        <a href="/login" @click.prevent="logout">Log out!</a>
      </p>
    </div>
  </div>
</template>
<script>
import auth from "./auth";

export default {
  methods: {
    logout: function() {
      auth.logout(this, { headers: auth.getAuthHeader() });
    },
    getUserRole: () => auth.user.role
  }
};
</script>
