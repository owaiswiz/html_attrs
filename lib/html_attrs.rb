# frozen_string_literal: true

require 'action_view'
require 'active_support/core_ext/hash/indifferent_access'

class HtmlAttrs < HashWithIndifferentAccess
  VERSION = '0.1.0'
  DEFAULT_MERGEABLE_ATTRIBUTES = %i[class style data].to_set

  def smart_merge(other)
    mergeable_attributes = other.delete(:mergeable_attributes) if other.is_a?(Hash) && other.key?(:mergeable_attributes)
    mergeable_attributes ||= DEFAULT_MERGEABLE_ATTRIBUTES
    self.class.smart_merge(self, other, mergeable_attributes: mergeable_attributes)
  end

  def to_s
    self.class.attributes(self)
  end

  def self.smart_merge(other, target, mergeable_attributes: DEFAULT_MERGEABLE_ATTRIBUTES)
    other  = other.with_indifferent_access if other.is_a?(Hash) && !other.is_a?(HashWithIndifferentAccess)
    target = target.with_indifferent_access if target.is_a?(Hash) && !target.is_a?(HashWithIndifferentAccess)

    return other if target.nil?
    return target if other.nil?

    if target.is_a?(Hash) || other.is_a?(Hash)
      raise 'Expected target to be a hash or nil' if !target.nil? && !target.is_a?(Hash)
      raise 'Expected other to be a hash or nil' if !other.nil? && !other.is_a?(Hash)

      target.each do |key, value|
        other[key] =
          if other.key?(key) && attribute_mergeable?(key, mergeable_attributes)
            smart_merge(other[key], value, mergeable_attributes: :all)
          else
            value
          end
      end
      return other
    end

    if target.is_a?(Array) || other.is_a?(Array)
      raise 'Expected target to be an array or nil' if !target.nil? && !target.is_a?(Array)
      raise 'Expected other to be an array or nil' if !other.nil? && !other.is_a?(Array)

      return (other || []).concat(target || [])
    end

    if target.is_a?(String) || other.is_a?(String)
      raise 'Expected target to be a string or nil' if !target.nil? && !target.is_a?(String)
      raise 'Expected other to be a string or nil' if !other.nil? && !other.is_a?(String)

      return [other.presence, target.presence].compact.join(' ')
    end

    target
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
end
