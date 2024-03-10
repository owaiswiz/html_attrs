# frozen_string_literal: true

require 'test_helper'

class TestHtmlAttrs < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::HtmlAttrs::VERSION
  end

  def test_smart_merge
    hash_a = {
      class: 'a b',
      style: 'color: red;',
      data: { a: 1, b: 2, d: 'x y', e: 'z', deep: { a: 'aa' } },
      id: 'test',
      unmergeable: { x: '1', y: 2, z: {} }
    }

    hash_b = {
      class: 'c d',
      style: 'color: blue;',
      data: { b: 3, c: 4, d: 'e', f: 'zz', deep: { x: 'a', a: 'b' } },
      id: 'test2',
      unmergeable: { x: '2', y: 3, z: false },
      z: { a: 1, b: {} }
    }

    result = HtmlAttrs.smart_merge(hash_a, hash_b)

    expected = {
      class: 'a b c d', style: 'color: red; color: blue;',
      data: { a: 1, b: 3, d: 'x y e', e: 'z', deep: { a: 'aa b', x: 'a' }, c: 4, f: 'zz' },
      id: 'test2',
      unmergeable: { x: '2', y: 3, z: false },
      z: { a: 1, b: {} }
    }.with_indifferent_access

    assert_equal expected, result
  end

  def test_smart_merge_with_custom_mergeable_attributes
    hash_a = {
      class: 'a b',
      style: 'color: red;',
      data: { a: 1, b: 2, d: 'x y', e: 'z', deep: { a: 'aa' } },
      id: 'test',
      unmergeable: { x: '1', y: 2, z: {} }
    }

    hash_b = {
      class: 'c d',
      style: 'color: blue;',
      data: { b: 3, c: 4, d: 'e', f: 'zz', deep: { x: 'a', a: 'b' } },
      id: 'test2',
      unmergeable: { x: '2', y: 3, z: { a: 3 } },
      z: { a: 1, b: {} }
    }

    result = HtmlAttrs.smart_merge(hash_a, hash_b, mergeable_attributes: %i[id unmergeable])

    expected = {
      class: 'c d',
      style: 'color: blue;',
      data: { b: 3, c: 4, d: 'e', f: 'zz', deep: { x: 'a', a: 'b' } },
      id: 'test test2',
      unmergeable: { x: '1 2', y: 3, z: { a: 3 } },
      z: { a: 1, b: {} }
    }.with_indifferent_access

    assert_equal expected, result
  end

  def test_smart_merge_when_nil
    result = HtmlAttrs.smart_merge(nil, nil)
    assert_nil result, nil

    result = HtmlAttrs.smart_merge({ class: 'test' }, nil)
    expected = { class: 'test' }.with_indifferent_access
    assert_equal expected, result

    result = HtmlAttrs.smart_merge(nil, { class: 'test' })
    expected = { class: 'test' }.with_indifferent_access
    assert_equal expected, result

    result = HtmlAttrs.smart_merge({ id: 'test2' }, { class: 'test' })
    expected = { id: 'test2', class: 'test' }.with_indifferent_access
    assert_equal expected, result

    result = HtmlAttrs.smart_merge({ class: 'test3', id: 'test2' }, { class: 'test' })
    expected = { class: 'test3 test', id: 'test2' }.with_indifferent_access
    assert_equal expected, result
  end

  def test_smart_merge_through_html_attrs_instance
    hash_a = {
      class: 'a b',
      style: 'color: red;',
      data: { a: 1, b: 2, d: 'x y', e: 'z', deep: { a: 'aa' } },
      id: 'test',
      unmergeable: { x: '1', y: 2, z: {} }
    }

    hash_b = {
      class: 'c d',
      style: 'color: blue;',
      data: { b: 3, c: 4, d: 'e', f: 'zz', deep: { x: 'a', a: 'b' } },
      id: 'test2',
      unmergeable: { x: '2', y: 3, z: false },
      z: { a: 1, b: {} }
    }

    result = HtmlAttrs.new(hash_a).smart_merge(hash_b)

    expected = {
      class: 'a b c d', style: 'color: red; color: blue;',
      data: { a: 1, b: 3, d: 'x y e', e: 'z', deep: { a: 'aa b', x: 'a' }, c: 4, f: 'zz' },
      id: 'test2',
      unmergeable: { x: '2', y: 3, z: false },
      z: { a: 1, b: {} }
    }.with_indifferent_access

    assert result.is_a?(HtmlAttrs)
    assert_equal expected, result

    result = HtmlAttrs.new(hash_a).smart_merge(nil)
    assert result.is_a?(HtmlAttrs)
    assert_equal hash_a.with_indifferent_access, result

    result = HtmlAttrs.new(nil).smart_merge(hash_b)
    assert result.is_a?(HtmlAttrs)
    assert_equal hash_b.with_indifferent_access, result
  end

  def test_passing_kwargs
    result = HtmlAttrs.new(class: 'test', data: 'a', x: 3).smart_merge(class: 'test2', id: 'd3', x: 4)
    expected = { class: 'test test2', data: 'a', x: 4, id: 'd3' }.with_indifferent_access
    assert_equal expected, result
  end

  def test_to_s
    attrs = HtmlAttrs.new({ class: 'bg-primary-500', data: { controller: 'popover' } })
    result = attrs.smart_merge(class: 'text-white', data: { controller: 'tooltip', title: 'test' }).to_s
    assert_equal 'class="bg-primary-500 text-white" data-controller="popover tooltip" data-title="test"', result
  end
end
