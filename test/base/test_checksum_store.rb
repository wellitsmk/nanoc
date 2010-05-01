# encoding: utf-8

require 'test/helper'

class Nanoc3::ChecksumStoreTest < MiniTest::Unit::TestCase

  include Nanoc3::TestHelpers

  def test_get_with_existing_object
    require 'pstore'

    # Create store
    FileUtils.mkdir_p('tmp')
    pstore = PStore.new('tmp/checksums')
    pstore.transaction do
      pstore[:checksums] = { [ :item, '/moo/' ] => 'zomg' }
    end

    # Check
    store = Nanoc3::ChecksumStore.new
    obj = Nanoc3::Item.new('Moo?', {}, '/moo/')
    assert_equal 'zomg', store.old_checksum_for(obj)
  end

  def test_get_with_nonexistant_object
    store = Nanoc3::ChecksumStore.new

    # Check
    obj = Nanoc3::Item.new('Moo?', {}, '/animals/cow/')
    new_checksum = Nanoc3::Checksummer.checksum_for_string('Moo?') + '-' +
      Nanoc3::Checksummer.checksum_for_hash({})
    assert_equal nil,          store.old_checksum_for(obj)
    assert_equal new_checksum, store.new_checksum_for(obj)
  end

  def test_store
    store = Nanoc3::ChecksumStore.new

    obj = Nanoc3::Item.new('Moo?', {}, '/animals/cow/')
    new_checksum = Nanoc3::Checksummer.checksum_for_string('Moo?') + '-' +
      Nanoc3::Checksummer.checksum_for_hash({})

    store.store
    store = Nanoc3::ChecksumStore.new

    assert_equal nil,          store.old_checksum_for(obj)
    assert_equal new_checksum, store.new_checksum_for(obj)

    store.calculate_checksums_for([ obj ])
    store.store
    store = Nanoc3::ChecksumStore.new

    assert_equal new_checksum, store.old_checksum_for(obj)
    assert_equal new_checksum, store.new_checksum_for(obj)
  end

end