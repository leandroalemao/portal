class Ability
  include CanCan::Ability

  def initialize(user)
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end

            user ||= User.new
 
                   if user.role == "admin" 
                        can :manage, :all
                    elsif user.role == "moderator"
                          can :update, Mailing
                          can :read, Mailing
                          can :destroy, Mailing
                          can :deliver, Mailing.where("status = 1")
                          can :finalize, Mailing.where("status = 2")
                          can :create, Mailing
                          can :new, Mailing
                    elsif user.role == "common"
                          can :update, Mailing.where("user_id = :user and rlowner_id is null", user: user)
                          can :read, Mailing.where("user_id = :user or rlowner_id = :user", user: user)
                          can :destroy, Mailing.where("user_id = :user and rlowner_id is null", user: user)
                          can :deliver, Mailing.where("rlowner_id = :user and status = 1", user: user)
                          can :finalize, Mailing.where("user_id = :user and status = 2", user: user)
                          can :create, Mailing
                          can :new, Mailing
                    end

    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end

end
