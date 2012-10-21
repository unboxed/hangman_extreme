class Ability
  include CanCan::Ability

  def initialize(user)
    can :create, Game
    can [:read,:play_letter], Game, user_id: user.id

    can :read, User
    can :update, user

    can :read, Winner

    can :create, PurchaseTransaction
    can :read, PurchaseTransaction, user_id: user.id

    can :create, RedeemWinning
    can :read, RedeemWinning, user_id: user.id
  end
end
