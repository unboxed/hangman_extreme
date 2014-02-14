require 'cancan'
class Ability
  include CanCan::Ability

  def initialize(user)
    can [:read,:play_letter,:show_clue,:reveal_clue], Game, user_id: user.id

    can :read, Winner
    can :read, User

    can :update, user

    can :read, Feedback, user_id: user.id

    unless user.guest?
      can :create, Game
      can :create, Feedback
    end
  end
end
