# frozen_string_literal: true

json.array! @variables, partial: "variables/variable", as: :variable
