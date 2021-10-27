module UserManagement
  module UserCreator
    class << self
      def call(params)
        Effects::Process.new([:validate_user_data, :create_user]) do |y|
          User.transaction do
            validated_data = sanitize_parameters(params)
            y.yield(:validate_user_data, validated_data)
            user = User.new(validated_data)
            user.save!
            y.yield(:create_user, user.id)
            user.id
          end
        end
      end

      def create(params, before_save: nil, after_save: nil)
        User.transaction do
          validated_data = sanitize_parameters(params)
          before_save.call(validated_data) if before_save
          user = User.new(validated_data)
          user.save!
          after_save.call(user.id) if after_save
          user.id
        end
      end
    end
  end
end

module SomeComponent
  class FancyUsersController
    def create
      additional_data = nil
      UserManagement::UserCreator.create(
        user_params,
        before_save: -> (processed_user_data) do
          additional_data = build_permissions(processed_user_data.role)
        end,
        after_save: -> (user_id) do
          FancyUserAssociatedRecord.create(user_id, additional_data)
        end)
    end

    def create
      user_id = UserManagement::UserCreator.create(user_params)
      FancyUserAssociatedRecord.create(user_id)
    end

    def create
      creator = UserManagement::UserCreator.call(user_params)
      processed_user_data = creator.(:validate_user_data)
      additional_data = build_permissions(processed_user_data.role)
      user_id = creator.(:create_user)
      FancyUserAssociatedRecord.create(user_id, additional_data)
      creator.finish
    end

    def create
      UserManagement::UserCreator.call(user_params) do |process|
        validated_user_data = process.(:validate_user_data)
        additional_data = build_permissions(validated_user_data.role)
        user_id = process.(:create_user)
        FancyUserAssociatedRecord.create(user_id, additional_data)
      end
    end

    def create
      UserManagement::UserCreator.(user_params).(:validate_user_data) do |processed_user_data, creator|
        additional_data = build_permissions(processed_user_data.role)
        user_id = creator.(:create_user)
        FancyUserAssociatedRecord.create(user_id, additional_data)
      end
    end

    def create
      lazy_user_id = UserManagement::UserCreator.call(user_params)
      FancyUserAssociatedRecord.create(lazy_user_id.call)
    end
  end
end
