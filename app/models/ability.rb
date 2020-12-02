class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
      @user = user || User.new # guest user (not logged in)

      if user
        user.admin? ? admin : auth_user
      else
        guest
      end
  end

  def guest; end

  def auth_user
    can :read, Payplan

    can [:read, :edit, :destroy], Payment, {user_id: user.id}

    can [:create], Invoice
    can [:read, :edit, :destroy], Invoice, payments: {user_id: user.id}
  end

  def admin
    can :manage, :all
  end
end
