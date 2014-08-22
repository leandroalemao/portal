# encoding: utf-8

require 'win32ole'

class MailingsController < ApplicationController

  before_filter :authenticate_user!#, except: [:index, :show]

  load_and_authorize_resource :except => [:index]

  # GET /mailings
  # GET /mailings.json
  def index

       if can? :manage, Mailing
           @mailings = Mailing.find(:all, :conditions => {:status => params[:statusvisual] })
       else  
           @mailings = Mailing.find(:all, :conditions => {:user_id => current_user, :status => params[:statusvisual] })
       end

       #Controle do StatusVisual
       if params[:statusvisual].to_i > 3
          params[:statusvisual] = 0
       end
       if params[:statusvisual].to_i < 0
          params[:statusvisual] = 0
       end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: MailingsDatatable.new(view_context,params[:statusvisual]) }
    end
  end

  # GET /mailings/1
  # GET /mailings/1.json
  def show
    @mailing = Mailing.find(params[:id])
    @comment = Comment.new

    respond_to do |format|
        format.html # show.html.erb
        format.json { render json: @mailing }
        format.pdf do        
            pdf = MailingPdf.new(@mailing, view_context)        
            send_data pdf.render, 
            type: "application/pdf", disposition: "inline"
        end      
    end
  end

  # GET /mailings/new
  # GET /mailings/new.json
  def new
    @mailing = Mailing.new
    @restriction = Restriction.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mailing }
    end
  end

  # GET /mailings/1/edit
  def edit
    @mailing = Mailing.find(params[:id])
  end

  # POST /mailings
  # POST /mailings.json
  def create
    @mailing = Mailing.new(params[:mailing])
    @mailing = current_user.mailings.build(params[:mailing])
    if !params[:mailing][:rlowner_id].blank?
      @mailing.status = 1
    else
      @mailing.status = 0
    end

    respond_to do |format|
      if @mailing.save
        format.html { redirect_to @mailing, notice: 'Mailing criado com sucesso!' }
        format.json { render json: @mailing, status: :created, location: @mailing }
        create_confirmation(@mailing)
      else
        format.html { render action: "new" }
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mailings/1
  # PUT /mailings/1.json
  def update
    @mailing = Mailing.find(params[:id])
    if !params[:mailing][:rlowner_id].blank?
        if @mailing.status == 0
            @mailing.status = 1
        end
    else
        @mailing.status = 0
    end
    respond_to do |format|
      if @mailing.update_attributes(params[:mailing])
        format.html { redirect_to @mailing, notice: 'Mailing atualizado com sucesso!' }
        format.json { head :no_content }
        edit_confirmation(@mailing)
      else
        format.html { render action: "edit" }
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /mailings/1
  # DELETE /mailings/1.json
  def destroy
    @mailing  = Mailing.find(params[:id])

    if !@mailing.comments.blank?
            @mailing.comments.each do |comments| 
              if comments.user_id == @mailing.user_id 
                    @mailing.destroy
                    redirect_to root_url, notice: 'Mailing deletado com sucesso!' 
              else 
                flash.now[:errors] = 'Você precisa adicionar um novo comentário antes de Excluir este Mailing!!!'
                @comment = Comment.new
              end
            end
    else
        flash.now[:errors] = 'Você precisa adicionar um novo comentário antes de Excluir este Mailing!!!'
        @comment = Comment.new
    end
  end

  def deliver
    @mailing = Mailing.find(params[:id])
    if !@mailing.status.blank?
        if @mailing.status == 1
            @mailing.status = 2
        end
    end
    respond_to do |format|
      if @mailing.update_attributes(params[:mailing])
        format.html { redirect_to @mailing, notice: 'Mailing entregue com sucesso!' }
        format.json { head :no_content }
        deliver_confirmation(@mailing)
      else
        format.html { render action: "show" }
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end

  def finalize
    @mailing = Mailing.find(params[:id])
    if !@mailing.status.blank?
        if @mailing.status == 2
            @mailing.status = 3
        end
    end
    respond_to do |format|
      if @mailing.update_attributes(params[:mailing])
        format.html { redirect_to @mailing, notice: 'Mailing concluído com sucesso!' }
        format.json { head :no_content }
        finalize_confirmation(@mailing)
      else
        format.html { render action: "show" }
        format.json { render json: @mailing.errors, status: :unprocessable_entity }
      end
    end
  end

  def create_confirmation(mailing)

    WIN32OLE.ole_initialize
    @outlook = WIN32OLE.new('Outlook.Application')

    email = @outlook.CreateItem(0)
    email.Subject = 'Novo Mailing Aberto: '+mailing.id.to_s
    email.HTMLBody = '<FONT face="Arial" SIZE=3>Novo Mailing Aberto</font><BR>'

    email.HTMLBody += '<TABLE><CAPTION>'
    email.HTMLBody += '<FONT face="Arial" color=red SIZE=2>Dados do Mailing</font></CAPTION>'
    email.HTMLBody += '<TD valign="top"><TABLE BORDER=1 bordercolor=black cellspacing="0" cellpadding="1%">'
   
    email.HTMLBody += '<TR><TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Demanda</font>'
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.typemailing+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Abordagem</font>'
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.approach+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Objetivo</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.objective+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Descrição</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.description+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Texto do SMS</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.sms+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Pasta Destino</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.folder+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Layout</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.layout+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Periodicidade</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.periodicity+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Restrições</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>' 
    @mailing.restrictions.each_with_index do |restriction, i|
      if (i + 1) == @mailing.restrictions.length 
          email.HTMLBody += restriction.name
        else
          email.HTMLBody += restriction.name+', '
      end
    end

    email.HTMLBody += '</font></TR>' 

    mailingstatus = case mailing.try(:status) 
             when 0 then 'Novo' #image_tag('new.png', :alt => 'Novo')
             when 1 then 'Demandado'
             when 2 then 'Entregue'
             when 3 then 'Finalizado' #image_tag('ok.png', :alt => 'Finalizado')
        end
    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Status</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailingstatus+'</font></TR>'     

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Criado Por</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.user.name+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Data de Criação</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.created_at.strftime("%d/%m/%Y %H:%M:%S")+'</font></TR>'

    if !mailing.rlowner_id.blank?
        @usuario = User.find(:all, :conditions => {:id => mailing.rlowner_id}) 
        @usuario.each do |usuarios|
              email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Demandado para</font>' 
              email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+usuarios.name+'</font></TR>'
              email.CC = usuarios.email
        end
    end

    email.HTMLBody += '</FONT></TABLE></TD>'
    email.HTMLBody += '</TABLE><BR>'

    email.HTMLBody += '<FONT face="Arial" SIZE=2>http://10.11.47.96:3000/mailings/'+mailing.slug+'</FONT>'

    email.To = mailing.user.email
    email.CC += ';Joel.Santiago@claro.com.br'
    email.Save
    email.Send
    WIN32OLE.ole_uninitialize

  end

  def edit_confirmation(mailing)

    WIN32OLE.ole_initialize
    @outlook = WIN32OLE.new('Outlook.Application')

    email = @outlook.CreateItem(0)
    email.Subject = 'Mailing Atualizado: '+mailing.id.to_s
    email.HTMLBody = '<FONT face="Arial" SIZE=3>Mailing Atualizado</font><BR>'

    email.HTMLBody += '<TABLE><CAPTION>'
    email.HTMLBody += '<FONT face="Arial" color=red SIZE=2>Dados do Mailing</font></CAPTION>'
    email.HTMLBody += '<TD valign="top"><TABLE BORDER=1 bordercolor=black cellspacing="0" cellpadding="1%">'
   
    email.HTMLBody += '<TR><TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Demanda</font>'
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.typemailing+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Abordagem</font>'
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.approach+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Objetivo</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.objective+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Descrição</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.description+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Texto do SMS</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.sms+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Pasta Destino</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.folder+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Layout</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.layout+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Periodicidade</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.periodicity+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Restrições</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>' 
    @mailing.restrictions.each_with_index do |restriction, i|
      if (i + 1) == @mailing.restrictions.length 
          email.HTMLBody += restriction.name
        else
          email.HTMLBody += restriction.name+', '
      end
    end

    email.HTMLBody += '</font></TR>' 

    mailingstatus = case mailing.try(:status) 
             when 0 then 'Novo' #image_tag('new.png', :alt => 'Novo')
             when 1 then 'Demandado'
             when 2 then 'Entregue'
             when 3 then 'Finalizado' #image_tag('ok.png', :alt => 'Finalizado')
        end
    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Status</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailingstatus+'</font></TR>'     

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Criado Por</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.user.name+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Data de Criacao</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.created_at.strftime("%d/%m/%Y %H:%M:%S")+'</font></TR>'
    
    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Data de Atualização</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.updated_at.strftime("%d/%m/%Y %H:%M:%S")+'</font></TR>'

    if !mailing.rlowner_id.blank?
        @usuario = User.find(:all, :conditions => {:id => mailing.rlowner_id}) 
        @usuario.each do |usuarios|
              email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Demandado para</font>' 
              email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+usuarios.name+'</font></TR>'
              email.CC = usuarios.email
        end
    end

    email.HTMLBody += '</FONT></TABLE></TD>'
    email.HTMLBody += '</TABLE><BR>'

    email.HTMLBody += '<FONT face="Arial" SIZE=2>http://10.11.47.96:3000/mailings/'+mailing.slug+'</FONT>'

    email.To = mailing.user.email
    email.CC += ';Joel.Santiago@claro.com.br'
    email.Save
    email.Send
    WIN32OLE.ole_uninitialize

  end

  def deliver_confirmation(mailing)

    WIN32OLE.ole_initialize
    @outlook = WIN32OLE.new('Outlook.Application')

    email = @outlook.CreateItem(0)
    email.Subject = 'Mailing Entregue: '+mailing.id.to_s
    email.HTMLBody = '<FONT face="Arial" SIZE=3>Mailing Entregue</font><BR>'

    email.HTMLBody += '<TABLE><CAPTION>'
    email.HTMLBody += '<FONT face="Arial" color=red SIZE=2>Dados do Mailing</font></CAPTION>'
    email.HTMLBody += '<TD valign="top"><TABLE BORDER=1 bordercolor=black cellspacing="0" cellpadding="1%">'
   
    email.HTMLBody += '<TR><TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Demanda</font>'
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.typemailing+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Abordagem</font>'
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.approach+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Objetivo</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.objective+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Descrição</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.description+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Texto do SMS</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.sms+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Pasta Destino</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.folder+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Layout</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.layout+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Periodicidade</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.periodicity+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Restrições</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>' 
    @mailing.restrictions.each_with_index do |restriction, i|
      if (i + 1) == @mailing.restrictions.length 
          email.HTMLBody += restriction.name
        else
          email.HTMLBody += restriction.name+', '
      end
    end

    email.HTMLBody += '</font></TR>' 

    mailingstatus = case mailing.try(:status) 
             when 0 then 'Novo' #image_tag('new.png', :alt => 'Novo')
             when 1 then 'Demandado'
             when 2 then 'Entregue'
             when 3 then 'Finalizado' #image_tag('ok.png', :alt => 'Finalizado')
        end
    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Status</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailingstatus+'</font></TR>'     

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Criado Por</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.user.name+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Data de Criação</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.created_at.strftime("%d/%m/%Y %H:%M:%S")+'</font></TR>'

    if !mailing.rlowner_id.blank?
        @usuario = User.find(:all, :conditions => {:id => mailing.rlowner_id}) 
        @usuario.each do |usuarios|
              email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Demandado para</font>' 
              email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+usuarios.name+'</font></TR>'
              email.CC = usuarios.email
        end
    end

    email.HTMLBody += '</FONT></TABLE></TD>'
    email.HTMLBody += '</TABLE><BR>'

    email.HTMLBody += '<FONT face="Arial" SIZE=2>http://10.11.47.96:3000/mailings/'+mailing.slug+'</FONT>'

    email.To = mailing.user.email
    email.CC += ';Joel.Santiago@claro.com.br'
    email.Save
    email.Send
    WIN32OLE.ole_uninitialize

  end  


  def finalize_confirmation(mailing)

    WIN32OLE.ole_initialize
    @outlook = WIN32OLE.new('Outlook.Application')

    email = @outlook.CreateItem(0)
    email.Subject = 'Mailing Concluído: '+mailing.id.to_s
    email.HTMLBody = '<FONT face="Arial" SIZE=3>Mailing Concluído</font><BR>'

    email.HTMLBody += '<TABLE><CAPTION>'
    email.HTMLBody += '<FONT face="Arial" color=red SIZE=2>Dados do Mailing</font></CAPTION>'
    email.HTMLBody += '<TD valign="top"><TABLE BORDER=1 bordercolor=black cellspacing="0" cellpadding="1%">'
   
    email.HTMLBody += '<TR><TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Demanda</font>'
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.typemailing+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Abordagem</font>'
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.approach+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Objetivo</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.objective+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Descrição</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.description+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Texto do SMS</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.sms+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Pasta Destino</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.folder+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Layout</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.layout+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Periodicidade</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.periodicity+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Restrições</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>' 
    @mailing.restrictions.each_with_index do |restriction, i|
      if (i + 1) == @mailing.restrictions.length 
          email.HTMLBody += restriction.name
        else
          email.HTMLBody += restriction.name+', '
      end
    end

    email.HTMLBody += '</font></TR>' 

    mailingstatus = case mailing.try(:status) 
             when 0 then 'Novo' #image_tag('new.png', :alt => 'Novo')
             when 1 then 'Demandado'
             when 2 then 'Entregue'
             when 3 then 'Finalizado' #image_tag('ok.png', :alt => 'Finalizado')
        end
    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Status</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailingstatus+'</font></TR>'     

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Criado Por</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.user.name+'</font></TR>'

    email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Data de Criação</font>' 
    email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+mailing.created_at.strftime("%d/%m/%Y %H:%M:%S")+'</font></TR>'

    if !mailing.rlowner_id.blank?
        @usuario = User.find(:all, :conditions => {:id => mailing.rlowner_id}) 
        @usuario.each do |usuarios|
              email.HTMLBody += '<TH bgcolor=#BBBBBB><FONT face="Arial" SIZE=2>Demandado para</font>' 
              email.HTMLBody += '<TH ALIGN=LEFT><FONT face="Arial" SIZE=2>'+usuarios.name+'</font></TR>'
              email.CC = usuarios.email
        end
    end

    email.HTMLBody += '</FONT></TABLE></TD>'
    email.HTMLBody += '</TABLE><BR>'

    email.HTMLBody += '<FONT face="Arial" SIZE=2>http://10.11.47.96:3000/mailings/'+mailing.slug+'</FONT>'

    email.To = mailing.user.email
    email.CC += ';Joel.Santiago@claro.com.br'
    email.Save
    email.Send
    WIN32OLE.ole_uninitialize

  end 

end
