class TicketsDatatable
  delegate :params, :tickets, :current_user, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: tickets.count,
      iTotalDisplayRecords: tickets.count,
      aaData: data
    }
  end

private

  def data
    tickets.map do |ticket|
      [
        link_to(ticket.id, ticket),
        h(ticket.nome),
        h(ticket.responsavel),
        h(ticket.descricao),
        h(ticket.created_at.strftime("%d/%m/%Y %H:%M:%S")),
        h(ticket.updated_at.strftime("%d/%m/%Y %H:%M:%S")),
        h(ticket.user.try(:name)),
      ]
    end
  end

  def tickets

    @tickets ||= fetch_tickets
  end

  def fetch_tickets
    
    if current_user.role == "admin"
      tickets = Ticket.order("#{sort_column} #{sort_direction}")
    else
      tickets = Ticket.where("user_id = :user", user: current_user).order("#{sort_column} #{sort_direction}")
    end
    tickets = tickets.page(page).per_page(per_page)

    if params[:sSearch].present?
       if current_user.role == "admin"
          tickets = Ticket.where("nome like :search", search: "%#{params[:sSearch]}%").order("#{sort_column} #{sort_direction}")
       else
          tickets = Ticket.where("user_id = :user and nome like :search", user: current_user, search: "%#{params[:sSearch]}%").order("#{sort_column} #{sort_direction}")
       end
    end
    tickets
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[id nome responsavel descricao created_at updated_at user_id]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end