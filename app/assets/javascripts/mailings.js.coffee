# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

jQuery ->
        $('#mailings').dataTable
          sPaginationType: "full_numbers"
          bJQueryUI: true
          aaSorting: [[ 0, "desc" ]]
          bProcessing: true
          bServerSide: true
          bAutoWidth: true
          sAjaxSource: $('#mailings').data('source')
          oLanguage: {    "sProcessing":   "Processando...",    
          "sLengthMenu":   "Mostrar _MENU_ registros",    "sZeroRecords":  "Não foram encontrados resultados",    "sInfo":         "Mostrando de _START_ até _END_ de _TOTAL_ registros",    "sInfoEmpty":    "Mostrando de 0 até 0 de 0 registros",    "sInfoFiltered": "(filtrado de _MAX_ registros no total)",    "sInfoPostFix":  "",    "sSearch":       "Buscar:",    "sUrl":          "",    "oPaginate": {        "sFirst":    "Primeiro",        "sPrevious": "Anterior",        "sNext":     "Seguinte",        "sLast":     "Último"    }}