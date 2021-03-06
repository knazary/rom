require 'spec_helper'

RSpec.describe ROM::Relation::Curried do
  include_context 'gateway only'
  include_context 'users and tasks'

  let(:users_relation) do
    Class.new(ROM::Memory::Relation) do
      def by_name(name)
        restrict(name: name)
      end

      def find(criteria)
        restrict(criteria)
      end
    end.new(users_dataset)
  end

  describe '#call' do
    let(:relation) { users_relation.by_name.call('Jane') }

    it 'materializes a relation' do
      expect(relation).to match_array([
        name: 'Jane', email: 'jane@doe.org'
      ])
    end

    it 'returns a loaded relation' do
      expect(relation.source).to eql(users_relation.by_name('Jane'))
    end
  end

  describe '#respond_to?' do
    it 'returns true if wrapped relation responds to a method' do
      expect(users_relation.by_name).to respond_to(:dataset)
    end

    it 'returns false if wrapped relation does not respond to a method' do
      expect(users_relation.by_name).not_to respond_to(:not_here)
    end
  end

  describe '#method_missing' do
    it 'forwards to the relation' do
      expect(users_relation.by_name.dataset).to eql(users_relation.dataset)
    end

    it 'does not forward to the relation when method is auto-curried' do
      expect { users_relation.by_name.find }.to raise_error(NoMethodError, /find/)
    end
  end
end
