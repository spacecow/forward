class Ability
  include CanCan::Ability

  def initialize(user)
    can :create, Locale
  end
end
