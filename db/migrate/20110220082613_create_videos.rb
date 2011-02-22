class CreateVideos < ActiveRecord::Migration
  def self.up
    create_table :videos do |t|
      t.string :source_content_type
      t.string :source_file_name
      t.integer :source_file_size
      t.string :name
      t.text :description
      t.integer :user_id
      t.timestamps
    end
      add_index :videos, :user_id
  end

  def self.down
    drop_table :videos
  end
end
