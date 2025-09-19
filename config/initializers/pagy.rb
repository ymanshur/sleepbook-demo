
Pagy::DEFAULT[:limit] = 25 # items per page
Pagy::DEFAULT[:count_args] = :id

require "pagy/extras/metadata"
require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page
