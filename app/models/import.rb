class Admin::Import
  include ActiveModel::Model
  attr_accessor :file, :imported_count
  
  def process!
    @imported_count = 0
    CSV.foreach(file.path, headers: true, header_converters: :symbol) do |row|
    admin = Admin.assign_from_row(row)
      if admin.save
        admin.save(validate: false) # Skips Validations for testing purposes.
        @imported_count += 1 if admin.persisted?
      else
        errors.add(:base, "Line #{$.} - #{admin.errors.full_messages.join(",")}")
      end
    end
  end
  
  def save
    process!
    errors.none?
  end
  
end