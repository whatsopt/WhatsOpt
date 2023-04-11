# frozen_string_literal: true

module PackagesHelper
  
    def link_to_package_if_authorized(pkg, user)
      if policy(pkg.analysis).show?
        link_to pkg.filename, pkg.archive
      else
        pkg.filename
      end
    end

end  