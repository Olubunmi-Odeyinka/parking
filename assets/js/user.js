import axios from "axios";

export default {
  user: { role: "", username: "" }, 
  create: function (creds) {
    axios.post("/api/users", {"name": creds.name, "username": creds.username2, "role": creds.role, "password": creds.password2})
      .catch(error => {
        console.log(error);
      });
    }
}