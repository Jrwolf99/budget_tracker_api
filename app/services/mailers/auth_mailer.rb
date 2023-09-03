class Mailers::AuthMailer < Mailers::RootMailer


  def send_email_verification_email(user)

    signed_id = user.email_verification_tokens.create.signed_id(expires_in: 2.days)

    to_email = SendGrid::Email.new(email: user.email)
    content = SendGrid::Content.new(type: 'text/html', value: "Click here to confirm your email address: <a href=#{app_host}/verify-email?token=#{signed_id}>Confirm</a>")
    personalization = SendGrid::Personalization.new
    personalization.add_to(to_email)
    mail = SendGrid::Mail.new
    mail.from = default_from
    mail.subject = subject_content('Confirm your email address')
    mail.add_content(content)
    mail.add_personalization(personalization)
    response = @mailer.client.mail._('send').post(request_body: mail.to_json)
    if response.status_code.to_i > 199 && response.status_code.to_i < 300
      puts "\n\nEmail sent successfully to #{user.email}, status code: #{response.status_code}\n\n"
    else
      puts "\n\nEmail failed to send to #{user.email}, status code: #{response.status_code}\n\n"
    end



  end


  def send_password_reset_email
    signed_id = user.password_reset_tokens.create.signed_id(expires_in: 20.minutes)

  end
    
    private
  

    def app_host
      ENV.fetch('FRONTEND_DOMAIN', nil)
    end
  
  end
  