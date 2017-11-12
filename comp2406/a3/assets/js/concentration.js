$(() => {

	var rows = 4;
	var cols = 4;
	var guesses = 0;
	var $game = $('#game');
	var user = prompt('Enter your name') || 'User' + new Date().getMilliseconds();

	reset();

	function reset() {
		$.getJSON('/memory/intro', {user: user});
		guesses = 0;
		$game.empty();
		for(var i = 0; i < rows; i++) {
			var $row = $('<tr>');
			for(var j = 0; j < cols; j++) {
				var $col = $('<td>');
				var $div = $('<div>').addClass('card');

				$div.attr({row: i, col: j});
				$div.click(clickCard);

				$div.append($('<span>'));
				$col.append($div);
				$row.append($col);
			}
			$game.append($row);
		}
	}

	// use a attribute or remove the event listener to inactivate a card
	function clickCard(ev) {
		var $card = $(ev.target);
		var row = $card.attr('row');
		var col = $card.attr('col');

		if(!$card.hasClass('flip') && $card.is('div.card')) {
			switch($('.flip.active').length) {
				case 0:
				 	flip($.noop);
				 	break;
				case 1:
				 	flip(() => {
				 		if(matched()) {
				 			match();
				 			if(isOver())
								endGame();
						} else
							setTimeout(unflip, 500);
				 	}); 		
					break;
				default:
					break;
			}
		}

		// flips $card
		function flip(cb) {
			$.getJSON('/memory/card', {user: user, row: row, col: col}, (data) => {
				$card.children().text(data.value);
				$card.addClass('flip');
				$card.addClass('active');
				cb();
			});
		}

		// unflips $flip
		function unflip() {
			var $flip = $('.flip.active');
			$flip.removeClass('flip');
			$flip.removeClass('active');
			$flip.children().empty();
		}

		// inactivates matched cards
		function match() {
			var $flip = $('.flip.active');
			$flip.removeClass('active');
		}

		// checks if the flipped cards are equal
		function matched() {
			guesses++;
			$flip = $('.flip.active span');
			var c1 = $flip.eq(0).text();
			var c2 = $flip.eq(1).text();
			return c1 === c2;
		}

		function isOver() {
			$spans = $('.card > span');
			for(var i = 0; i < $spans.length; i++) {
				if($spans.eq(i).text() == '')
					return false;
			}
			return true;
		}

		function endGame() {
			rows += 2;
			cols += 2;
			alert('It took you ' + guesses + ' guesses');
			reset();
		}
	}
});