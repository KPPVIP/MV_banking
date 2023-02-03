$(document).ready(function(){
	
    window.addEventListener('message', function( event ) {     
      if (event.data.action == 'open') {
		$('body').css('display', 'block');
		$('.einzahlen').removeClass('selected');
		$('.abheben').removeClass('selected');
		$('.transfer').removeClass('selected');
		$('.padid').css('display', 'none');
		$('#eingabe2').css('display', 'none');
		$('.einzahlen').addClass('selected');
		document.getElementById("numpadbild").src = "numpad.png";
	  } else if (event.data.action == 'setName') {
		document.getElementById("nameda").innerHTML = event.data.name;
	  } else if (event.data.action == 'setKontostand') {
		setBankAmount(event.data.bank);
      } else {
        $('body').css('display', 'none');
      }
    });

	$("body").on("keyup", function (key) {
		if (key.which == 27) {
			$.post('http://JasonV2_Bank/Exit', JSON.stringify({}));
		}
	});
	
	$(".exit").click(function(){
		$.post('http://JasonV2_Bank/Exit', JSON.stringify({}));
	});

	$("button").click(function(){
		if (this.id === "delete") {
			document.getElementById("mengenfeld").value = document.getElementById("mengenfeld").value.slice(0, -1);
		} else if (this.id === "verlassen") {
			$.post('http://JasonV2_Bank/Exit', JSON.stringify({}));
		} else if (this.id === "confirm") {
			var test = $('.selected').attr('data-action');
			if (test === "transfer") {
				$.post('http://JasonV2_Bank/Ueberweisen', JSON.stringify({id:document.getElementById("idfeld").value, amount:document.getElementById("mengenfeld").value}));
			} else if (test === "abheben") {
				$.post('http://JasonV2_Bank/Auszahlen', JSON.stringify({amount : document.getElementById("mengenfeld").value}));
			} else if (test === "einzahlen") {
				$.post('http://JasonV2_Bank/Einzahlen', JSON.stringify({amount : document.getElementById("mengenfeld").value}));
			}

		} else {
			document.getElementById("mengenfeld").value += this.value;
		}
	});
	
});

function select(elem) {
	$('.einzahlen').removeClass('selected');
	$('.abheben').removeClass('selected');
	$('.transfer').removeClass('selected');
	$(elem).addClass('selected');
	if (elem.id === "transferda") {
		$('.padid').css('display', 'block');
		$('#eingabe2').css('display', 'block');
		document.getElementById("numpadbild").src = "numpad3.png";
	} else if (elem.id === "abhebenda") {
		document.getElementById("numpadbild").src = "numpad2.png";
	} else if (elem.id === "einzahlenda") {
		$('.padid').css('display', 'none');
		$('#eingabe2').css('display', 'none');
		document.getElementById("numpadbild").src = "numpad.png";
	}
}

function setBankAmount(value) {
	document.getElementById("bank").innerHTML = new Intl.NumberFormat('de-DE').format(value);
}