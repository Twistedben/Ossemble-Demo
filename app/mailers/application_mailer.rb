class ApplicationMailer < ActionMailer::Base
# Main Application model for Mailer. Sets up default configuration:

  default from: "support@ossemble.com"
  layout 'mailer'

end
