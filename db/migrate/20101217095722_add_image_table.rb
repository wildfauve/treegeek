class AddImageTable < ActiveRecord::Migration
  def self.up
    create_table :pictures do |t|
      t.string :image_file_name # original filename
      t.string :image_content_type # MIME type
      t.integer :image_file_size # file size in bytes
    end
  end


  def self.down
    drop_table :pictures
  end
end
