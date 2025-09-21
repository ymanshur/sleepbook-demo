
Pagy::DEFAULT[:count_args] = :id

require "pagy/extras/limit"
Pagy::DEFAULT[:limit_max] = ENV.fetch("DEFAULT_SCOPE_LIMIT", 25).to_i

require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page

require "pagy/extras/metadata"
