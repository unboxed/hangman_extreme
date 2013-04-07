class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :create, Game
      can [:read,:play_letter,:show_clue,:reveal_clue], Game, user_id: user.id

      can :read, User
      can :update, user

      can :read, Winner

      can :create, PurchaseTransaction
      can :read, PurchaseTransaction, user_id: user.id

      can :create, RedeemWinning
      can :read, RedeemWinning, user_id: user.id

      can :read, AirtimeVoucher, user_id: user.id
    end
  end
end
