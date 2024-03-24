# frozen_string_literal: true

require 'action_view'

class HtmlAttrs < Hash
  VERSION = '1.1.0'
  DEFAULT_MERGEABLE_ATTRIBUTES = %i[class style data].to_set

  def initialize(constructor = nil)
    if constructor.respond_to?(:to_hash)
      super()
      update(constructor)

      hash = constructor.is_a?(Hash) ? constructor : constructor.to_hash
      self.default = hash.default if hash.default
      self.default_proc = hash.default_proc if hash.default_proc
    elsif constructor.nil?
      super()
    else
      super(constructor)
    end
  end

  def smart_merge(target)
    if target.is_a?(Hash) && target.key?(:mergeable_attributes)
      mergeable_attributes = target.delete(:mergeable_attributes)
    end
    mergeable_attributes ||= DEFAULT_MERGEABLE_ATTRIBUTES
    self.class.smart_merge(self, target, mergeable_attributes: mergeable_attributes)
  end

  def smart_merge_all(target)
    target[:mergeable_attributes] = :all if target.is_a?(Hash)
    smart_merge(target)
  end

  def to_s
    self.class.attributes(self)
  end

  def self.smart_merge(other, target, mergeable_attributes: DEFAULT_MERGEABLE_ATTRIBUTES)
    return other if target.nil?
    return target if other.nil?

    if target.is_a?(Hash) || other.is_a?(Hash)
      raise 'Expected target to be a hash or nil' unless target.is_a?(Hash)
      raise 'Expected other to be a hash or nil' unless other.is_a?(Hash)

      other = other.dup
      target = target.dup

      target.each do |key, value|
        other_type_of_key = key.is_a?(Symbol) ? key.to_s : key.to_sym

        key_with_value = if other.key?(key)
                           key
                         elsif other.key?(other_type_of_key)
                           other_type_of_key
                         else
                           nil
                         end

        other[key_with_value || key] =
          if key_with_value && attribute_mergeable?(key, mergeable_attributes)
            smart_merge(other[key_with_value], value, mergeable_attributes: :all)
          else
            value
          end
      end

      return other
    end

    if target.is_a?(Array) || other.is_a?(Array)
      raise 'Expected target to be an array or nil' unless target.is_a?(Array)
      raise 'Expected other to be an array or nil' unless other.is_a?(Array)

      return (other.dup || []).concat(target.dup || [])
    end

    if target.is_a?(String) || other.is_a?(String)
      raise 'Expected target to be a string or nil' unless target.is_a?(String)
      raise 'Expected other to be a string or nil' unless other.is_a?(String)

      return [other.presence, target.presence].compact.join(' ')
    end

    target
  end

  def self.smart_merge_all(other, target)
    smart_merge(other, target, mergeable_attributes: :all)
  end

  def self.attribute_mergeable?(attribute, mergeable_attributes)
    return true if mergeable_attributes == :all

    mergeable_attributes.include?(attribute.to_sym)
  end

  def self.attributes(hash)
    tag_helper.tag_options(hash).to_s.strip.html_safe
  end

  def self.tag_helper
    @tag_helper ||= ActionView::Helpers::TagBuilder.new(nil)
  end
end

class Hash
  def as_html_attrs
    HtmlAttrs.new(self)
  end

  def smart_merge(target)
    as_html_attrs.smart_merge(target)
  end

  def smart_merge_all(target)
    as_html_attrs.smart_merge_all(target)
  end
end
