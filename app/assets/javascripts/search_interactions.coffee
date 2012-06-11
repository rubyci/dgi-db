$('.tip').tooltip placement: 'right'

$('#loadingBar').show()
$.get '/gene_group_names.json', (data)->
  $('#genes').typeahead
    source: data
    items: 20
    updater: (item)->
      oldval = this.$element[0]?.value?.split("\n")[0..-2].join("\n")
      (if oldval then oldval + "\n" else ""  ) + item + "\n"
  $('#loadingBar').hide()

$('#addGene').click ->
    geneInput = $('#geneInput')[0].value
    $('#genes')[0].value += geneInput + "\n" unless geneInput is ''
    $('#geneInput')[0].value = ''

$('#defaultGenes').click ->
    $('#genes')[0].value = ['FLT1','FLT2','FLT3','STK1','MM1','LOC100508755','FAKE1'].join "\n"
    $('#genes')[0].value += "\n"

$(".btn-primary").click ->
  $("#loading").modal("show") if $("#html_output").attr("checked")

$(window).unload ->
  $("#loading").modal("hide")

$.valHooks.textarea =
    get: (elem) -> elem.value.replace(/(\n|\r)+$/,"").split("\n").splice(-1,1)[0];

