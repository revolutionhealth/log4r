#Monkey Patch to not allow usage of VERSION in migration since log4r returns nil instead of true
module ActiveRecord
  class Migrator
    
  def migrate
    migration_classes.each do |(version, migration_class)|
      if reached_target_version?(version)
        Base.logger.info("Reached target version: #{@target_version}")
        return
      end
      next if irrelevant_migration?(version)

      Base.logger.info "Migrating to #{migration_class} (#{version})"
      migration_class.migrate(@direction)
      set_schema_version(version)
    end
  end
    
  end
end
