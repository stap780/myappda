require_relative 'apartment/active_record/schema_migration'
require_relative 'apartment/active_record/internal_metadata'

if ActiveRecord.version.release >= Gem::Version.new('7.1')
  require_relative 'apartment/active_record/postgres/schema_dumper'
end