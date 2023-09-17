class Mailers::RootMailer
  attr_reader :mailer

  def initialize
    @mailer = SendGrid::API.new(api_key: Rails.application.credentials.sendgrid[:api_key])
  end

  def subject_content(subject_text)
    "#{Rails.env.production? ? '' : 'TEST - '}#{subject_text}"
  end

  def send_test_email(user)
    puts "\n\nSending test email to #{user.email}\n\n"
    to_email = SendGrid::Email.new(email: user.email)
    content = SendGrid::Content.new(type: 'text/plain',
                                    value: 'Hello! This is a test email from the Budget App. SUCCESS! emails are working!')
    personalization = SendGrid::Personalization.new
    personalization.add_to(to_email)
    mail = SendGrid::Mail.new
    mail.from = default_from
    mail.subject = subject_content('A sample email from Budget App')
    mail.add_content(content)
    mail.add_personalization(personalization)
    response = @mailer.client.mail._('send').post(request_body: mail.to_json)
    if response.status_code.to_i > 199 && response.status_code.to_i < 300
      puts "\n\nEmail sent successfully, status code: #{response.status_code}\n\n"
    else
      puts "\n\nEmail failed to send, status code: #{response.status_code}\n\n"
    end
  end

  private

  def default_from
    from_email = SendGrid::Email.new(email: 'jrwolf99@outlook.com')
  end
end
