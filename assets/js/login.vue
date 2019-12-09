<template>
  <div class="row">
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
          <ul class="nav navbar-nav navbar-right">
            <li>
              <a href="#">
                <span class="glyphicon glyphicon-log-in"></span> Login
              </a>
            </li>
          </ul>
        </div>
      </div>
    </nav>
    <div class="well col-sm-offset-3 col-sm-6">
      <h2>Please log in</h2>
      <div>
        <div class="form-group">
          <label for="username">Username:</label>
          <input type="text" class="form-control" id="username" v-model="username" />
        </div>
        <div class="form-group">
          <label for="password">Password:</label>
          <input type="password" class="form-control" id="password" v-model="password" />
        </div>
        <button id="login_user" type="submit" class="btn btn-default" v-on:click="login">Submit</button>
      </div>
      <h2>or create new user</h2>
      <div>
        <div class="form-group">
          <label for="name">Name:</label>
          <input type="text" class="form-control" id="name" v-model="name" />
        </div>
        <div class="form-group">
          <label for="role">Role:</label>
          <input type="text" class="form-control" id="role" v-model="role" />
        </div>
        <div class="form-group">
          <label for="username">Username:</label>
          <input type="text" class="form-control" id="username" v-model="username2" />
        </div>
        <div class="form-group">
          <label for="password">Password:</label>
          <input type="text" class="form-control" id="password" v-model="password2" />
        </div>
        <div class="form-group">
          <label for="email">Email:</label>
          <input type="email" class="form-control" id="email" v-model="email" />
        </div>
        <button id="create_user" type="submit" class="btn btn-default" v-on:click="create">Create</button>
      </div>
    </div>
  </div>
</template>
<script>
import auth from "./auth";
import user from "./user";
import vue from "./app";

export default {
  data() {
    return {
      username: "",
      password: ""
    };
  },
  methods: {
    login: function() {
      auth.login(
        this,
        { username: this.username, password: this.password },
        "/"
      );
    },
    create: function() {
      user.create(this, {
        name: this.name,
        username2: this.username2,
        password2: this.password2,
        role: this.role,
        email: this.email
      });
    }
  }
};
</script>
