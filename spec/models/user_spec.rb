# frozen_string_literal: true
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create :user }

  context 'validations' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end
    it 'is invalid without a first_name' do
      expect(build(:user, first_name: nil)).not_to be_valid
    end
    it 'is invalid without a last_name' do
      expect(build(:user, last_name: nil)).not_to be_valid
    end
    it 'is invalid without an email' do
      expect(build(:user, email: nil)).not_to be_valid
    end
    it 'is invalid without a phone' do
      expect(build(:user, phone: nil)).not_to be_valid
    end
    it 'is invalid without a spire_id' do
      expect(build(:user, spire_id: nil)).not_to be_valid
    end
    it 'does not allow duplicate spire_ids' do
      user = create(:user)
      expect(build(:user, spire_id: user.spire_id)).not_to be_valid
    end

    it 'requires spire id to be length 8' do
      expect(build(:user, spire_id: '1234567')).not_to be_valid
    end
  end

  context 'helper methods' do
    it 'builds a tag' do
      expect(user.tag).to include user.spire_id, user.full_name
    end

    describe '#full_name' do
      it 'returns first name and last name with a space in between' do
        expect(user.full_name).to eql "#{user.first_name} #{user.last_name}"
      end
    end
  end

  describe '#has_permission?' do
    it 'returns true if the user has a permission with the requested controller, action, and no id_field' do
      group = create(:group)
      permission = create(:permission, controller: 'user', action: 'show', id_field: nil)

      group.permissions << permission
      user.groups << group

      expect(user).to have_permission permission.controller,
                                      permission.action,
                                      nil
    end

    it 'returns true if the user has a permission with the requested controller, action, and an id_field,
                        and their id matches the id of the requested instance' do
      group = create(:group)
      permission = create(:permission, controller: 'user', action: 'show', id_field: 'id')

      group.permissions << permission
      user.groups << group

      expect(user).to have_permission permission.controller,
                                      permission.action,
                                      user.id
    end

    it 'returns false if the user does not have a permission with the requested controller, action' do
      group = create(:group)
      permission = create(:permission, controller: 'user', action: 'show', id_field: nil)

      user.groups << group

      expect(user).not_to have_permission permission.controller,
                                          permission.action,
                                          nil
    end

    it 'returns false if the user has a permission with the requested controller, action, and an id_field,
                        and their id matches the id of the requested instance but the user is inactive' do
      user.active = false
      user.save!
      group = create(:group)
      permission = create(:permission, controller: 'user', action: 'show', id_field: 'id')

      group.permissions << permission
      user.groups << group

      expect(user).not_to have_permission permission.controller,
                                          permission.action,
                                          user.id
    end

    it 'returns false if the user has a permission with the requested controller, action and an id_field,
                         and their id does not match the id of the requested instance' do
      user2 = create(:user)
      group = create(:group)
      permission = create(:permission, controller: 'user', action: 'show', id_field: 'id')

      group.permissions << permission
      user.groups << group

      expect(user).not_to have_permission permission.controller,
                                          permission.action,
                                          user2.id
    end
  end

  describe '#has_group?' do
    it 'returns true if the user has the requested group' do
      group = create(:group)

      user.groups << group

      expect(user).to have_group group
    end

    it 'returns false if the user does not have the requested group' do
      group = create(:group)

      expect(user).not_to have_group group
    end
  end
end
