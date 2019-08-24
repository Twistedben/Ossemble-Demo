class CityMailer < ApplicationMailer
# Main Mailer Model for sending Cities emails. 
  # Below - Sending email for Complaint filed threshold being hit, CAC.
  def complaint_filed_email(city, complaint)
    @city = city
    @complaint = complaint
    @url  = 'www.ossemble.com'
    mail(to: @city.email, subject: 'Ossemble - Address Official Community Complaint')
  end
  
  # Below - Sending email for Petition filed threshold being hit, petition for the city to consider.
  def petition_filed_email(city, petition)
    @city = city
    @petition = petition
    @url  = 'www.ossemble.com'
    mail(to: @city.email, subject: 'Ossemble - Address Official Community Petition')
  end
  # Below - Sending email for Petition filed threshold being hit to the recipient the author added upon creation.
  def recipient_petition_email(city, petition, recipient)
    @city = city
    @petition = petition
    @recipient = recipient 
    @url  = 'www.ossemble.com'
    mail(to: recipient, subject: "FWD: Ossemble - Address Official #{city.name} Petition")
  end
  # Below - Sending email for Petition filed threshold being hit to the additional email recipients the author added upon creation.
  def additional_petition_email(city, petition, additional_recipient)
    @city = city
    @petition = petition
    @recipient = @petition.recipient 
    @additional_recipient = additional_recipient 
    @url  = 'www.ossemble.com'
    mail(to: additional_recipient, subject: "FWD: Ossemble - Address Official #{city.name} Petition")
  end

end
