class Video < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :description, :clip
  has_attached_file :clip

  validates_attachment_presence :clip

  acts_as_state_machine :initial => :pending
  state :pending
  state :converting
  state :converted, :enter => :set_new_filename
  state :error

  event :convert do
    transitions :from => :pending, :to => :converting
  end

  event :converted do
    transitions :from => :converting, :to => :converted
  end

  event :failed do
    transitions :from => :converting, :to => :error
  end

  def convert
    self.convert!
    cmd = convert_command
    puts "[CONVERT_COMMAND] #{cmd}"
    success = system(cmd)
    if success && $?.exitstatus == 0
      self.converted!
    else
      self.failure!
    end
  end

  protected

  def get_max_duration
    15 #seconds
  end

  def convert_command
    flv = File.join(File.dirname(clip.path), "#{id}.flv")
    max_t = self.get_max_duration
    File.open(flv, 'w')

    command = <<-end_command
      ffmpeg -i #{ clip.path }  -ar 22050 -ab 32 -acodec libmp3lame
      -s 480x360 -vcodec flv -r 25 -t #{max_t} -qscale 8 -f flv -y #{ flv }
    end_command
    command.gsub!(/\s+/, " ")
  end

  def set_new_filename
    update_attribute(:clip_file_name, "#{id}.flv")
  end

end
