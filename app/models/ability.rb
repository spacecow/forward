class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :create, Locale
      can [:index,:create,:delete], Translation
    end
  end
end
