# encoding: utf-8

class MailingPdf < Prawn::Document  

	def initialize(mailing, view)    
		super()    
		@mailing = mailing   
		@view = view
		logo
		conteudo
		rodape
	end

	 def logo    
	 	logopath =  "#{Rails.root}/app/assets/images/claro1.png"    
	 	image logopath, :width => 32, :height => 32    
	 	text_box "Marketing Nacional", :at => [50, 715], size: 11, style: :bold
	 	text_box "Inteligência do Negócio", :at => [50, 700], size: 11, style: :bold
	 end

	def conteudo    
		move_down 15  
	 	text "Solicitante: #{@mailing.user.name}", size: 9, style: :bold		  
		move_down 5    
		text "Celular/Ramal: #{@mailing.user.phone} / #{@mailing.user.branch}", size: 9, style: :bold
		move_down 15   
		text "Requisição de Mailing ou Acompanhamento de Ações", size: 11, style: :bold_italic 
		move_down 20 
		text "1) Demanda: #{@mailing.typemailing}", size: 9, style: :bold, :indent_paragraphs => 20
		move_down 10 
		text "2) Meios de abordagem: #{@mailing.approach}", size: 9, style: :bold, :indent_paragraphs => 20
		move_down 10 
		text "3) Objetivo: #{@mailing.objective}", size: 9, style: :bold, :indent_paragraphs => 20
		move_down 10 
		text "4) Descrição da ação ou do acompanhamento: #{@mailing.description}", size: 9, style: :bold, :indent_paragraphs => 20
		move_down 10 
		text "5) Texto da SMS (Quando aplicável): #{@mailing.sms}", size: 9, style: :bold, :indent_paragraphs => 20
		move_down 10 
		text "6) Pasta onde as informações deverão ser disponiblizadas (FTP): #{@mailing.folder}", size: 9, style: :bold, :indent_paragraphs => 20
		move_down 10 
		text "7) Layout do mailing: #{@mailing.layout}", size: 9, style: :bold, :indent_paragraphs => 20
		move_down 10 
		text "8) Periodicidade da mensuração da ação / acompanhamento (Quando aplicável): #{@mailing.periodicity}", size: 9, style: :bold, :indent_paragraphs => 20
		move_down 20 
		text "Restrições para o Mailing: ", size: 11, style: :bold, :indent_paragraphs => 20
		@mailing.restrictions.each_with_index do |restriction, i|
		      if (i + 1) == @mailing.restrictions.length 
		      	  move_down 5 
		          text "#{restriction.name}.", size: 9, style: :bold, :indent_paragraphs => 40
		        else
		          move_down 5 
		          text "#{restriction.name};", size: 9, style: :bold, :indent_paragraphs => 40
		      end
    	end

	end	 

	def rodape    
	 	ano = Time.now.strftime("%Y")
	 	text_box "Claro - Marketing - Inteligência do Negócio - #{ano}", :at => [0, 20], size: 11, style: :bold, :align => :center
	 end

end