# frozen_string_literal: true

require_relative 'db'
require_relative '../data/sender'

SENDER_FIELDS = 'id, created_at, name, username, password_hint, '\
                'comments'
ACCOUNT_FIELDS = 'id, sender_id, account_number, account_details, comments'

# fetches sender information from the db
class SenderHandler
  include Db

  def add_sender(sender)
    raise TypeError, 'add_sender expects a Sender' unless sender.is_a?(Sender)

    sql = 'insert into bills.sender (name, username, password_hint, '\
          'comments) values ($1, $2, $3, $4)'
    connect_for('adding a new sender') do |conn|
      conn.prepare('add_sender', sql)
      conn.exec_prepared('add_sender', [
                           sender.name,
                           sender.username,
                           sender.password_hint,
                           sender.comments
                         ])
    end
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

  # fetch individual sender, also populate its account data
  def fetch_sender(sender_id)
    ret = nil
    connect_for('fetching a sender') do |conn|
      sql = "select #{SENDER_FIELDS} from bills.sender where id = $1"
      conn.prepare('fetch_sender', sql)
      conn.exec_prepared('fetch_sender', [sender_id]) do |result|
        result.each do |result_row|
          ret = Sender.new(result_row['id'], result_row['created_at'])
          ret.fill_out_from(result_row)
        end
      end

      unless ret.nil?

        accounts = []
        sql = "select #{ACCOUNT_FIELDS} from bills.sender_account " \
              'where sender_id = $1 order by account_number'
        conn.prepare('fetch_sa', sql)
        conn.exec_prepared('fetch_sa', [sender_id]) do |result|
          result.each do |result_row|
            acc = SenderAccount.new(result_row['id'], result_row['sender_id'])
            acc.fill_out_from(result_row)
            accounts.push(acc)
          end
        end
        ret.add_accounts(accounts)
      end
      ret
    end

    ret
  end

  def fetch_senders
    ret = []
    connect_for('fetching all senders') do |conn|
      sql = "select #{SENDER_FIELDS} from bills.sender order by name"
      conn.exec(sql) do |result|
        result.each do |result_row|
          sender = Sender.new(result_row['id'], result_row['created_at'])
          sender.fill_out_from(result_row)
          ret.push(sender)
        end
      end
    end
    ret
  end
end
