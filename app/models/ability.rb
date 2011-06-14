class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can [:create,:update], Locale
      can [:index,:create,:delete], Translation
    end
  end
end
