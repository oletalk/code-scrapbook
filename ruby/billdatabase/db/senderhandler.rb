# frozen_string_literal: true

require_relative 'db'
require_relative '../data/sender'
require_relative '../data/mappers/genericmapper'
require_relative '../data/mappers/sendermapper'
require_relative '../data/mappers/sendertagmapper'
require_relative '../data/collectors/senderobjectcollector'
require_relative '../util/logging'

SENDER_FIELDS = 'id, created_at, name, username, password_hint, '\
                'comments'
ACCOUNT_FIELDS = 'id, sender_id, account_number, account_details, comments'
CONTACT_FIELDS = 'id, sender_id, name, contact, comments'

# fetches sender information from the db
class SenderHandler
  include Db
  include Logging

  def add_sender(sender)
    ret = nil
    raise TypeError, 'add_sender expects a Sender' unless sender.is_a?(Sender)

    sql = 'insert into bills.sender (name, username, password_hint, '\
          'comments) values ($1, $2, $3, $4) returning id'
    connect_for('adding a new sender') do |conn|
      conn.prepare('add_sender', sql)
      conn.exec_prepared('add_sender', [
                           sender.name,
                           sender.username,
                           sender.password_hint,
                           sender.comments
                         ]) do |result|
                           result.each do |result_row|
                             ret = result_row['id']
                           end
                         end
    end
    log_info "new id returned: #{ret}"
    ret
  end

  def add_sender_account(account)
    unless account.is_a?(SenderAccount)
      raise TypeError,
            'add_sender_account expects a SenderAccount'
    end
    raise ArgumentError, 'provided account is not linked to a sender' if account.sender_id.nil?

    sql = 'insert into bills.sender_account '\
          '(sender_id, account_number, account_details, comments) '\
          'VALUES ($1, $2, $3, $4)'
    connect_for('adding an account to a sender') do |conn|
      conn.prepare('add_sa', sql)
      conn.exec_prepared('add_sa', [
                           account.sender_id,
                           account.account_number,
                           account.account_details,
                           account.comments
                         ])
    end
  end

  def upd_sender_account(account)
    unless account.is_a?(SenderAccount)
      raise TypeError,
            'add_sender_account expects a SenderAccount'
    end
    raise ArgumentError, 'provided account has no id' if account.id.nil?

    sql = 'update bills.sender_account '\
          'set account_number = $1, account_details = $2, comments = $3 '\
          ' where id = $4'
    connect_for('updating an account held with a sender') do |conn|
      conn.prepare('upd_sa', sql)
      conn.exec_prepared('upd_sa', [
                           account.account_number,
                           account.account_details,
                           account.comments,
                           account.id
                         ])
    end
  end

  def add_sender_contact(contact)
    unless contact.is_a?(SenderContact)
      raise TypeError,
            'add_sender_contact expects a SenderContact'
    end
    raise ArgumentError, 'provided contact is not linked to a sender' if contact.sender_id.nil?

    sql = 'insert into bills.sender_contact '\
          '(sender_id, name, contact, comments) '\
          'VALUES ($1, $2, $3, $4)'
    connect_for('adding a contact to a sender') do |conn|
      conn.prepare('add_sc', sql)
      conn.exec_prepared('add_sc', [
                           contact.sender_id,
                           contact.name,
                           contact.contact,
                           contact.comments
                         ])
    end
  end

  def upd_sender_contact(contact)
    unless contact.is_a?(SenderContact)
      raise TypeError,
            'add_sender_contact expects a SenderContact'
    end
    raise ArgumentError, 'provided contact has no id' if contact.id.nil?

    sql = 'update bills.sender_contact '\
          'set name = $1, contact = $2, comments = $3 '\
          ' where id = $4'
    connect_for('updating contact information for a sender') do |conn|
      conn.prepare('upd_sc', sql)
      conn.exec_prepared('upd_sc', [
                           contact.name,
                           contact.contact,
                           contact.comments,
                           contact.id
                         ])
    end
  end

  def update_sender(sender)
    raise TypeError, 'update_sender expects a Sender' unless sender.is_a?(Sender)

    sql = 'update bills.sender set username = $1, password_hint = $2, '\
          'comments = $3 where id = $4'
    connect_for('updating a sender') do |conn|
      conn.prepare('upd_sender', sql)
      conn.exec_prepared('upd_sender', [
                           sender.username,
                           sender.password_hint,
                           sender.comments,
                           sender.id
                         ])
    end
  end

  # fetch sender ids grouped by tag
  def fetch_sender_tags_and_ids
    ret = {}
    connect_for('fetching sender ids by tag') do |conn|
      sql = File.read('./sql/fetch_senders_grouped_by_tag.sql')
      conn.exec(sql) do |result|
        result.each do |result_row|
          tag_name = result_row['tag_name']
          color = result_row['color']
          ind = "#{tag_name}|#{color}"
          ret[ind] = [] if ret[ind].nil?
          ret[ind].push(result_row['sender_id'])
        end
      end
    end
    ret
  end

  # fetch individual sender, also populate its account data
  def fetch_sender(sender_id)
    ret = nil
    connect_for('fetching a sender') do |conn|
      sql = "select #{SENDER_FIELDS} from bills.sender where id = $1"
      conn.prepare('fetch_sender', sql)
      conn.exec_prepared('fetch_sender', [sender_id]) do |result|
        ret = SenderMapper.new.create_from_result(result)[0]
      end

      unless ret.nil?
        # load accounts you have with the sender if any
        ret.add_accounts(fetchlist_accounts(conn, sender_id))

        # load contact details you have with the sender if any
        ret.add_contacts(fetchlist_contacts(conn, sender_id))

        # load contact details you have with the sender if any
        ret.add_tags(fetchlist_tags(conn, sender_id))
      end
      ret
    end

    ret
  end

  ## sub methods for above
  def fetchlist_accounts(conn, sender_id)
    ret = []
    sql = "select #{ACCOUNT_FIELDS} from bills.sender_account " \
              'where sender_id = $1 and deleted is null order by account_number'
    conn.prepare('fetch_sa', sql)
    conn.exec_prepared('fetch_sa', [sender_id]) do |result|
      ret = GenericMapper.new.create_from_result(result, SenderAccount)
    end
    ret
  end

  def fetchlist_contacts(conn, sender_id)
    ret = []
    sql = "select #{CONTACT_FIELDS} from bills.sender_contact " \
      'where sender_id = $1 and deleted is null order by name'
    conn.prepare('fetch_sc', sql)
    conn.exec_prepared('fetch_sc', [sender_id]) do |result|
      ret = GenericMapper.new.create_from_result(result, SenderContact)
    end
    ret
  end

  def fetchlist_tags(conn, sender_id)
    ret = []
    sql = 'select tag_id, tag_name, color from bills.tag_type t, bills.sender_tag st ' \
      'where t.id = st.tag_id and st.sender_id = $1 order by tag_name'
    conn.prepare('fetch_st', sql)
    conn.exec_prepared('fetch_st', [sender_id]) do |result|
      ret = SenderTagMapper.new.create_from_result(result)
    end
    ret
  end

  ## end sub methods...
  def fetch_senders_and_tags
    ret = []
    soc = SenderObjectCollector.new('sender_id')

    # this is how soc should create a sender:
    so = proc { |result_row|
      ret = Sender.new(result_row['sender_id'], nil)
      ret.name = result_row['sender_name']
      ret
    }

    # this is how soc should create a tag
    so_contact = proc { |result_row|
      SenderTagMapper.new.create_from_row(result_row)
    }

    # attach the objects to each sender
    so_save_contacts = proc { |sender, objs|
      sender.add_tags(objs)
    }

    connect_for('fetching senders and tags') do |conn|
      sql = File.read('./sql/fetch_sender_tags.sql')
      conn.exec(sql) do |result|
        ret = soc.process_result(result, so, so_contact, so_save_contacts)
      end
    end
    ret
  end

  def fetch_senders
    ret = []
    connect_for('fetching all senders') do |conn|
      sql = "select #{SENDER_FIELDS} from bills.sender order by name"
      conn.exec(sql) do |result|
        sm = SenderMapper.new
        result.each do |result_row|
          sender = sm.create_from_row(result_row)
          ret.push(sender)
        end
      end
    end
    ret
  end

  def fetch_all_tags
    ret = []
    connect_for('fetching all tags') do |conn|
      sql = 'select id as tag_id, tag_name, color from bills.tag_type order by tag_name'
      conn.exec(sql) do |result|
        ret = SenderTagMapper.new.create_from_result(result)
      end
    end
    ret
  end

  def fetch_sender_tags(sender_id)
    ret = []
    connect_for('fetching sender tags') do |conn|
      ret = fetchlist_tags(conn, sender_id)
    end
    ret
  end

  def add_tagtype(tag)
    raise TypeError, 'add_tagtype expects a SenderTag' unless tag.is_a?(SenderTag)

    ret = { result: 'success' }
    sql = 'insert into bills.tag_type (tag_name, color) values ($1, $2)'
    connect_for('inserting new tag type') do |conn|
      conn.prepare('add_tagtype', sql)
      conn.exec_prepared('add_tagtype', [tag.description, tag.color])
    rescue StandardError => e
      ret = { result: e.to_s }
    end
    ret
  end

  def upd_tagtype(tag)
    raise TypeError, 'upd_tagtype expects a SenderTag' unless tag.is_a?(SenderTag)

    ret = { result: 'success' }
    sql = 'update bills.tag_type set color = $1 where id = $2'
    connect_for('updating tag color') do |conn|
      conn.prepare('upd_tagtype', sql)
      conn.exec_prepared('upd_tagtype', [tag.color, tag.id])
    rescue StandardError => e
      ret = { result: e.to_s }
    end
    ret
  end

  def del_sender_tag(sender_id, tag_id)
    sql = 'delete from bills.sender_tag where sender_id = $1 and tag_id = $2'
    connect_for('deleting a tag from a sender') do |conn|
      conn.prepare('del_st', sql)
      conn.exec_prepared('del_st', [sender_id, tag_id])
    end
  end

  def add_sender_tag(sender_id, tag_id)
    sql = 'insert into bills.sender_tag (sender_id, tag_id) values ($1, $2)'
    connect_for('adding a tag to a sender') do |conn|
      conn.prepare('add_st', sql)
      conn.exec_prepared('add_st', [sender_id, tag_id])
    end
  end

  def del_sender_account(sa_id)
    raise 'Cannot delete account while it still has associated documents' \
    unless check_senderaccount_nodocuments(sa_id)

    sql = 'update bills.sender_account '\
          "set deleted = 'Y' where id = $1"
    connect_for('marking a sender account as deleted') do |conn|
      conn.prepare('upd_sa', sql)
      conn.exec_prepared('upd_sa', [sa_id])
    end
  end

  def del_sender_contact(sc_id)
    sql = 'update bills.sender_contact '\
          "set deleted = 'Y' where id = $1"
    connect_for('marking a sender contact as deleted') do |conn|
      conn.prepare('upd_sc', sql)
      conn.exec_prepared('upd_sc', [sc_id])
    end
  end

  def check_senderaccount_nodocuments(sa_id)
    ret = true
    connect_for('checking sender account for any associated documents') do |conn|
      sql = 'select 1 from bills.document where sender_account_id = $1'
      conn.prepare('check_sa_nd', sql)
      conn.exec_prepared('check_sa_nd', [sa_id]) do |result|
        result.each do
          ret = false
        end
      end
    end
    ret
  end

  def fetch_all_contacts
    ret = []

    soc = SenderObjectCollector.new('sender_id')
    # 3 procs for SenderObjectCollector
    so = proc { |result_row| # save sender
      ret = Sender.new(result_row['sender_id'], nil)
      ret.name = result_row['sender_name']
      ret
    }

    so_contact = proc { |result_row| # save sender object (contact)
      GenericMapper.new.create_from_row(result_row, SenderContact)
    }

    so_save_contacts = proc { |sender, objs| # link objects to sender
      sender.add_contacts(objs)
    }

    connect_for('fetching all sender contacts') do |conn|
      sql = File.read('./sql/fetch_all_contact_info.sql')

      conn.exec(sql) do |result|
        ret = soc.process_result(result, so, so_contact, so_save_contacts)
      end
    end
    ret
  end
end
