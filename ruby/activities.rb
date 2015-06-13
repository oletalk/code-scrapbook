class ActivityLogger

  # include './filehash'
  
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
  end
  # handle reading/writing to activities file

  # handle commands
  public
  def start(activity, timespec=Time.now.to_i)
    given_time = timespec
    puts "ok, recording start of #{activity} at #{given_time}"
    a_list = read_activity_file
    
    check_activity_for_errors
  end

  private
  def read_activity_file
    @open_tasks = {}
    File.foreach(@activityfile) { |x|
      command, activity, spec = x.split('#')

      ret_error = check_activity_for_errors(command, activity)
      if ret_error
        internal_error ret_error
      else
        case command
        when "start" then
          @open_tasks[activity] = spec
        when "stop" then
          @open_tasks.delete(activity)
        else
          internal_error "unknown command '#{command}' in activity file"
        end
      end
    }
    @open_tasks
  end
  
  private
  def write_new_activity(command, activity, timespec)
  end

  private
  def check_activity_for_errors(command, activity)
    case command
    when "start" then
      if @open_tasks.key?(activity)
        return "Attempt to start an activity that is already open"
      end
    when "stop" then
      unless @open_tasks.key?(activity)
        return "Attempt to stop an unknown activity '#{activity}'"
      end
    else
      return "unknown command '#{command}' in activity file"
    end
    
    return nil
  end
  
  private
  def internal_error(errorstr)
    puts "Internal activities file error: #{errorstr}"
  end

end