# frozen_string_literal: true

require 'json'
require_relative 'senderaccount'
require_relative 'sendercontact'
require_relative 'sendertag'

# holds information about the sender of a document (account you have with them)
class Sender
  attr_reader :id, :created_at, :sender_accounts, :sender_contacts, :sender_tags
  attr_accessor :name, :username, :password_hint, :comments, :is_active

  def initialize(id_, created_at_)
    @id = id_
    @created_at = created_at_
    @sender_accounts = []
    @sender_contacts = []
    @sender_tags = []
    @is_active = true
  end

  def fill_out_from(result_row)
    @name = result_row['name']
    @username = result_row['username']
    @password_hint = result_row['password_hint']
    @comments = result_row['comments']
    @is_active = result_row['is_active']
  end

  def add_tags(tags)
    tags.each do |tag|
      raise "Array doesn't completely consist of SenderTags" \
      unless tag.is_a?(SenderTag)

      @sender_tags.push(tag)
    end
  end

  def add_accounts(accounts)
    accounts.each do |account|
      raise "Array doesn't completely consist of SenderAccounts" \
      unless account.is_a?(SenderAccount)

      @sender_accounts.push(account)
    end
  end

  def add_contacts(contacts)
    contacts.each do |contact|
      raise "Array doesn't completely consist of SenderContacts" \
      unless contact.is_a?(SenderContact)

      @sender_contacts.push(contact)
    end
  end

  def to_json(*args)
    {
      JSON.create_id => self.class.name,
      'id' => @id,
      'name' => @name,
      'created_at' => @created_at,
      'username' => @username,
      'password_hint' => @password_hint,
      'comments' => @comments,
      'is_active' => @is_active,
      'sender_accounts' => @sender_accounts,
      'sender_contacts' => @sender_contacts,
      'sender_tags' => @sender_tags
    }.to_json(*args)
  end
end
