# frozen_string_literal: true

# holds information about a document type (invoice, statement, notice etc)
class DocType
  attr_reader :id, :name

  def initialize(id_, name_)
    @id = id_
    @name = name_
  end
end
