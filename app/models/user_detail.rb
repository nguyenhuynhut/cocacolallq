
class UserDetail < ActiveRecord::Base
  validates :real_name, :street_address, :state_id, :post_code ,:presence => true
  validates_numericality_of :post_code, :only_integer => true, :message => "can only be integer"
  belongs_to :user
    def savelogo(fileio)
    # ENSURE WE HAVE A FILE AND IT IS THE CORRECT CONTENT TYPE
    if (fileio && fileio.content_type =~ /^image/) then

      # GET THE EXTENSION, DIRECTORY, AND VIRTUAL PATH
      extension = File.extname(fileio.original_filename)
      dir = Rails.root.join('public','uploads')
      path = File.join('uploads')

      # CREATE THE DIRECTORY IF IT DOESNT EXIST
      Dir.mkdir(dir) unless File.exist?(dir)

      # WRITE THE ORIGINAL FILE FOR USE IN MINIMAGICK
      file_name = self.id.to_s + '_' + Time.now.to_i.to_s
      File.open(dir + (file_name + extension), "wb") do |f|
        f.write(fileio.read)
      end

      # PERFORM THE MINIMAGICK CHANGES
      mm = MiniMagick::Image.from_file(dir + (file_name + extension))
      mm.resize("60X60")
      mm.write( "public/uploads/" + (file_name + extension))

      # UPDATE ATTRIBUTES
      self.avatar = "/"+ path + "/" + file_name + extension
      self.save()
    end
  end
end
