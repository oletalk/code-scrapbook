# frozen_string_literal: true

require_relative '../../data/collectors/senderobjectcollector'
require_relative '../../data/sender'
require_relative '../../data/sendercontact'
require_relative '../../data/mappers/genericmapper'

describe SenderObjectCollector do
  describe '.process_result' do
    it 'creates an empty SOC object' do
      actual = SenderObjectCollector.new('sender_id')
      db_result = []
      expect(actual.process_result(db_result, proc {}, proc {}, proc {})).to eq([])
    end

    it 'creates a sender only' do
      soc = SenderObjectCollector.new('sender_id')

      db_result = [{
        'sender_id' => '3',
        'sender_name' => 'MSDW'
      }]
      actual = soc.process_result(db_result, create_sender, proc {}, proc {})
      expect(actual.length).to eq(1)
      expect(actual[0].name).to eq('MSDW')
    end

    it 'creates a sender with a contact' do
      soc = SenderObjectCollector.new('sender_id')

      db_result = [{
        'sender_id' => '12',
        'sender_name' => 'JPMC',
        'name' => 'CEO',
        'contact' => '+ 1 800-MR-DIMON',
        'comments' => 'this is a test ofc'
      }]
      actual = soc.process_result(
        db_result, create_sender, create_one_contact, attach_objects
      )
      expect(actual.length).to eq(1)
      expect(actual[0].name).to eq('JPMC')
      contacts = actual[0].sender_contacts
      expect(contacts.length).to eq(1)
      expect(contacts[0].contact).to eq('+ 1 800-MR-DIMON')
      expect(contacts[0].comments).to eq('this is a test ofc')
    end

    it 'creates two senders each with a contact' do
      soc = SenderObjectCollector.new('sender_id')

      db_result = [{
        'sender_id' => '12',
        'sender_name' => 'JPMC',
        'name' => 'CEO',
        'contact' => '+ 1 800-MR-DIMON',
        'comments' => 'this is a test ofc'
      },
      {
        'sender_id' => '33',
        'sender_name' => 'MSDW',
        'name' => 'Janitor',
        'contact' => 'jannie@msdw.com',
        'comments' => 'it is another test!'
      }]
      actual = soc.process_result(
        db_result, create_sender, create_one_contact, attach_objects)

      expect(actual.length).to eq(2)
      expect(actual[0].name).to eq('JPMC')
      contacts = actual[0].sender_contacts
      expect(contacts.length).to eq(1)
      expect(contacts[0].contact).to eq('+ 1 800-MR-DIMON')
      expect(contacts[0].comments).to eq('this is a test ofc')

      expect(actual[1].name).to eq('MSDW')
      contacts = actual[1].sender_contacts
      expect(contacts.length).to eq(1)
      expect(contacts[0].contact).to eq('jannie@msdw.com')
    end

  end

  it 'creates one sender with multiple contacts' do
    soc = SenderObjectCollector.new('sender_id')

    db_result = [{
      'sender_id' => '12',
      'sender_name' => 'JPMC',
      'name' => 'CEO',
      'contact' => '+ 1 800-MR-DIMON',
      'comments' => 'this is a test ofc'
    },
    {
      'sender_id' => '12',
      'sender_name' => 'JPMC',
      'name' => 'Janitor',
      'contact' => 'jannie@jpmc.com',
      'comments' => 'it is another test!'
    }]
    actual = soc.process_result(
      db_result, create_sender, create_one_contact, attach_objects)

    expect(actual.length).to eq(1)
    expect(actual[0].name).to eq('JPMC')
    contacts = actual[0].sender_contacts
    expect(contacts.length).to eq(2)
    expect(contacts[0].contact).to eq('+ 1 800-MR-DIMON')
    expect(contacts[0].comments).to eq('this is a test ofc')
    expect(contacts[1].comments).to eq('it is another test!')

  end

  # TEST DATA PROCS
  def create_sender
    proc { |row| 
      ret = Sender.new(row['sender_id'], nil)
      ret.name = row['sender_name']
      ret
    }
  end

  def create_one_contact
    proc { |row|
      GenericMapper.new.create_from_row(row, SenderContact)
    }
  end

  def attach_objects
    proc { |sender, array_of_objs|
      sender.add_contacts(array_of_objs)
    }
  end

end
