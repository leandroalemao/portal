require 'win32ole'

class TicketsController < ApplicationController

  before_filter :authenticate_user!#, except: [:index, :show]

  load_and_authorize_resource :except => [:index]

  # GET /tickets
  # GET /tickets.json
  def index

       if can? :manage, Ticket
           @tickets = Ticket.all
       else  
           @tickets = Ticket.find(:all, :conditions => {:user_id => current_user})
       end

    #@tickets = Ticket.find(:all, :conditions => {:user_id => current_user})

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: TicketsDatatable.new(view_context) }
    end
  end

  # GET /tickets/1
  # GET /tickets/1.json
  def show
      @ticket = Ticket.find(params[:id])
      respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @ticket }
      end
  end

  # GET /tickets/new
  # GET /tickets/new.json
  def new
    @ticket = Ticket.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ticket }
    end
  end

  # GET /tickets/1/edit
  def edit
     @ticket = Ticket.find(params[:id])
  end

  # POST /tickets
  # POST /tickets.json
  def create
    @ticket = Ticket.new(params[:ticket])
    @ticket = current_user.tickets.build(params[:ticket])

    respond_to do |format|
      if @ticket.save
        format.html { redirect_to @ticket, notice: 'Ticket criado com sucesso!' }
        format.json { render json: @ticket, status: :created, location: @ticket }
        create_confirmation(@ticket)
      else
        format.html { render action: "new" }
        format.json { render json: @ticket.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /tickets/1
  # PUT /tickets/1.json
  def update
    @ticket = Ticket.find(params[:id])
      respond_to do |format|
        if @ticket.update_attributes(params[:ticket])
          format.html { redirect_to @ticket, notice: 'Ticket atualizado com sucesso!' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @ticket.errors, status: :unprocessable_entity }
        end
      end
  end

  # DELETE /tickets/1
  # DELETE /tickets/1.json
  def destroy
    @ticket = Ticket.find(params[:id])
    @ticket.destroy
      respond_to do |format|
        format.html { redirect_to tickets_url, notice: 'Ticket deletado com sucesso!' }
        format.json { head :no_content }
      end
  end


  def create_confirmation(ticket)

    WIN32OLE.ole_initialize
    @outlook = WIN32OLE.new('Outlook.Application')

    email = @outlook.CreateItem(0)
    email.Subject = 'Novo Ticket Aberto: '+ticket.id.to_s
    email.HTMLBody = '<FONT face="Arial" SIZE=3>Novo Ticket Aberto</font><BR>'

    email.HTMLBody += '<TABLE><CAPTION>'
    email.HTMLBody += '<FONT face="Arial" color=red SIZE=2>Dados do Ticket</font></CAPTION>'
    email.HTMLBody += '<TD valign="top"><TABLE BORDER=1 bordercolor=black cellspacing="0" cellpadding="1%">'
   
    email.HTMLBody += '<TR><TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Nome</font>'
    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Responsavel</font>'
    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Descricao</font>' 
    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Criado Por</font>' 
    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Data de Criacao</font></TR>' 

    email.HTMLBody += '<TR><TD ALIGN=CENTER><FONT face="Arial" SIZE=2>'+ticket.nome+'</font>'
    email.HTMLBody += '<TD ALIGN=CENTER><FONT face="Arial" SIZE=2>'+ticket.responsavel+'</font>'
    email.HTMLBody += '<TD ALIGN=CENTER><FONT face="Arial" SIZE=2>'+ticket.descricao+'</font>'
    email.HTMLBody += '<TD ALIGN=CENTER><FONT face="Arial" SIZE=2>'+ticket.user.name+'</font>'
    email.HTMLBody += '<TD ALIGN=CENTER><FONT face="Arial" SIZE=2>'+ticket.created_at.strftime("%d/%m/%Y %H:%M:%S")+'</font></TR>'

    email.HTMLBody += '</FONT></TABLE></TD>'
    email.HTMLBody += '</TR></TABLE><BR>'

    email.To = ticket.user.email
    #email.SenderEmailAddress = 'leandro.costantini1@claro.com.br'
    email.Save
    email.Send
    WIN32OLE.ole_uninitialize

  end

end