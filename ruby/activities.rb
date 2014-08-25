class ActivityLogger

  def initialize(activityfilename)
    @activityfile = activityfilename
    # check if file exists
    unless File.exists?(@activityfile)
      # try creating it
      a_file = File.new(@activityfile, "w")
    end
    unless File.readable?(@activityfile)          
      raise "Given activities file #{@activityfile} isn't readable"
    end
    puts "ok, all looks good for your new ActivityLogger based off of #{@activityfile}"
  end
  # handle reading/writing to activities file

  # handle commands
  public
  def start(activity, timespec=Time.now.to_i)
    given_time = timespec
    puts "ok, recording start of #{activity} at #{given_time}"
    a_list = read_activity_file
    p a_list
  end

  private
  def read_activity_file
    @open_tasks = {}
    File.foreach(@activityfile) { |x|
      command, activity, spec = x.split('#')
      case command
      when "start" then
        if @open_tasks.key?(activity)
          internal_error "Attempt to start an activity that is already open"
        else
          @open_tasks[activity] = spec
        end
      when "stop" then
        if @open_tasks.key?(activity)
          @open_tasks.delete(activity)
        else
          internal_error "Attempt to stop an unknown activity '#{activity}'"
        end
      else
        puts "unknown command '#{command}' in activity file"
      end
    }
    @open_tasks
  end
  
  private
  def internal_error(errorstr)
    raise "Internal activities file error: #{errorstr}"
  end

end