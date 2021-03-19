import consumer from "./consumer"
import {TriviaHelpers} from "../packs/custom/trivia_session"
//CLIENT SIDE

$(document).on('turbolinks:load', function () {
  
  var trivia_id = $('#ab-session-id').attr('data-trivia-session-id');

  // If we have left the page with an ID to subscribe to, delete the subcription, you left the game!
  if (trivia_id == undefined) {
    consumer.subscriptions['subscriptions'].forEach(element => {
      consumer.subscriptions.remove(element);
    });
  
    // Do not create the subscription if we are not on a page supplying an ID to subscrube to
    return;
  }

  // We are on the trivia session show page, and have a game ready to connect.
  // Subscribe!
  consumer.subscriptions.create({ channel: "TriviaSocketChannel",
                                  trivia_session_id: $('#ab-session-id').attr('data-trivia-session-id'),
                                  player_id: $('#ab-player-id').attr('data-trivia-player-id') },
  {
    connected() {
      console.log("Client connected to " + $('#ab-session-id').attr('data-trivia-session-id') );
      // Called when the subscription is ready for use on the server
    },

    disconnected() {
      // Called when the subscription has been terminated by the server
    },

    received(data) {
      // Called when there's incoming data on the websocket for this channel
      console.log("Received broadcast:");
      console.log(data);

      var received_action = TriviaHelpers.getAction(data);

      // Action to update player counts - game is still pending
      if (received_action == "player_count_update") {
        TriviaHelpers.updateHtmlOfAllByClass("tsd-current-player-count", data['players']);
        TriviaHelpers.updateHtmlOfAllByClass("tsd-min-player-count", data['needed']);
      }

      // Action to start a countodwn timer to game start - still pending. Will change this at maybe 3 sec left
      else if (received_action == "starting_timer") {
        TriviaHelpers.addClassSafe($("#tse-pending-min-players-area"), "ab-hidden");
        $("#tse-session-start-counter-area").removeClass("ab-hidden");          
        $("#countdown-timer").html(data["value"]);
      }

      // Action when the timer ticks!
      else if (received_action == "timer_tick") {
        $("#countdown-timer").html(data["value"]);
      }

    },

    waiting: function() {
      return this.perform('waiting');
    },

    ready: function() {
      return this.perform('ready');
    },

    eliminated: function() {
      return this.perform('eliminated');
    },

    correct: function() {
      return this.perform('correct');
    },

    incoming: function() {
      return this.perform('incoming');
    },

    ask: function() {
      return this.perform('ask');
    },

    answer: function() {
      return this.perform('answer');
    },

    closed: function() {
      return this.perform('closed');
    }
  })
});

