defmodule Parking.AccessLayer.Mailer do
alias SendGrid.{Mail, Email}
def send_mail_now(emailaddress,mail_text) do
  Email.build()
    |> Email.put_from("Parking Support <sola@parking_dev.com>")
    |> Email.add_to(emailaddress)
    |> Email.put_subject("Booking Notification")
    |> Email.put_html(mail_text)
    #|> Email.put_send_at(1574988780)
    #|>Email.put_template("d-26e143441ab443b1846c16cf05f27b20")
     |> SendGrid.Mail.send()
    
    end

    def send_mail_later(emailaddress,mail_text,unix_time) do
  Email.build()
    |> Email.put_from("Parking Support <sola@parking_dev.com>")
    |> Email.add_to(emailaddress)
    |> Email.put_subject("Booking Notification")
    |> Email.put_html(mail_text)
    |> Email.put_send_at(unix_time)
    #|>Email.put_template("d-26e143441ab443b1846c16cf05f27b20")
     |> SendGrid.Mail.send()
    
    end
end