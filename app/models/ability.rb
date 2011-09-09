class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      if user.role? :god
        can :manage, :all
      else
        if user.role? :admin
          can [:create], Locale
          can [:index,:create,:delete], Translation
          can :manage, Filter
          can :manage, Message
        elsif user.role? :member
          can [:index,:new,:create], Filter
          can [:edit,:update,:show,:destroy], Filter, :user_id => user.id
          can [:new,:create], Message
        end
      end
    end
  end
end
