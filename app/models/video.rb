class Video < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :description, :clip

  # order reverse-chronologically, by default
  default_scope :order => 'videos.created_at DESC'

  validates :description, :presence => true, :length => { :maximum => 140 }
  validates :user_id, :presence => true

  # make Paperclip happy
  # TODO: add content-type and filename extension check
  has_attached_file :clip
  validates_attachment_presence :clip

  # FSM: might come in handy at some point
  acts_as_state_machine :initial => :pending
  state :pending
  state :uploading
  state :converting
  state :converted, :enter => :set_new_filename
  state :error

  event :upload do
    transitions :from => :init, :to => :uploading
  end

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
      self.failed!
    end
  end

  private

  def get_max_duration
    15 #seconds
  end

  def convert_command
    flv = File.join(File.dirname(clip.path), "#{id}.flv")
    max_t = get_max_duration
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
