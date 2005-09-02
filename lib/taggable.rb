# found at http://dema.ruby.com.br/files/taggable.rb
module ActiveRecord
  module Acts #:nodoc:
    module Taggable #:nodoc:
      
      def self.append_features(base)
        super
        base.extend(ClassMethods)
      end
      
      # This mixin provides an easy way to tag active record objects.
      # It assumes you have a defined a model to represent +tags+ with a +name+ column.
      # Tag names will be stored in the proper tags table, as where tagging objects
      # is perfomed by using +has_and_belong_to_many+ join tables between the tags table
      # and the target object table.
      #
      # The +acts_as_taggable+ adds the method 'tag' to the class and this 
      # method holds the logic for proper tagging the instances of the class, avoiding
      # tagging duplication and using a many-to-many relationship.
      #
      # Example:
      # 
      #   class Photo < ActiveRecord::Base
      #     # this creates a 'tags' has_and_belongs_to_many relationship using the
      #     # join table 'tags_photo'.
      #     acts_as_taggable 
      #   end
      #
      #   photo = Photo.new
      #   # splits and adds to the tags collection
      #   photo.tag("wine beer alcohol") 
      #
      #   # don't need to split since it's an array, but adds to the tags collection
      #   # withough duplicating wine
      #   photo.tag( %w( wine vodka ), :clear => false ) 
      #
      #   photo.tags.size # => 4
      module ClassMethods
        
        # This method defines a +has_and_belongs_to_many+ relationship between
        # the target class and the tag model class. It also adds instance method
        # +tag+ to the class.
        #
        # The options are:
        # The +:collection+ parameter receives a symbol defining
        # the name of the tag collection method and it defaults to +:tags+.
        # The +:tag_class_name+ parameter receives the tag model class name and
        # it defaults to +'Tag'+.
        # The remaining options are passed on to the +has_and_belongs_to_many+ declaration.
        # The +:join_table+ parameter is defined by default using the form
        # of +[tags_table_name]_[target_class_table_name]+, example: +tags_photos+, 
        # which differs from the standard +has_and_belongs_to_many+ behavior.
        def acts_as_taggable(options = {})

          options = { :collection => :tags, :tag_class_name => 'Tag' }.merge(options)
          tag_model = options[:tag_class_name].constantize
          collection_name = options[:collection]
          options[:join_table] ||= "#{tag_model.table_name}_#{self.table_name}"
          [ :collection, :tag_class_name ].each { |key| options.delete(key) } # remove these, we don't need it anymore
          
          class_eval do
            include ActiveRecord::Acts::Taggable::InstanceMethods
            has_and_belongs_to_many collection_name, options
            
            define_method(:tag_collection_name) { collection_name }
            define_method(:tag_model) { tag_model }
          end
          
        end
      end
      
      module InstanceMethods

        # This method applies tags to the target object, by parsing the tags parameter
        # into Tag instances and adding them to the tag collection of the object.
        # If the tag name already exists in the tags table, it just adds a relationship
        # to the existing tag record. If it doesn't exist, it then creates a new
        # Tag record for it. 
        #
        # The +tags+ parameter can be a +String+ or a +Array+. If it's a +String+, it's
        # splitted using the :separator specified in the +options+ hash. 
        # If it's an +Array+ it is flattened and compacted. Duplicate
        # entries will be removed as well. Tag names are also stripped of trailing 
        # and leading whitespaces.
        # The +options+ hash has the following parameters:
        # +:separator+ => defines the separator used to split the tags parameter, 
        # if it's a +String+, and defaults to ' ' (space and line breaks).
        # +:clear+ => defines whether the existing tag collection will be cleared before
        # applying the +tags+ passed. Defaults to +true+.
        def tag(tags, options = {})
      
          options = { :separator => ' ', :clear => true }.merge(options)
      
          # parse the tags parameter
          tag_names = []
          if tags.is_a?(Array)
            tag_names << tags 
          elsif tags.is_a?(String)
            tag_names << tags.split(options[:separator])
          end
          tag_names = tag_names.flatten.uniq.compact #straight 'em up
          
          # clear the collection if appropriate
          tag_collection.clear if options[:clear]
      
          # append the tag names to the collection
          tag_names.each do |name| 
            # ensure that tag names don't get duplicated
            tag_name = name.strip
            tag_record = tag_model.find_by_name(tag_name) || tag_model.new(:name => tag_name)
            tag_collection << tag_record unless tagged_by?(tag_name)
          end
          
        end
        
        # Returns an array of strings containing the tags applied to this object.
        def tag_names
          tag_collection.map { |rec| rec.name }
        end
        
        # Checks to see if this object has been tagged with +tag_name+.
        def tagged_by?(tag_name)
          tag_names.include?(tag_name)
        end
        
        private
        def tag_collection() send(tag_collection_name) end        
          
      end
      
    end
  end
end

ActiveRecord::Base.class_eval do
  include ActiveRecord::Acts::Taggable
end
