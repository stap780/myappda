require 'active_record/connection_adapters/postgresql/schema_dumper'

# This patch prevents `create_schema` from being added to db/schema.rb as schemas are managed by Apartment
# not ActiveRecord like they would be in a vanilla Rails setup.
class ActiveRecord::ConnectionAdapters::PostgreSQL::SchemaDumper
  def schemas(stream); end
end