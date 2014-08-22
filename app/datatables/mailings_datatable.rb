class MailingsDatatable
  delegate :params, :mailings, :current_user, :h, :image_tag, :alt, :truncate, :link_to, :number_to_currency, to: :@view
  attr_reader :size

  def initialize(view,statusvisual)
    @view = view
    @statusnovo = statusvisual.to_i
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: mailings.count,
      iTotalDisplayRecords: mailings.count,
      aaData: data
    }
  end

private

  def data
      mailings.map do |mailing|
      [
        link_to(mailing.id, mailing),
        h(mailing.typemailing),
        h(mailing.approach),
        truncate(h(mailing.objective), :length => 50,  :separator => ' '),
        truncate(h(mailing.description), :length => 50,  :separator => ' '),
        h(mailing.created_at),
        h(mailing.updated_at),
        h(mailing.user.try(:name)),
        User.find(:all, :select => 'name', :conditions => {:id => mailing.rlowner_id}).uniq.map {|a| a[:name]},
        case mailing.try(:status) 
             when 0 then 'Novo' #image_tag('new.png', :alt => 'Novo')
             when 1 then 'Demandado'
             when 2 then 'Entregue'
             when 3 then 'Finalizado' #image_tag('ok.png', :alt => 'Finalizado')
        end
      ]
     end
  end

  def mailings

    @mailings ||= fetch_mailings
  end

  def fetch_mailings
    
    if current_user.role == "admin" || current_user.role == "moderator"
      mailings = Mailing.where("status = :statusvisual", statusvisual: @statusnovo).order("#{sort_column} #{sort_direction}").includes(:user)
    else
      mailings = Mailing.where("status = :statusvisual and (user_id = :user or rlowner_id = :user)", statusvisual: @statusnovo, user: current_user).order("#{sort_column} #{sort_direction}").includes(:user)
    end
    mailings = mailings.page(page).per_page(per_page)

    if params[:sSearch].present?
       if current_user.role == "admin" || current_user.role == "moderator"
          mailings = Mailing.joins("JOIN users a ON (mailings.rlowner_id = a.id or mailings.user_id = a.id)").where("status = :statusvisual and (mailings.id like :search or mailings.typemailing like :search or mailings.approach like :search or mailings.objective like :search or mailings.description like :search or a.name like :search)", statusvisual: @statusnovo, search: "%#{params[:sSearch]}%").order("#{sort_column} #{sort_direction}")
       else
          mailings = Mailing.joins("JOIN users a ON (mailings.rlowner_id = a.id or mailings.user_id = a.id)").where("status = :statusvisual and (mailings.user_id = :user or mailings.rlowner_id = :user and (mailings.id like :search or mailings.typemailing like :search or mailings.approach like :search or mailings.objective like :search or mailings.description like :search or a.name like :search))", statusvisual: @statusnovo, user: current_user, search: "%#{params[:sSearch]}%").order("#{sort_column} #{sort_direction}")
       end
    end
    mailings
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[id typemailing approach objective description created_at updated_at user_id rlowner_id status]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end