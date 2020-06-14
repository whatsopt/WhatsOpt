# frozen_string_literal: true

namespace :whatsopt do
  namespace :check do
    desc "Run connection integrity/consistency check"
    task connections: :environment do
      conns = Connection.left_outer_joins(:from).where(variables: { id: nil })
      p conns.all
      conns = Connection.left_outer_joins(:from).where(variables: { id: nil })
      p conns.all
      conns = []
      Connection.all.each do |conn|
        if !conn.to
          p "Connection #{conn.id} is invalid"
          conns << conn unless conns.include?(conn)
        end
        if !conn.from
          p "Connection #{conn.id} is invalid"
          conns << conn unless conns.include?(conn)
        end
      end
      p conns
      # conns.map{|v| v.delete }
    end

    desc "Run variables integrity/consistency check"
    task variables: :environment do
      # vars_to_delete = []
      vars_to = Variable.left_outer_joins(:incoming_connection).where(connections: { id: nil })
      vars_from = Variable.left_outer_joins(:outgoing_connections).where(connections: { id: nil })
      vars = vars_to & vars_from
      p vars
      # vars.map{|v| v.delete }
    end
  end
end
