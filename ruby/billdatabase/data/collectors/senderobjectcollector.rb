# frozen_string_literal: true

require_relative '../sender'

# class to assist in collecting objects from db rows
# where sender info is duplicated e.g. contacts
class SenderObjectCollector
  def initialize(id_field_name_)
    @id_field_name = id_field_name_
    reset
  end

  def reset
    @senders = []
    @prev_id = -1
    @curr_sender = nil
    @curr_sender_objects = []
  end

  def process_result(result,
                     populate_sender_proc, populate_senderobject_proc, assign_objects_proc)
    result.each do |result_row|
      id_value = result_row[@id_field_name]

      if id_value != @prev_id
        # puts "** new sender - save all info you have for sender #{@prev_id} **"
        unless @curr_sender.nil?
          # puts "  saving sender info for sender #{@curr_sender.id}"
          assign_objects_proc.call(@curr_sender, @curr_sender_objects)
          @senders.push(@curr_sender)

          @curr_sender_objects = []
        end
        @curr_sender = populate_sender_proc.call(result_row)
        @prev_id = id_value
      end
      @curr_sender_objects.push(populate_senderobject_proc.call(result_row))
    end
    # save any leftover rows
    unless @curr_sender.nil?
      # puts "  saving sender info for sender #{@curr_sender.id}"
      assign_objects_proc.call(@curr_sender, @curr_sender_objects)
      @senders.push(@curr_sender)

      @curr_sender_objects = []
    end
    @senders
  end
end
