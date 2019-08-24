namespace :import do
  desc "Imports CSV for admins"
  task :admin_import => :environment do
    counter = 0
    
    CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
      admin = Admin.assign_from_row(row)

        if admin.save
          admin.save(validate: false) # Skips Validations for testing purposes.
          counter += 1 if admin.persisted?
        else
          puts "#{admin.email} - #{admin.errors.full_messages.join(",")}"
        end
    end
    
    puts "Imported #{counter} admins"
  end
end