class ChangeSurrogateKind < ActiveRecord::Migration[6.0]
  OLD_KINDS = ['KRIGING', 'KPLS', 'KPLSK', 'LS', 'QP']
  NEW_KINDS = ['SMT_KRIGING', 'SMT_KPLS', 'SMT_KPLSK', 'SMT_LS', 'SMT_QP']

  def up

    MetaModel.all.each do |mm|
      kind = mm.default_surrogate_kind
      if OLD_KINDS.include?(kind)
        mm.update!(default_surrogate_kind: "SMT_#{kind}")
      end
    end

    Surrogate.all.each do |surr|
      kind = surr.kind
      if OLD_KINDS.include?(kind)
        surr.update!(kind: "SMT_#{kind}")
      end
    end
  end

  def down

    MetaModel.all.each do |mm|
      kind = mm.default_surrogate_kind
      if NEW_KINDS.include?(kind)
        mm.update_column(:default_surrogate_kind, "#{kind[4..-1]}")
      end
    end

    Surrogate.all.each do |surr|
      kind = surr.kind
      if NEW_KINDS.include?(kind)
        surr.update_column(:kind, "#{kind[4..-1]}")
      end
    end
  end

end
